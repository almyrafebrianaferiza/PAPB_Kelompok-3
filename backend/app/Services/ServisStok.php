<?php

namespace App\Services;

use App\Models\DetailPesanan;
use App\Models\Produk;
use App\Models\UnitProduk;

class ServisStok
{
    /**
     * Membuat N unit fisik baru dengan nomor seri otomatis untuk produk tertentu.
     */
    public function buatUnit(Produk $produk, int $jumlah): void
    {
        for ($i = 0; $i < $jumlah; $i++) {
            $urut = UnitProduk::max('id') + 1;
            UnitProduk::create([
                'produk_id' => $produk->id,
                'nomor_seri' => sprintf('ZNV-P%02d-%04d', $produk->id, $urut),
                'status' => 'tersedia',
                'detail_pesanan_id' => null,
            ]);
        }
        $this->sinkronkanStok($produk);
    }

    /**
     * Menyesuaikan jumlah unit fisik tersedia dengan target stok baru.
     */
    public function sesuaikanUnitKeTarget(Produk $produk, int $targetStok): void
    {
        $unitTersedia = UnitProduk::where('produk_id', $produk->id)
            ->where('status', 'tersedia')
            ->get();

        $selisih = $targetStok - $unitTersedia->count();

        if ($selisih > 0) {
            $this->buatUnit($produk, $selisih);
        } elseif ($selisih < 0) {
            $jumlahHapus = abs($selisih);
            $idHapus = $unitTersedia->take($jumlahHapus)->pluck('id');
            UnitProduk::whereIn('id', $idHapus)->delete();
            $this->sinkronkanStok($produk);
        }
    }

    /**
     * Mengalokasikan N unit tersedia ke detail pesanan (status: terjual).
     */
    public function jual(Produk $produk, int $jumlah, DetailPesanan $detail): void
    {
        $units = UnitProduk::where('produk_id', $produk->id)
            ->where('status', 'tersedia')
            ->orderBy('id', 'asc')
            ->lockForUpdate()
            ->take($jumlah)
            ->get();

        foreach ($units as $u) {
            $u->update([
                'status' => 'terjual',
                'detail_pesanan_id' => $detail->id,
            ]);
        }

        $this->sinkronkanStok($produk);
    }

    /**
     * Mengembalikan unit fisik dari pesanan yang dibatalkan menjadi tersedia kembali.
     */
    public function kembalikanUnit(int $detailPesananId): void
    {
        $units = UnitProduk::where('detail_pesanan_id', $detailPesananId)->get();
        $produkId = null;

        foreach ($units as $u) {
            $produkId = $u->produk_id;
            $u->update([
                'status' => 'tersedia',
                'detail_pesanan_id' => null,
            ]);
        }

        if ($produkId) {
            $produk = Produk::find($produkId);
            if ($produk) {
                $this->sinkronkanStok($produk);
            }
        }
    }

    /**
     * Menjaga invarian: produk.stok = COUNT(unit_produk WHERE status = 'tersedia').
     */
    public function sinkronkanStok(Produk $produk): void
    {
        $count = UnitProduk::where('produk_id', $produk->id)
            ->where('status', 'tersedia')
            ->count();

        $produk->update(['stok' => $count]);
    }
}
