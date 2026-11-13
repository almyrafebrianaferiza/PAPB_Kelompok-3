# 04 — Spesifikasi UI Blade & Sistem Desain Web Admin

> Spesifikasi teknis antarmuka Laravel Blade berdasarkan dokumen acuan `desain-admin.md` untuk Seller Dashboard Zenvorā.

---

## 1. Desain Token & Palet Warna Resmi

Seluruh antarmuka Blade mengadopsi token warna dari `desain-admin.md` Bagian 2:

```css
:root {
  /* Latar Belakang & Permukaan */
  --bg-primary: #0B0B0B;          /* Latar utama dashboard */
  --surface-sidebar: #171717;     /* Panel samping (sidebar) & topbar */
  --surface-elevated: #202020;    /* Kartu KPI, baris tabel, modal */
  --border-dark: #333333;         /* Garis pembatas komponen */

  /* Aksen Utama Zenvora */
  --accent-orange: #FF6A00;       /* Tombol utama, menu aktif, highlight */
  --accent-hover: #E85D00;        /* Efek hover tombol */

  /* Tipografi */
  --text-primary: #FFFFFF;        /* Teks utama, judul, angka metrik */
  --text-secondary: #B8B8B8;      /* Label kolom, deskripsi, metadata */
  --text-muted: #737373;          /* Placeholder & keterangan footer */

  /* Status Bisnis */
  --status-success: #36B37E;      /* Pesanan selesai, stok aman */
  --status-warning: #F5B942;      /* Menunggu konfirmasi, stok kritis */
  --status-danger: #E5484D;       /* Dibatalkan, stok habis */
  --status-info: #3B82F6;         /* Sedang dikirim, informasi */
}
```

### Tipografi:
- **Font Family**: `'Poppins', sans-serif` (diimpor via Google Fonts CDN).
- **Heading 1**: 24–28 px, Weight 600 (SemiBold).
- **Heading 2 / Card Title**: 16–18 px, Weight 600.
- **Body Data**: 13–14 px, Weight 400 (Regular) / 500 (Medium).
- **Angka Metrik**: 20–24 px, Weight 700 (Bold).

---

## 2. Tata Letak Dashboard Desktop (3 Area)

Berdasarkan `desain-admin.md` Bagian 3, tata letak layar terbagi menjadi:

```
┌─────────────────┬────────────────────────────────────────────────────────┐
│   LOGO ZENVORA  │ Topbar: Judul Halaman  |  Tanggal  |  Badge Admin Toko │
├─────────────────┼────────────────────────────────────────────────────────┤
│ • Dashboard     │ Main Content Area:                                     │
│ • Pesanan (Live)│                                                        │
│ • Produk (CRUD) │ [ Kartu KPI 1 ] [ Kartu KPI 2 ] [ Kartu KPI 3 ]        │
│ • Varian & Stok │                                                        │
│ • Unit Serial   │ [ Tabel Data Utama / Konten Interaktif ]               │
│ • Pengaturan    │                                                        │
│                 │                                                        │
│ Sidebar (250px) │                                                        │
└─────────────────┴────────────────────────────────────────────────────────┘
```

1. **Sidebar Kiri (Lebar tetap 250 px)**:
   - Header: Logo resmi Zenvorā dengan aksen oranye.
   - Navigasi:
     - `Dashboard`: Ringkasan omzet, pesanan aktif, & produk.
     - `Pesanan Masuk`: Daftar pesanan, filter status, konfirmasi bayar, & input resi.
     - `Katalog Produk`: Daftar produk, stok, harga, & manajemen varian.
     - `Unit & Serial Number`: Gudang fisik dan pencarian IMEI/SN.
   - Menu aktif ditandai dengan latar belakang `#25180E`, teks putih tebal, dan garis aksen oranye di tepi kiri (`border-l-4 border-[#FF6A00]`).
2. **Topbar Atas (Tinggi 64 px)**:
   - Breadcrumb penunjuk lokasi halaman.
   - Indikator status server aktif (`Backend Online :8000`).
   - Profil Admin Toko (*"Administrator Zenvorā"*).
3. **Main Content**:
   - Area konten utama dengan scroll vertikal mandiri.
   - Menggunakan padding standar 24 px dengan latar belakang `#0B0B0B`.

---

## 3. Struktur Berkas Template Blade

Semua berkas Blade ditempatkan di bawah folder `backend/resources/views/admin/`:

```text
backend/resources/views/admin/
├── layouts/
│   ├── app.blade.php           # Template induk (HTML shell, font Poppins, layout grid)
│   ├── sidebar.blade.php       # Navigasi panel samping
│   └── topbar.blade.php        # Header atas & profil
├── dashboard/
│   └── index.blade.php         # Kartu KPI, grafik status, pesanan terkini, stok menipis
├── pesanan/
│   ├── index.blade.php         # Tabel pesanan lengkap dengan tab filter status
│   └── show.blade.php          # Rincian pesanan, serial number fisik, aksi status, modal resi
├── produk/
│   ├── index.blade.php         # Tabel katalog produk, status stok, tombol CRUD
│   ├── create.blade.php        # Form tambah produk baru + spesifikasi per kategori
│   └── edit.blade.php          # Form ubah produk & manajemen varian RAM/SSD
└── unit/
    └── index.blade.php         # Tabel monitoring serial number fisik (IMEI/SN)
```

---

## 4. Komponen UI Mandiri (Reusable)

1. **Kartu KPI (Stat Card)**:
   - Wadah berbentuk kotak surface `#202020` dengan radius 14 px dan border tipis `#333333`.
   - Menampilkan ikon berlatar lingkaran transparan, label kecil, angka nilai nominal yang kontras, dan keterangan status.
2. **Tabel Data Gelap (Dark Data Table)**:
   - Header tabel menggunakan warna `#171717` dengan teks uppercase huruf kecil 12 px abu-abu terang.
   - Baris tabel berlatar `#202020` dengan efek hover halus `#282828`.
3. **Pill Status Badge**:
   - Badge oval kecil dengan teks tebal 11 px.
   - Warna menyesuaikan status:
     - `menunggu_pembayaran` / `menunggu_konfirmasi`: Latar kuning transparan, teks `#F5B942`.
     - `dibayar` / `diproses`: Latar biru transparan, teks `#3B82F6`.
     - `dikirim`: Latar cyan transparan, teks `#06B6D4`.
     - `selesai`: Latar hijau transparan, teks `#36B37E`.
     - `dibatalkan`: Latar merah transparan, teks `#E5484D`.
4. **Tombol Aksi**:
   - Tombol Utama: Oranye `#FF6A00`, teks hitam tebal `#000000`, radius 8 px.
   - Tombol Sekunder: Latar transparan dengan outline border `#444444`, teks putih `#FFFFFF`.
