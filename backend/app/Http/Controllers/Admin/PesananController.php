<?php

namespace App\Http\Controllers\Admin;

use App\Enums\StatusPesanan;
use App\Exceptions\BentrokException;
use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Services\ServisPesanan;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PesananController extends Controller
{
    public function __construct(
        protected ServisPesanan $servisPesanan
    ) {}

    /**
     * Menampilkan daftar pesanan dengan filter status.
     */
    public function index(Request $request): View
    {
        $statusTerpilih = $request->query('status');
        $nilaiStatus = array_map(fn (StatusPesanan $status) => $status->value, StatusPesanan::cases());

        if (! in_array($statusTerpilih, $nilaiStatus, true)) {
            $statusTerpilih = null;
        }

        $pesanan = Pesanan::with(['pelanggan', 'kurir'])
            ->when($statusTerpilih, fn ($query) => $query->where('status', $statusTerpilih))
            ->orderByDesc('created_at')
            ->paginate(15)
            ->withQueryString();

        $hitunganStatus = Pesanan::query()
            ->selectRaw('status, COUNT(*) as jumlah')
            ->groupBy('status')
            ->pluck('jumlah', 'status');

        return view('admin.pesanan.index', [
            'judulHalaman' => 'Pesanan Masuk',
            'pesanan' => $pesanan,
            'statusTerpilih' => $statusTerpilih,
            'hitunganStatus' => $hitunganStatus,
            'totalSemua' => $hitunganStatus->sum(),
            'daftarStatus' => StatusPesanan::cases(),
        ]);
    }

    /**
     * Menampilkan rincian satu pesanan beserta unit serialnya.
     */
    public function show(Pesanan $pesanan): View
    {
        $pesanan->load(['pelanggan', 'kurir', 'metodePembayaran', 'detail.unit']);

        $statusSekarang = StatusPesanan::from($pesanan->status);

        return view('admin.pesanan.show', [
            'judulHalaman' => 'Rincian Pesanan',
            'pesanan' => $pesanan,
            'statusBerikutnya' => $statusSekarang->berikutnya(),
        ]);
    }

    /**
     * Memproses perpindahan status pesanan melalui state machine resmi.
     */
    public function ubahStatus(Request $request, Pesanan $pesanan): RedirectResponse
    {
        $data = $request->validate([
            'status' => ['required', 'string'],
        ], [
            'status.required' => 'Status tujuan wajib dipilih.',
        ]);

        try {
            $this->servisPesanan->ubahStatus($pesanan->id, $data['status']);
        } catch (BentrokException $exception) {
            return back()->withErrors(['status' => $exception->getMessage()]);
        }

        return back()->with('status', "Status pesanan {$pesanan->nomor_pesanan} berhasil diperbarui.");
    }

    /**
     * Menyimpan nomor resi lalu memajukan pesanan ke status dikirim.
     */
    public function simpanResi(Request $request, Pesanan $pesanan): RedirectResponse
    {
        $data = $request->validate([
            'nomor_resi' => ['required', 'string', 'max:50'],
        ], [
            'nomor_resi.required' => 'Nomor resi wajib diisi.',
            'nomor_resi.max' => 'Nomor resi maksimal 50 karakter.',
        ]);

        $statusSekarang = StatusPesanan::from($pesanan->status);

        if (! in_array($statusSekarang, [StatusPesanan::Diproses, StatusPesanan::Dikirim], true)) {
            return back()->withErrors([
                'nomor_resi' => 'Resi hanya dapat diisi saat pesanan berstatus diproses atau dikirim.',
            ]);
        }

        $pesanan->update(['nomor_resi' => $data['nomor_resi']]);

        try {
            if ($statusSekarang === StatusPesanan::Diproses) {
                $this->servisPesanan->ubahStatus($pesanan->id, StatusPesanan::Dikirim->value);
            }
        } catch (BentrokException $exception) {
            return back()->withErrors(['nomor_resi' => $exception->getMessage()]);
        }

        return back()->with('status', "Resi {$data['nomor_resi']} tersimpan dan pesanan ditandai dikirim.");
    }
}
