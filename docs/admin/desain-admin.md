# Zenvora — Seller Dashboard Design Specification

> Dokumen panduan desain UI/UX untuk sisi penjual (seller) pada platform e-commerce Zenvora, toko elektronik dan gawai.

## 1. Ringkasan Produk

**Zenvora** adalah platform e-commerce yang berfokus pada produk elektronik dan gawai. Seller Dashboard merupakan area khusus penjual untuk mengelola aktivitas toko, mulai dari memantau performa, mengelola katalog produk, memproses pesanan, hingga mengatur profil toko.

### Tujuan utama
- Membantu penjual memahami kondisi dan performa toko dengan cepat.
- Mempermudah pengelolaan produk, stok, harga, dan variasi.
- Menyediakan alur pemrosesan pesanan yang jelas.
- Menampilkan informasi penting tanpa membuat dashboard terasa penuh.
- Menjaga konsistensi visual dengan halaman pembeli Zenvora.

### Target pengguna
Penjual individu, toko elektronik, dan pemilik usaha yang menjual smartphone, laptop, televisi, monitor, aksesori, serta perangkat elektronik lainnya.

## 2. Arah Visual dan Identitas

### Karakter desain
- Modern dan profesional.
- Minimalis, rapi, dan mudah dipindai.
- Kesan premium yang sesuai dengan produk teknologi.
- Mengutamakan keterbacaan dan efisiensi kerja.
- Menggunakan aksen orange untuk aksi utama dan informasi penting.

### Palet warna

| Token | Warna | Hex | Penggunaan |
|---|---|---|---|
| Primary Background | Hitam pekat | `#0B0B0B` | Latar utama aplikasi |
| Surface | Hitam keabu-abuan | `#171717` | Sidebar, navbar, dan panel |
| Surface Elevated | Abu gelap | `#202020` | Card, tabel, dan dropdown |
| Primary Accent | Orange Zenvora | `#FF6A00` | Tombol utama, navigasi aktif, highlight |
| Accent Hover | Orange gelap | `#E85D00` | Kondisi hover tombol |
| Text Primary | Putih | `#FFFFFF` | Judul dan teks utama |
| Text Secondary | Abu terang | `#B8B8B8` | Deskripsi dan metadata |
| Border | Abu gelap | `#333333` | Garis pembatas dan outline |
| Success | Hijau | `#36B37E` | Pesanan selesai dan stok tersedia |
| Warning | Kuning | `#F5B942` | Stok menipis dan perlu perhatian |
| Danger | Merah | `#E5484D` | Pesanan dibatalkan atau stok habis |

**Aturan penggunaan warna**
- Gunakan orange secara selektif agar tombol dan status penting mudah ditemukan.
- Jangan menggunakan orange sebagai warna latar untuk seluruh card.
- Pastikan teks tetap memiliki kontras yang cukup dengan latarnya.
- Status tidak boleh dibedakan berdasarkan warna saja; sertakan label teks atau ikon.

### Tipografi
- **Font utama:** Poppins.
- **Heading halaman:** Poppins SemiBold, 24–28 px.
- **Judul card:** Poppins SemiBold, 16–18 px.
- **Body:** Poppins Regular, 14 px.
- **Label dan metadata:** Poppins Regular/Medium, 12–13 px.
- **Tombol:** Poppins Medium, 14 px.

Gunakan hierarki tipografi yang konsisten. Hindari terlalu banyak variasi ukuran dan ketebalan font.

### Bentuk dan komponen
- Radius card: 12–16 px.
- Radius tombol dan input: 8–10 px.
- Border tipis `#333333`.
- Shadow sangat halus; pisahkan elemen terutama melalui perbedaan warna surface.
- Ikon menggunakan gaya outline yang konsisten.
- Gunakan jarak berbasis kelipatan 4 atau 8 px.

## 3. Struktur Navigasi

### Layout utama desktop

Gunakan layout dashboard dengan tiga area:

1. **Sidebar kiri** — navigasi utama dan identitas toko.
2. **Topbar** — breadcrumb/judul halaman, pencarian bila diperlukan, notifikasi, dan profil akun.
3. **Main content** — konten sesuai halaman yang sedang dibuka.

