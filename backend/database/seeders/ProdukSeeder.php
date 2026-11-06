<?php

namespace Database\Seeders;

use App\Models\Produk;
use App\Models\UnitProduk;
use Illuminate\Database\Seeder;

class ProdukSeeder extends Seeder
{
    public function run(): void
    {
        $produkData = [
            ['id' => 1, 'nama' => 'Samsung Galaxy A55 5G 8/256', 'merek' => 'Samsung', 'harga' => 5999000, 'kategori' => 'gadget', 'stok' => 5, 'tersedia' => true, 'deskripsi' => 'Smartphone 5G dengan kamera 50MP OIS dan layar Super AMOLED 120Hz.', 'berat_gram' => 213, 'garansi_bulan' => 12],
            ['id' => 2, 'nama' => 'Xiaomi Redmi Note 13 Pro', 'merek' => 'Xiaomi', 'harga' => 4299000, 'kategori' => 'gadget', 'stok' => 8, 'tersedia' => true, 'deskripsi' => 'Kamera ultra-jernih 200MP dengan OIS, pengisian daya turbo 67W.', 'berat_gram' => 187, 'garansi_bulan' => 12],
            ['id' => 3, 'nama' => 'Apple iPhone 15 128GB', 'merek' => 'Apple', 'harga' => 12999000, 'kategori' => 'gadget', 'stok' => 0, 'tersedia' => true, 'deskripsi' => 'Dynamic Island, kamera utama 48 MP, konektor USB-C.', 'berat_gram' => 171, 'garansi_bulan' => 12], // Stok nol wajib
            ['id' => 4, 'nama' => 'ASUS Vivobook 14', 'merek' => 'ASUS', 'harga' => 8499000, 'kategori' => 'laptop', 'stok' => 4, 'tersedia' => true, 'deskripsi' => 'Laptop bertenaga Intel Core generasi terbaru, layar NanoEdge anti-silau.', 'berat_gram' => 1400, 'garansi_bulan' => 24],
            ['id' => 5, 'nama' => 'Lenovo IdeaPad Slim 3', 'merek' => 'Lenovo', 'harga' => 7199000, 'kategori' => 'laptop', 'stok' => 6, 'tersedia' => true, 'deskripsi' => 'Desain ramping dan ringan kelas militer, Rapid Charge Boost.', 'berat_gram' => 1620, 'garansi_bulan' => 24],
            ['id' => 6, 'nama' => 'Acer Aspire 5', 'merek' => 'Acer', 'harga' => 9299000, 'kategori' => 'laptop', 'stok' => 3, 'tersedia' => true, 'deskripsi' => 'Konektivitas Wi-Fi 6E, sistem pendingin ganda, performa tinggi.', 'berat_gram' => 1700, 'garansi_bulan' => 24],
            ['id' => 7, 'nama' => 'Samsung 43" Crystal UHD', 'merek' => 'Samsung', 'harga' => 5499000, 'kategori' => 'tv', 'stok' => 3, 'tersedia' => true, 'deskripsi' => 'Resolusi 4K nyata dengan Dynamic Crystal Color dan HDR 10+.', 'berat_gram' => 9500, 'garansi_bulan' => 12],
            ['id' => 8, 'nama' => 'LG 50" 4K Smart TV', 'merek' => 'LG', 'harga' => 6999000, 'kategori' => 'tv', 'stok' => 2, 'tersedia' => true, 'deskripsi' => 'AI Sound Pro sinematik dengan webOS responsif.', 'berat_gram' => 12500, 'garansi_bulan' => 12],
            ['id' => 9, 'nama' => 'TCL 32" HD Android TV', 'merek' => 'TCL', 'harga' => 1899000, 'kategori' => 'tv', 'stok' => 0, 'tersedia' => true, 'deskripsi' => null, 'berat_gram' => 4200, 'garansi_bulan' => 12], // Stok nol & deskripsi null
            ['id' => 10, 'nama' => 'LG 24" Full HD', 'merek' => 'LG', 'harga' => 1649000, 'kategori' => 'monitor', 'stok' => 7, 'tersedia' => true, 'deskripsi' => 'Panel IPS 75Hz, AMD FreeSync, 3-Side Virtually Borderless.', 'berat_gram' => 3300, 'garansi_bulan' => 24],
            ['id' => 11, 'nama' => 'Dell 24" Full HD', 'merek' => 'Dell', 'harga' => 1799000, 'kategori' => 'monitor', 'stok' => 5, 'tersedia' => true, 'deskripsi' => 'Monitor ergonomis bersertifikasi TUV Eye Comfort.', 'berat_gram' => 3600, 'garansi_bulan' => 36],
            ['id' => 12, 'nama' => 'Samsung 27" Curved 144Hz', 'merek' => 'Samsung', 'harga' => 3499000, 'kategori' => 'monitor', 'stok' => 2, 'tersedia' => false, 'deskripsi' => null, 'berat_gram' => 5500, 'garansi_bulan' => 24], // tersedia false & deskripsi null
            ['id' => 13, 'nama' => 'Samsung Galaxy Tab A9+', 'merek' => 'Samsung', 'harga' => 3199000, 'kategori' => 'tablet', 'stok' => 6, 'tersedia' => true, 'deskripsi' => 'Layar 11 inci 90Hz dengan audio quad-speaker Dolby Atmos.', 'berat_gram' => 510, 'garansi_bulan' => 12],
            ['id' => 14, 'nama' => 'Xiaomi Pad 6', 'merek' => 'Xiaomi', 'harga' => 4999000, 'kategori' => 'tablet', 'stok' => 4, 'tersedia' => true, 'deskripsi' => 'Snapdragon 870, layar WQHD+ 144Hz, baterai 8840mAh.', 'berat_gram' => 490, 'garansi_bulan' => 12],
            ['id' => 15, 'nama' => 'Apple iPad 10th Gen', 'merek' => 'Apple', 'harga' => 7999000, 'kategori' => 'tablet', 'stok' => 3, 'tersedia' => true, 'deskripsi' => 'Layar Liquid Retina 10,9 inci, chip A14 Bionic bertenaga.', 'berat_gram' => 477, 'garansi_bulan' => 12],
        ];

        $unitSeq = 1;

        foreach ($produkData as $p) {
            $stokAwal = $p['stok'];
            $prod = Produk::updateOrCreate(['id' => $p['id']], $p);

            // Buat baris unit_produk fisik sesuai jumlah stok awal
            for ($s = 1; $s <= $stokAwal; $s++) {
                UnitProduk::updateOrCreate(
                    ['id' => $unitSeq],
                    [
                        'produk_id' => $prod->id,
                        'nomor_seri' => sprintf('ZNV-P%02d-%04d', $prod->id, $unitSeq),
                        'status' => 'tersedia',
                        'detail_pesanan_id' => null,
                    ]
                );
                $unitSeq++;
            }
        }
    }
}
