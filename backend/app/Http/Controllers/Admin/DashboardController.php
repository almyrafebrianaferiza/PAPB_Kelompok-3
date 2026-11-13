<?php

namespace App\Http\Controllers\Admin;

use App\Enums\StatusPesanan;
use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\Produk;
use Illuminate\View\View;

class DashboardController extends Controller
{
    /**
     * Menampilkan halaman ringkasan panel admin.
     */
    public function index(): View
    {
        $statusAktif = [
            StatusPesanan::MenungguPembayaran->value,
            StatusPesanan::MenungguKonfirmasi->value,
            StatusPesanan::Dibayar->value,
            StatusPesanan::Diproses->value,
        ];

        return view('admin.dashboard.index', [
            'judulHalaman' => 'Dashboard',
            'namaAdmin' => config('admin.nama'),
            'omzetSelesai' => (int) Pesanan::where('status', StatusPesanan::Selesai->value)->sum('total'),
            'jumlahPerluProses' => Pesanan::whereIn('status', $statusAktif)->count(),
            'jumlahProdukAktif' => Produk::count(),
            'jumlahStokKritis' => Produk::where('tersedia', true)->where('stok', '<', 3)->count(),
            'pesananTerbaru' => Pesanan::latest()->limit(5)->get(),
            'produkMenipis' => Produk::where('tersedia', true)
                ->where('stok', '<', 3)
                ->orderBy('stok')
                ->limit(5)
                ->get(),
        ]);
    }
}