Sidebar disarankan memiliki lebar sekitar 240–260 px dan dapat diciutkan menjadi ikon saja. Pada layar kecil, sidebar berubah menjadi drawer atau navigasi mobile.

### Menu sidebar

| Menu | Fungsi |
|---|---|
| Dashboard | Ringkasan performa dan aktivitas toko |
| Produk | Melihat, menambah, dan mengedit produk |
| Kategori | Mengelola kategori produk toko |
| Pesanan | Melihat dan memproses pesanan pembeli |
| Pengiriman | Memantau status pengiriman dan informasi resi |
| Ulasan | Melihat penilaian dan ulasan pembeli |
| Promosi | Mengelola diskon dan promo toko |
| Analitik | Melihat laporan penjualan dan performa |
| Pengaturan Toko | Mengatur profil, alamat, dan informasi toko |
| Bantuan | Panduan dan pusat bantuan |

Menu yang sedang aktif menggunakan aksen orange pada ikon, teks, atau indikator di sisi kiri. Hindari memberikan latar orange yang terlalu dominan pada seluruh sidebar.

## 4. Spesifikasi Halaman

### 4.1 Dashboard

**Tujuan:** Memberikan gambaran kondisi toko dalam sekali lihat.

**Susunan konten:**
- Sapaan: `Selamat datang, [Nama Penjual]`.
- Informasi toko aktif dan tanggal/periode laporan.
- Kartu ringkasan:
  - Total Penjualan.
  - Total Pesanan.
  - Produk Aktif.
  - Pesanan Perlu Diproses.
- Grafik penjualan berdasarkan periode.
- Ringkasan status pesanan.
- Produk terlaris.
- Aktivitas terbaru.

**Perilaku:**
- Periode grafik dapat diganti, misalnya 7 hari, 30 hari, atau 12 bulan.
- Kartu ringkasan dapat diklik untuk membuka halaman terkait.
- Tampilkan empty state yang informatif ketika toko belum memiliki transaksi.

### 4.2 Manajemen Produk

**Tujuan:** Memudahkan penjual mengelola katalog barang elektronik.

**Bagian halaman:**
- Judul `Produk Saya`.
- Tombol utama `+ Tambah Produk`.
- Pencarian berdasarkan nama produk atau SKU.
- Filter kategori dan status produk.
- Tabel atau daftar produk.

**Kolom tabel yang disarankan:**
- Foto produk.
- Nama produk dan SKU.
- Kategori.
- Harga.
- Stok.
- Status.
- Terakhir diperbarui.
- Aksi.

**Aksi produk:**
- Lihat detail.
- Edit produk.
- Ubah status aktif/nonaktif.
- Hapus produk dengan dialog konfirmasi.

**Status produk:**
- Aktif.
- Draft.
- Stok habis.
- Ditinjau (jika platform menerapkan moderasi).

### 4.3 Tambah dan Edit Produk

Form dibuat dalam beberapa kelompok agar mudah dipahami.

**A. Informasi dasar**
- Nama produk.
- Kategori dan subkategori.
- Merek.
- SKU/kode produk.
- Deskripsi produk.

**B. Media produk**
- Upload foto utama.
- Upload foto tambahan.
- Preview gambar.
- Panduan rasio dan ukuran gambar.
- Tombol untuk menghapus atau mengganti gambar.

**C. Harga dan stok**
- Harga jual.
- Harga sebelum diskon (opsional).
- Jumlah stok.
- Berat produk.
- SKU variasi jika tersedia.

**D. Spesifikasi dan variasi**
- Warna.
- Kapasitas penyimpanan.
- RAM.
- Ukuran layar.
- Garansi.
- Kondisi barang.
- Tambahkan atribut sesuai kategori produk.

**E. Pengaturan publikasi**
- Simpan sebagai draft.
- Pratinjau.
- Terbitkan produk.

Field spesifikasi sebaiknya dinamis berdasarkan kategori. Contohnya, laptop menampilkan RAM, prosesor, dan penyimpanan, sedangkan smartphone menampilkan RAM, kapasitas, dan ukuran layar.

### 4.4 Manajemen Pesanan

**Tujuan:** Membantu penjual memproses pesanan secara terstruktur.

**Bagian halaman:**
- Ringkasan jumlah pesanan berdasarkan status.
- Pencarian nomor pesanan atau nama pembeli.
- Filter tanggal dan status.
- Tabel daftar pesanan.

