# 03 — Manajemen Katalog, Variasi, dan Stok Fisik

> Panduan pengelolaan data produk elektronik, variasi multi-SKU, dan alokasi unit bernomor seri (IMEI/SN) pada Web Admin Zenvorā.

---

## 1. Spesifikasi Produk Elektronik per Kategori

Katalog Zenvorā memiliki 5 kategori resmi (`gadget`, `laptop`, `tv`, `monitor`, `tablet`). Pada form input admin web (`/admin/produk/create`), spesifikasi disesuaikan menurut karakteristik perangkat:

| Kategori | Atribut Wajib Tambahan | Contoh Nilai |
|---|---|---|
| **gadget** | RAM, Internal Storage, Resolusi Kamera, Ukuran Layar | 8GB / 256GB, 50MP OIS, 6.6" Super AMOLED 120Hz |
| **laptop** | Tipe Processor, Kapasitas RAM, Tipe SSD, Ukuran Layar | Intel Core i5-1335U, 16GB DDR5, 512GB NVMe, 14" IPS |
| **tv** | Resolusi Layar, Fitur Smart OS, Ukuran Panel Inci | 4K UHD HDR10+, Google TV, 43 Inci |
| **monitor** | Refresh Rate (Hz), Tipe Panel, Tipe Bezel, Port I/O | 144Hz, IPS 1ms, Curved 1500R, HDMI + DisplayPort |
| **tablet** | Konektivitas (Wi-Fi / 5G), Dukungan Stylus Pen | Wi-Fi Only, Support S-Pen / Apple Pencil |

---

## 2. Struktur Variasi Produk (Multi-SKU)

Produk elektronik premium umumnya memiliki beberapa opsi varian spesifikasi (misal RAM atau kapasitas penyimpanan) dengan harga jual dan kuota stok yang berbeda.

### Skema Tabel Database `produk_varian`:
```sql
CREATE TABLE produk_varian (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    produk_id BIGINT UNSIGNED NOT NULL,
    nama_varian VARCHAR(100) NOT NULL, -- Contoh: "8GB / 256GB - Awesome Iceblue"
    harga INT UNSIGNED NOT NULL,       -- Harga spesifik varian (Rp)
    stok INT UNSIGNED DEFAULT 0,       -- Stok fisik khusus varian ini
    berat_gram INT UNSIGNED DEFAULT 0, -- Berat produk untuk hitungan tarif kurir
    sku VARCHAR(50) NULL UNIQUE,       -- Barcode / Stock Keeping Unit
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (produk_id) REFERENCES produk(id) ON DELETE CASCADE
);
```

### Relasi Stok:
1. Jika produk **memiliki varian**:
   - `produk.stok` merupakan akumulasi total (`SUM(produk_varian.stok)`).
   - Di halaman mobile rincian produk, pembeli memilih varian via *ChoiceChip*. Harga dan sisa stok langsung menyesuaikan varian terpilih.
2. Jika produk **tidak memiliki varian** (misal monitor atau TV standar):
   - `produk.stok` dikelola langsung oleh tabel `unit_produk` milik produk induk.

---

## 3. Manajemen Unit Fisik & Nomor Seri (IMEI / SN)

Setiap barang elektronik bernilai tinggi di Zenvorā memiliki identitas fisik unik pada tabel `unit_produk`:

- **Format Serial Number**:
  ```
  ZNV-P{kodeProduk 2 digit}-{urutan 4 digit}
  Contoh: ZNV-P01-0001 (Samsung Galaxy A55 unit pertama)
  ```
- **Siklus Status Unit**:
  - `'tersedia'`: Unit berada di rak gudang dan siap dijual.
  - `'terjual'`: Unit telah dialokasikan ke pesanan (`detail_pesanan_id` terisi).
  - `'rusak'`: Unit cacat saat inspeksi gudang dan dikeluarkan dari stok aktif.

### Menu Gudang Admin (`/admin/unit-produk`):
Halaman ini memungkinkan admin gudang untuk:
1. Memindai barcode atau mengetikkan nomor seri fisik untuk memeriksa status unit.
2. Mengetahui ke pesanan mana nomor seri tertentu dikirimkan (pelacakan klaim garansi resmi).
3. Melakukan *Stock Opname* berkala mencocokkan fisik di rak dengan data sistem.

---

## 4. Sistem Peringatan Stok Kritis (Low Stock Alert)

Untuk mencegah toko kehabisan barang tanpa disadari (*out of stock*), Web Admin memiliki logika visual khusus:

| Kondisi Stok | Status Badge | Warna Aksen | Tindakan Admin |
|---|---|---|---|
| `stok == 0` | **HABIS** | Merah (`#E5484D`) | Segera hubungi distributor / matikan status tampil |
| `stok < 3` | **KRITIS** | Kuning (`#F5B942`) | Rencanakan re-stock unit baru |
| `stok >= 3` | **AMAN** | Hijau (`#36B37E`) | Kondisi normal |

Di halaman daftar produk web (`/admin/produk`), terdapat tombol filter cepat:
- **Semua Produk**: Menampilkan seluruh katalog.
- **Perlu Re-stock**: Hanya memfilter produk dengan sisa stok < 3 unit.
- **Non-Aktif**: Produk yang dinonaktifkan sementara dari penjualan.
