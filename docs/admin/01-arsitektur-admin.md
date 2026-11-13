# 01 — Arsitektur Web Admin Backend Zenvorā

> Dokumen acuan arsitektur sistem pengelola toko (Seller/Admin Dashboard) pada backend Laravel Zenvorā.

---

## 1. Latar Belakang & Filosofi Arsitektur

Dalam sistem e-commerce terdistribusi modern dan profesional, antarmuka dibagi menjadi dua ranah utama:

```
┌───────────────────────────────────────┐      ┌───────────────────────────────────────┐
│     Mobile App (Flutter Client)       │      │     Web Dashboard (Laravel Backend)   │
│         Peran: Pembeli (Buyer)        │      │         Peran: Penjual (Seller/Admin) │
├───────────────────────────────────────┤      ├───────────────────────────────────────┤
│ • Eksplorasi katalog & varian produk  │      │ • Memantau omzet & ringkasan KPI toko │
│ • Deteksi lokasi GPS saat checkout    │      │ • Verifikasi mutasi pembayaran        │
│ • Menempatkan pesanan transaksional   │      │ • Mengalokasikan serial number fisik  │
│ • Memantau status + konfirmasi bayar  │      │ • Memasukkan nomor resi ekspedisi     │
│ • REST API via Bearer Token statis    │      │ • Web Session + CSRF Protection       │
└──────────────────┬────────────────────┘      └──────────────────┬────────────────────┘
                   │                                              │
                   ▼                                              ▼
          [routes/api.php]                                [routes/web.php]
          (15 Endpoint Resmi)                             (Grup Rute /admin)
                   │                                              │
                   └──────────────────────┬───────────────────────┘
                                          │
                                          ▼
                             [MySQL Database `zenvora`]
                     (Tabel Terpadu: produk, pesanan, unit, varian)
```

### Mengapa Pemrosesan Pesanan Harus di Web Backend?
1. **Keamanan & Otoritas**: Pembeli di HP tidak boleh memiliki tombol yang bisa mengubah status pesanannya sendiri menjadi *"Sudah Dibayar"* atau *"Selesai"*. Hal ini merupakan celah fraud kritis pada toko online.
2. **Kesesuaian Operasional Toko**: Staf gudang dan admin bekerja di komputer laptop/desktop untuk mencetak label pengiriman, memindai barcode/serial number fisik barang, dan mengecek mutasi bank.
3. **Pemisahan Jalur Jaringan**: Mobile menggunakan API JSON dengan token, sedangkan Admin Web beroperasi menggunakan session web terenkripsi dan token CSRF.

---

## 2. Integritas Kontrak 15 Endpoint API

> **Aturan Keras**: Pembuatan Web Admin Dashboard **TIDAK BOLEH** mengubah atau menambah rute API pada `routes/api.php` agar kepatuhan kontrak UTS (15 endpoint) dan seluruh pengujian otomatis yang telah hijau tetap terjaga 100%.

Seluruh rute Web Admin ditempatkan secara eksklusif pada **`routes/web.php`** di bawah Controller internal namespace `App\Http\Controllers\Admin\*`:

| Kategori | Controller Web Admin | Controller API Mobile (Tetap) |
|---|---|---|
| Dashboard KPI | `Admin\DashboardController` | — (Khusus Web Admin) |
| Manajemen Pesanan | `Admin\PesananController` | `Api\PesananController` (Mobile Read) |
| Manajemen Katalog | `Admin\ProdukController` | `Api\ProdukController` (Mobile Read) |
| Pelacakan Unit Fisik | `Admin\UnitProdukController` | — (Internal Backend) |

---

## 3. Struktur Rute Web Admin (`routes/web.php`)

```php
Route::prefix('admin')->name('admin.')->group(function () {
    // 1. Dashboard Ringkasan & KPI
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // 2. Manajemen Pesanan & Fulfillment
    Route::get('/pesanan', [PesananController::class, 'index'])->name('pesanan.index');
    Route::get('/pesanan/{id}', [PesananController::class, 'show'])->name('pesanan.show');
    Route::post('/pesanan/{id}/status', [PesananController::class, 'ubahStatus'])->name('pesanan.status');
    Route::post('/pesanan/{id}/resi', [PesananController::class, 'inputResi'])->name('pesanan.resi');

    // 3. Manajemen Katalog Produk & Variasi
    Route::get('/produk', [ProdukController::class, 'index'])->name('produk.index');
    Route::get('/produk/create', [ProdukController::class, 'create'])->name('produk.create');
    Route::post('/produk', [ProdukController::class, 'store'])->name('produk.store');
    Route::get('/produk/{id}/edit', [ProdukController::class, 'edit'])->name('produk.edit');
    Route::put('/produk/{id}', [ProdukController::class, 'update'])->name('produk.update');
    Route::delete('/produk/{id}', [ProdukController::class, 'destroy'])->name('produk.destroy');

    // 4. Monitoring Stok Fisik & Serial Number Unit
    Route::get('/unit-produk', [UnitProdukController::class, 'index'])->name('unit.index');
});
```

---

## 4. Stack Teknologi & Standar Implementasi

1. **Backend Framework**: Laravel 11 / PHP 8.3 native.
2. **Templating Engine**: Laravel Blade Components (`resources/views/admin/layouts/` dan `components/`).
3. **Desain & Tema**: Mengadopsi spesifikasi resmi dari `desain-admin.md`:
   - Dark theme dominan: Background `#0B0B0B`, Surface `#171717`, Elevated `#202020`, Border `#333333`.
   - Brand Accent: Orange Zenvora `#FF6A00` & Hover `#E85D00`.
   - Tipografi: Google Font **Poppins** (SemiBold untuk heading, Regular untuk isi data).
4. **Interaktivitas Ringan**: Vanilla JavaScript / CSS native murni tanpa dependensi Node.js / NPM kompleks agar server dapat langsung dijalankan dengan `php artisan serve`.
5. **Database Interactivity**: Memanfaatkan model Eloquent yang sudah ada (`Produk`, `ProdukVarian`, `UnitProduk`, `Pesanan`, `DetailPesanan`, `Kurir`, `Pelanggan`) sehingga data antara aplikasi mobile dan web dashboard tersinkron setelah halaman dimuat ulang (bukan real-time).
