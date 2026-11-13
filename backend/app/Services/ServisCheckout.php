<?php

namespace App\Services;

use App\Exceptions\BentrokException;
use App\Models\DetailPesanan;
use App\Models\Keranjang;
use App\Models\Pelanggan;
use App\Models\Pesanan;
use App\Models\Produk;
use App\Models\UnitProduk;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ServisCheckout
{
    public function __construct(
        protected ServisOngkir $servisOngkir,
        protected ServisStok $servisStok
    ) {}

    public function proses(Pelanggan $pelanggan, string $kunci, array $data): Pesanan
    {
        // 1. Pemeriksaan replay idempotensi SEBELUM validasi keranjang
        $lama = Pesanan::where('pelanggan_id', $pelanggan->id)
            ->where('kunci_idempoten', $kunci)
            ->first();

        if ($lama) {
            return $lama->load('detail.unit', 'kurir', 'metodePembayaran');
        }

        // 2. Validasi keranjang tidak boleh kosong
        $keranjang = Keranjang::where('pelanggan_id', $pelanggan->id)
            ->orderBy('produk_id', 'asc')
            ->get();

        if ($keranjang->isEmpty()) {
            throw ValidationException::withMessages([
                'keranjang' => ['Keranjang belanja kosong saat checkout'],
            ]);
        }

        return DB::transaction(function () use ($pelanggan, $kunci, $data, $keranjang) {
            $idProduk = $keranjang->pluck('produk_id')->sort()->values();

            // Kunci baris produk, SELALU urut ID naik (mencegah deadlock)
            $produkMap = Produk::whereIn('id', $idProduk)
                ->orderBy('id', 'asc')
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            // Cek replay sekali lagi di dalam transaksi
            $replayCheck = Pesanan::where('pelanggan_id', $pelanggan->id)
                ->where('kunci_idempoten', $kunci)
                ->first();

            if ($replayCheck) {
                return $replayCheck->load('detail.unit', 'kurir', 'metodePembayaran');
            }

            // Periksa ketersediaan unit seluruh item di keranjang
            $itemKurang = [];
            foreach ($keranjang as $item) {
                $p = $produkMap->get($item->produk_id);
                $unitTersedia = $p ? UnitProduk::where('produk_id', $p->id)
                    ->where('status', 'tersedia')
                    ->lockForUpdate()
                    ->count() : 0;

                if (! $p || ! $p->tersedia || $unitTersedia < $item->jumlah) {
                    $itemKurang[] = [
                        'produk_id' => $item->produk_id,
                        'nama' => $p?->nama ?? 'Produk Tidak Ditemukan',
                        'diminta' => $item->jumlah,
                        'tersedia' => $p?->tersedia ? $unitTersedia : 0,
                    ];
                }
            }

            if (! empty($itemKurang)) {
                throw new BentrokException('Stok beberapa barang tidak mencukupi', [
                    'item_kurang' => $itemKurang,
                ]);
            }

            // Hitung kalkulasi ongkir dan keuangan di server
            $hitung = $this->servisOngkir->hitung($keranjang, $produkMap, (int) $data['kurir_id']);

            $pesanan = Pesanan::create([
                'pelanggan_id' => $pelanggan->id,
                'kurir_id' => $data['kurir_id'],
                'metode_pembayaran_id' => $data['metode_pembayaran_id'],
                'status' => 'menunggu_pembayaran',
                'nama_penerima' => trim($data['nama_penerima']),
                'alamat_penerima' => trim($data['alamat_penerima']),
                'subtotal' => $hitung['subtotal'],
                'total_berat_gram' => $hitung['total_berat_gram'],
                'berat_kg_tertagih' => $hitung['berat_kg_tertagih'],
                'tarif_per_kg_saat_pesan' => $hitung['tarif_per_kg'],
                'ongkir' => $hitung['ongkir'],
                'total' => $hitung['total'],
                'kunci_idempoten' => $kunci,
            ]);

            $nomorPesanan = sprintf('ZNV-%s-%05d', now()->format('Ymd'), $pesanan->id);
            $pesanan->update(['nomor_pesanan' => $nomorPesanan]);

            foreach ($keranjang as $item) {
                $prod = $produkMap->get($item->produk_id);
                $detail = DetailPesanan::create([
                    'pesanan_id' => $pesanan->id,
                    'produk_id' => $prod->id,
                    'nama_produk' => $prod->nama,
                    'harga_satuan' => $prod->harga,
                    'jumlah' => $item->jumlah,
                    'berat_gram_satuan' => $prod->berat_gram,
                    'garansi_bulan' => $prod->garansi_bulan,
                    'subtotal_item' => $prod->harga * $item->jumlah,
                ]);

                // Mengikat unit fisik serial ke baris detail pesanan
                $this->servisStok->jual($prod, $item->jumlah, $detail);
            }

            // Kosongkan keranjang pelanggan
            Keranjang::where('pelanggan_id', $pelanggan->id)->delete();

            return $pesanan->load('detail.unit', 'kurir', 'metodePembayaran');
        });
    }
}
