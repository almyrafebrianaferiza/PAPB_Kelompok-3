<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UnitProduk;
use App\Services\ServisStok;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class UnitProdukController extends Controller
{
    public function __construct(
        protected ServisStok $servisStok
    ) {}

    /**
     * Menampilkan unit fisik beserta status serial number.
     */
    public function index(Request $request): View
    {
        $status = $request->query('status');
        $cari = trim((string) $request->query('cari'));
        $nilaiStatus = ['tersedia', 'terjual', 'rusak'];

        if (! in_array($status, $nilaiStatus, true)) {
            $status = null;
        }

        $unit = UnitProduk::with(['produk', 'detailPesanan.pesanan'])
            ->when($status, fn ($query) => $query->where('status', $status))
            ->when($cari !== '', fn ($query) => $query->where('nomor_seri', 'like', "%{$cari}%"))
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        $hitungan = UnitProduk::query()
            ->selectRaw('status, COUNT(*) as jumlah')
            ->groupBy('status')
            ->pluck('jumlah', 'status');

        return view('admin.unit.index', [
            'judulHalaman' => 'Unit & Serial',
            'unit' => $unit,
            'statusTerpilih' => $status,
            'cari' => $cari,
            'hitungan' => $hitungan,
            'totalSemua' => $hitungan->sum(),
        ]);
    }

    /**
     * Mengubah status unit tersedia menjadi rusak atau sebaliknya.
     */
    public function ubahStatus(Request $request, UnitProduk $unit): RedirectResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['tersedia', 'rusak'])],
        ], [
            'status.required' => 'Status unit wajib dipilih.',
            'status.in' => 'Status unit hanya boleh tersedia atau rusak.',
        ]);

        if ($unit->status === 'terjual') {
            return back()->withErrors([
                'unit' => 'Unit yang sudah terjual tidak dapat diubah statusnya.',
            ]);
        }

        $unit->update(['status' => $data['status']]);
        $this->servisStok->sinkronkanStok($unit->produk);

        $label = $data['status'] === 'tersedia' ? 'tersedia' : 'rusak';

        return back()->with('status', "Unit {$unit->nomor_seri} ditandai {$label}.");
    }
}
