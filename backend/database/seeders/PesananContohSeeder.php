<?php

namespace Database\Seeders;

use App\Models\DetailPesanan;
use App\Models\Kurir;
use App\Models\Pesanan;
use App\Models\Produk;
use App\Models\UnitProduk;
use Illuminate\Database\Seeder;

class PesananContohSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Pesanan A: Redmi Note 13 Pro (1) + Galaxy Tab A9+ (1) -> status: menunggu_pembayaran
        $this->buatPesananContoh(
            id: 1,
            nomorPesanan: 'ZNV-20261106-00001',
            kurirId: 2, // Zenvora Jawa (7500/kg)
            metodeId: 2, // transfer_manual
            status: 'menunggu_pembayaran',
            penerima: 'Andi Pratama',
            alamat: 'Jl. Ahmad Yani No. 45, Malang, Jawa Timur',
            kunci: 'seed-order-a-key-001',
            items: [
                ['produk_id' => 2, 'jumlah' => 1],
                ['produk_id' => 13, 'jumlah' => 1],
            ]
        );

        // 2. Pesanan B: ASUS Vivobook 14 (1) -> status: dibayar
        $this->buatPesananContoh(
            id: 2,
            nomorPesanan: 'ZNV-20261106-00002',
            kurirId: 1, // Zenvora Kota (4000/kg)
            metodeId: 1, // tunai_di_tempat
            status: 'dibayar',
            penerima: 'Siti Rahmawati',
            alamat: 'Jl. Darmo Permai II No. 12, Surabaya, Jawa Timur',
            kunci: 'seed-order-b-key-002',
            items: [
                ['produk_id' => 4, 'jumlah' => 1],
            ]
        );

        // 3. Pesanan C: 2x LG 24" Full HD -> status: selesai
        $this->buatPesananContoh(
            id: 3,
            nomorPesanan: 'ZNV-20261106-00003',
            kurirId: 3, // Zenvora Nusantara (15000/kg)
            metodeId: 2, // transfer_manual
            status: 'selesai',
            penerima: 'Budi Santoso',
            alamat: 'Jl. Gajah Mada No. 88, Denpasar, Bali',
            kunci: 'seed-order-c-key-003',
            items: [
                ['produk_id' => 10, 'jumlah' => 2],
            ]
        );
    }

    private function buatPesananContoh(int $id, string $nomorPesanan, int $kurirId, int $metodeId, string $status, string $penerima, string $alamat, string $kunci, array $items): void
    {
        $kurir = Kurir::find($kurirId);
        $subtotal = 0;
        $totalBerat = 0;

        $detailRecords = [];
        foreach ($items as $item) {
            $p = Produk::find($item['produk_id']);
            $sub = $p->harga * $item['jumlah'];
            $subtotal += $sub;
            $totalBerat += $p->berat_gram * $item['jumlah'];

            $detailRecords[] = [
                'produk' => $p,
                'jumlah' => $item['jumlah'],
                'subtotal_item' => $sub,
            ];
        }

        $beratKg = (int) ceil($totalBerat / 1000);
        $ongkir = $beratKg * $kurir->tarif_per_kg;
        $total = $subtotal + $ongkir;

        $pesanan = Pesanan::updateOrCreate(
            ['id' => $id],
            [
                'nomor_pesanan' => $nomorPesanan,
                'pelanggan_id' => 1,
                'kurir_id' => $kurirId,
                'metode_pembayaran_id' => $metodeId,
                'status' => $status,
                'nama_penerima' => $penerima,
                'alamat_penerima' => $alamat,
                'subtotal' => $subtotal,
                'total_berat_gram' => $totalBerat,
                'berat_kg_tertagih' => $beratKg,
                'tarif_per_kg_saat_pesan' => $kurir->tarif_per_kg,
                'ongkir' => $ongkir,
                'total' => $total,
                'kunci_idempoten' => $kunci,
            ]
        );

        foreach ($detailRecords as $d) {
            $prod = $d['produk'];
            $detail = DetailPesanan::create([
                'pesanan_id' => $pesanan->id,
                'produk_id' => $prod->id,
                'nama_produk' => $prod->nama,
                'harga_satuan' => $prod->harga,
                'jumlah' => $d['jumlah'],
                'berat_gram_satuan' => $prod->berat_gram,
                'garansi_bulan' => $prod->garansi_bulan,
                'subtotal_item' => $d['subtotal_item'],
            ]);

            // Alokasikan unit fisik
            $units = UnitProduk::where('produk_id', $prod->id)
                ->where('status', 'tersedia')
                ->take($d['jumlah'])
                ->get();

            foreach ($units as $u) {
                $u->update([
                    'status' => 'terjual',
                    'detail_pesanan_id' => $detail->id,
                ]);
            }

            // Kurangi stok produk agar invarian terjaga
            $prod->decrement('stok', $d['jumlah']);
        }
    }
}