**Kolom tabel:**
- Nomor pesanan.
- Tanggal pesanan.
- Nama pembeli.
- Ringkasan produk.
- Total pembayaran.
- Status pesanan.
- Aksi.

**Alur status pesanan:**
1. Menunggu pembayaran.
2. Perlu diproses.
3. Dikemas.
4. Dalam pengiriman.
5. Selesai.
6. Dibatalkan atau dikembalikan (sesuai kebijakan platform).

Tampilkan tombol tindakan sesuai status. Contohnya, pesanan yang sudah dibayar dapat memiliki aksi `Proses Pesanan`, sedangkan pesanan yang siap dikirim memiliki aksi `Input Resi` atau `Atur Pengiriman`.

### 4.5 Detail Pesanan

Tampilkan informasi berikut:
- Nomor dan tanggal pesanan.
- Status pembayaran dan pesanan.
- Data penerima dan alamat pengiriman.
- Daftar produk, variasi, jumlah, dan harga.
- Rincian subtotal, ongkir, diskon, dan total.
- Metode pengiriman.
- Nomor resi jika tersedia.
- Riwayat perubahan status.

Aksi harus kontekstual dan disertai konfirmasi untuk tindakan penting.

### 4.6 Pengiriman

**Tujuan:** Memudahkan penjual memantau pesanan yang perlu dikirim.

**Konten:**
- Daftar pesanan siap dikirim.
- Kurir atau metode pengiriman.
- Batas waktu pengiriman jika tersedia.
- Nomor resi.
- Status pengiriman.
- Aksi untuk memasukkan atau memperbarui resi.

Jangan menampilkan status pengiriman yang belum dikonfirmasi oleh layanan pengiriman.

### 4.7 Ulasan

**Konten:**
- Rating rata-rata toko atau produk.
- Distribusi rating bintang.
- Daftar ulasan pembeli.
- Filter berdasarkan rating dan produk.
- Foto atau video ulasan jika tersedia.
- Fitur balas ulasan.

Gunakan bahasa yang sopan dan profesional pada fitur balasan.

### 4.8 Promosi

**Konten:**
- Daftar promo aktif dan berakhir.
- Nama promo.
- Jenis diskon.
- Periode promo.
- Produk yang mengikuti promo.
- Status promo.

**Aksi:** Buat promo, edit, aktifkan/nonaktifkan, dan lihat detail. Berikan validasi untuk periode dan batas diskon.

### 4.9 Analitik

**Konten:**
- Total penjualan.
- Jumlah pesanan.
- Rata-rata nilai transaksi.
- Produk paling banyak terjual.
- Grafik tren penjualan.
- Perbandingan periode.

Sediakan filter rentang tanggal. Jelaskan definisi metrik dan sumber datanya agar tidak menimbulkan salah tafsir.

### 4.10 Pengaturan Toko

**Informasi yang dapat diatur:**
- Logo dan banner toko.
- Nama toko.
- Deskripsi toko.
- Alamat toko/gudang.
- Kontak layanan pelanggan.
- Jam operasional.
- Kebijakan pengiriman dan pengembalian.
- Informasi akun penjual.

Sediakan tombol `Simpan Perubahan` dan indikator keberhasilan atau kegagalan penyimpanan.

## 5. Komponen UI yang Dapat Digunakan Ulang

| Komponen | Keterangan |
|---|---|
| Sidebar | Navigasi utama seller |
| Topbar | Judul halaman, notifikasi, dan profil |
| Stat Card | Ringkasan angka penting |
| Data Table | Daftar produk dan pesanan |
| Search Input | Pencarian data |
| Filter Dropdown | Filter kategori, tanggal, dan status |
| Status Badge | Penanda status dengan teks |
| Primary Button | Aksi utama berwarna orange |
| Secondary Button | Aksi alternatif dengan outline |
| Form Input | Input teks, angka, dan tanggal |
| Image Uploader | Upload dan preview gambar |
| Confirmation Dialog | Konfirmasi tindakan penting |
| Empty State | Tampilan ketika belum ada data |
| Pagination | Navigasi halaman data |
| Toast/Alert | Informasi keberhasilan atau kesalahan |

