# 05 — Rencana Eksekusi Bertahap Web Admin Backend

> Roadmap implementasi bertahap Web Admin Dashboard Zenvorā agar terealisasi secara profesional, aman, dan tanpa melanggar batasan kontrak API.

---

## 1. Tahapan Pengerjaan Bertahap

```
┌────────────────────────────────────────────────────────────────────────┐
│                        TAHAP EKSEKUSI ADMIN WEB                        │
├───────────────────┬────────────────────────────────────────────────────┤
│ Tahap 1           │ Fondasi Routing Web & Layout Blade Dark Theme      │
│ Tahap 2           │ Modul Dashboard (KPI Omzet, Ringkasan, & Alert)    │
│ Tahap 3           │ Modul Pesanan (Fulfillment, Transisi, Input Resi)  │
│ Tahap 4           │ Modul Katalog Produk, Variasi, & Unit Serial       │
│ Tahap 5           │ Penyelarasan Mobile & Pengujian Integrasi Penuh    │
└───────────────────┴────────────────────────────────────────────────────┘
```

---

### TAHAP 1: Fondasi Routing & Shell Layout Blade
1. **Routing Web**:
   - Daftarkan grup rute `prefix('admin')` di `backend/routes/web.php`.
2. **Layout Induk**:
   - Buat `resources/views/admin/layouts/app.blade.php`:
     - Font Poppins via Google Fonts.
     - Variabel CSS token warna gelap `#0B0B0B`, `#171717`, `#202020`, aksen `#FF6A00`.
     - Layout flex/grid: Sidebar kiri 250px + Topbar atas 64px + Container konten.
   - Buat `resources/views/admin/layouts/sidebar.blade.php` (Navigasi: Dashboard, Pesanan, Produk, Unit Serial).
   - Buat `resources/views/admin/layouts/topbar.blade.php` (Breadcrumb, jam real-time, badge role Admin).
3. **Verifikasi**: Buka browser `http://127.0.0.1:8000/admin` tampil kerangka dashboard gelap yang rapi.

---

### TAHAP 2: Modul Dashboard (KPIs, Charts, & Low Stock Alert)
1. **Controller**:
   - Buat `app/Http/Controllers/Admin/DashboardController.php`.
   - Mengambil data agregat dari model Eloquent:
     - `totalOmzet`: Jumlah nominal pesanan lunas/selesai.
     - `pesananPerluProses`: Pesanan berstatus `menunggu_pembayaran` dan `menunggu_konfirmasi`.
     - `totalProduk`: Jumlah produk aktif.
     - `stokKritis`: Daftar produk dengan total stok < 3 unit.
2. **View**:
   - Buat `resources/views/admin/dashboard/index.blade.php`:
     - 4 Kartu Metrik KPI utama.
     - Tabel 5 pesanan masuk paling baru dengan badge status berwarna.
     - Panel peringatan stok menipis dengan tombol aksi re-stock.
3. **Verifikasi**: Buka `/admin/dashboard`, angka omzet dan kuota stok terisi akurat sesuai isi database.

---

### TAHAP 3: Modul Manajemen Pesanan & Pemrosesan Status (Fulfillment)
1. **Controller**:
   - Buat `app/Http/Controllers/Admin/PesananController.php`:
     - `index()`: Menampilkan semua pesanan dengan filter status (Tabs: Semua, Perlu Konfirmasi, Diproses, Dikirim, Selesai).
     - `show($id)`: Rincian pesanan lengkap, daftar unit fisik serial number, alamat pengiriman, dan estimasi kurir.
     - `ubahStatus($id, $statusBaru)`: Memanggil `ServisPesanan::ubahStatus()` untuk validasi transisi sah dan rollback unit jika dibatalkan.
     - `inputResi($id)`: Menyimpan nomor resi kurir dan memajukan status ke `dikirim`.
2. **View**:
   - `resources/views/admin/pesanan/index.blade.php`: Tabel pesanan interaktif.
   - `resources/views/admin/pesanan/show.blade.php`: Halaman rincian pesanan dengan tombol aksi status yang kontekstual:
     - *"Konfirmasi Pembayaran"* (dari `menunggu_konfirmasi` ke `dibayar`).
     - *"Kemas & Siapkan"* (dari `dibayar` ke `diproses`).
     - *"Input Resi & Kirim"* (membuka modal input resi lalu berpindah ke `dikirim`).
     - *"Batalkan Pesanan"* (dialog konfirmasi + auto rollback stok).
3. **Verifikasi**: Admin memproses status pesanan di web, pembeli di mobile melihat perubahan status secara instan!

---

### TAHAP 4: Modul Manajemen Produk, Varian, & Unit Serial Gudang
1. **Controller**:
   - Buat `app/Http/Controllers/Admin/ProdukController.php`:
     - CRUD produk lengkap dengan upload/pilihan gambar dan spesifikasi per kategori.
     - Dukungan pembuatan varian multi-SKU (RAM, SSD, Warna) di form produk.
   - Buat `app/Http/Controllers/Admin/UnitProdukController.php`:
     - Melihat status fisik seluruh unit serial number (`ZNV-P...`).
2. **View**:
   - `resources/views/admin/produk/index.blade.php`: Tabel katalog, harga, kategori, dan tombol edit/hapus.
   - `resources/views/admin/produk/create.blade.php` & `edit.blade.php`: Form modern dengan dynamic variant rows.
   - `resources/views/admin/unit/index.blade.php`: Gudang unit serial number.
3. **Verifikasi**: Menambah atau mengedit produk di web admin langsung memperbarui katalog di aplikasi mobile.

---

### TAHAP 5: Penyelarasan Mobile Client & Pengujian Mutu
1. **Penyelarasan Role di Mobile**:
   - Di mobile (`rincian_pesanan_page.dart`): Pastikan pembeli hanya melihat status pesanan dan rincian serial number (read-only), tidak ada tombol ubah status admin di mobile.
2. **Pengecekan Mutu (Quality Gates)**:
   - `php artisan route:list --path=api` -> Tepat 15 rute API (tidak ada kebocoran rute).
   - `vendor/bin/pint --dirty --format agent` -> Semua berkas PHP rapi sesuai PSR-12 / Pint.
   - `cd mobile && dart analyze` -> 0 issue pada Flutter.
   - Jalankan seluruh tes integrasi `flutter test test/uji_*.dart`.
3. **Git Version Control**:
   - Commit perubahan dengan format Conventional Commits dan push ke GitHub repository.