### Aturan tombol
- **Primary:** orange dengan teks hitam atau putih sesuai hasil uji kontras.
- **Secondary:** transparan/abu gelap dengan border.
- **Danger:** merah untuk tindakan destruktif.
- **Disabled:** kontras tetap terbaca, tetapi jelas tidak dapat digunakan.
- Setiap tombol harus memiliki label aksi yang spesifik.

## 6. Responsivitas

### Desktop (≥ 1024 px)
- Sidebar tetap terlihat.
- Konten menggunakan lebar ruang yang tersedia.
- Tabel menampilkan kolom penting secara lengkap.
- Form tambah/edit produk dapat menggunakan beberapa kolom jika ruang mencukupi.

### Tablet (768–1023 px)
- Sidebar dapat diciutkan.
- Kartu statistik menggunakan grid dua kolom.
- Tabel dapat digeser horizontal atau diubah menjadi daftar ringkas.

### Mobile (< 768 px)
- Navigasi menggunakan drawer atau menu yang mudah dijangkau.
- Kartu statistik satu atau dua kolom sesuai lebar.
- Tabel berubah menjadi card/list.
- Form menggunakan satu kolom.
- Tombol aksi utama mudah ditemukan dan memiliki area sentuh yang memadai.

## 7. Interaksi, Feedback, dan State

Setiap halaman perlu memiliki empat kondisi dasar:

1. **Loading:** tampilkan skeleton atau indikator proses.
2. **Success:** tampilkan notifikasi singkat setelah aksi berhasil.
3. **Error:** jelaskan masalah dan cara memperbaikinya.
4. **Empty:** jelaskan bahwa data belum tersedia dan berikan aksi berikutnya.

### Validasi
- Tandai field wajib.
- Tampilkan pesan kesalahan di dekat field terkait.
- Pertahankan input pengguna ketika validasi gagal.
- Cegah pengiriman form berulang saat proses berlangsung.
- Gunakan dialog konfirmasi untuk penghapusan dan tindakan yang sulit dibatalkan.

### Aksesibilitas
- Jaga kontras teks dan latar.
- Jangan mengandalkan warna saja untuk menyampaikan status.
- Berikan label pada seluruh input.
- Gunakan ukuran teks yang nyaman dibaca.
- Pastikan navigasi dapat digunakan dengan keyboard.
- Berikan focus state yang terlihat.
- Gunakan ikon bersama teks untuk aksi penting.

## 8. Struktur Halaman dan Rekomendasi Implementasi

Contoh struktur route (dapat disesuaikan dengan framework):

```text
/seller
/seller/dashboard
/seller/products
/seller/products/create
/seller/products/:id
/seller/products/:id/edit
/seller/categories
/seller/orders
/seller/orders/:id
/seller/shipping
/seller/reviews
/seller/promotions
/seller/analytics
/seller/settings
/seller/help
```

### Prioritas pengembangan

**Prioritas 1 — Fitur inti**
- Dashboard.
- Manajemen produk.
- Tambah/edit produk.
- Manajemen pesanan.
- Detail pesanan.

**Prioritas 2 — Operasional toko**
- Pengiriman.
- Ulasan.
- Pengaturan toko.

**Prioritas 3 — Pengembangan lanjutan**
- Promosi.
- Analitik lanjutan.
- Laporan dan ekspor data.

## 9. Prinsip Akhir Desain

1. Informasi terpenting harus terlihat tanpa pengguna perlu mencari terlalu jauh.
2. Satu halaman memiliki satu tujuan utama yang jelas.
3. Gunakan pola komponen dan jarak yang konsisten.
4. Aksi utama menggunakan orange, sedangkan elemen pendukung tetap netral.
5. Hindari tabel yang terlalu padat; prioritaskan informasi yang dibutuhkan untuk mengambil tindakan.
6. Pastikan semua status, angka, dan notifikasi berasal dari data yang valid.
7. Pertahankan identitas Zenvora: hitam, orange, putih, dan tipografi Poppins.

---

**Catatan:** Dokumen ini merupakan spesifikasi awal desain UI/UX. Detail seperti alur pembayaran, integrasi kurir, moderasi produk, hak akses, dan kebijakan retur perlu disesuaikan dengan kebutuhan backend serta aturan bisnis Zenvora.
