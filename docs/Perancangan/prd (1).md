# PRD — Zenvora: Aplikasi Toko Online Elektronik dan Gawai

> Tugas Pengganti UTS (berkelompok) — Pemrograman Aplikasi Perangkat Bergerak (2010MWP0507) dan Sistem Terdistribusi
> Domain bisnis: **No. 3 — Elektronik dan gawai**
> Status dokumen: draf 1 · Tenggat pengumpulan internal: **9 November 2026** (Senin)

---

## 1. Ringkasan

Zenvora adalah toko online elektronik dengan fokus awal pada kategori **gadget, laptop, TV, monitor, dan tablet**. Sistem terdiri atas dua bagian:

- **Backend**: REST API Laravel di atas MySQL. Server adalah satu-satunya sumber kebenaran (harga, subtotal, ongkir, total, stok, status).
- **Mobile**: aplikasi Flutter yang hanya menampilkan data dan mengirim permintaan.

Alur utama: **katalog → rincian produk → keranjang → checkout → rincian pesanan → riwayat**, ditambah halaman kelola produk (CRUD).

## 2. Tujuan dan Ukuran Keberhasilan

| # | Tujuan | Ukuran keberhasilan |
|---|--------|---------------------|
| T1 | Alur belanja utuh dari katalog sampai pesanan tersimpan | Seluruh 7 halaman wajib berjalan di emulator dan HP |
| T2 | Data konsisten di bawah kegagalan | Checkout gagal tidak mengubah stok; klik ganda atau retry hanya membuat satu pesanan; dua pembeli unit terakhir tidak membuat stok minus |
| T3 | Kontrak API disiplin | 14 endpoint wajib ada, pembungkus respons seragam, dokumentasi cocok dengan perilaku nyata |
| T4 | Aplikasi tahan gangguan | 5 jenis galat tampil berbeda dan terbukti di video |
| T5 | Siap uji petik Pertemuan 8 | Setiap anggota bisa menjelaskan seluruh kode (Kriteria 9, per mahasiswa) |
| T6 | Pengumpulan lengkap dan tepat waktu | Daftar periksa Bagian 11 dokumen tugas tercentang seluruhnya |

## 3. Ruang Lingkup

### Dalam lingkup
- Katalog produk dengan filter kategori dan pencarian yang dikerjakan server, plus **lazy load** (nilai tambah).
- CRUD produk dari dalam aplikasi.
- Keranjang yang tersimpan di server.
- Checkout dengan hitung ongkir berbasis berat, pembayaran simulasi, dan pelacakan status pesanan.
- Nomor seri per unit produk dan garansi yang tampil di pesanan.
- Idempotensi checkout, transaksi basis data, dan penanganan galat.

### Di luar lingkup (dilarang atau belum diajarkan)
- Payment gateway (Midtrans, Xendit, Stripe) dan API ekspedisi (RajaOngkir, JNE, SiCepat).
- Login penuh (JWT atau OAuth 2.0), baru pada Pertemuan 14.
- Provider atau pustaka manajemen state; yang dipakai `setState`, constructor, dan callback.
- Kategori aksesoris dan "printilan": ditunda, ditambah belakangan jika sempat.

## 4. Pengguna dan Identitas

Belum ada autentikasi. Dua peran disederhanakan:

| Peran | Wujud | Kegunaan |
|-------|-------|----------|
| Pembeli | `pelanggan_id` tetap (usulan: `1`) | Memiliki keranjang dan riwayat pesanan |
| Admin toko | Tanpa login, halaman "Kelola produk" terbuka | CRUD produk; konfirmasi pembayaran lewat `PATCH /api/pesanan/{id}/status` |

Pengiriman identitas (usulan: header `Authorization: Bearer <token-statis>` yang dipetakan server ke pelanggan 1) **hanya di satu tempat** di `LayananApi`, supaya penggantian ke JWT di Pertemuan 14 cukup satu berkas.

## 5. Katalog Awal (Domain Zenvora)

Kategori awal: **Gadget, Laptop, TV, Monitor, Tablet**.

Kebutuhan data awal (seeder, wajib berhasil dalam sekali `php artisan migrate --seed`):

- Sekurang-kurangnya **12 produk** tersebar di minimal 2 kategori (target: 15 produk, 3 per kategori).
- Sekurang-kurangnya **2 produk berstok nol** atau `tersedia = false`.
- **3 kurir/wilayah antar** dengan tarif per kg berbeda.
- **2 metode pembayaran**: `tunai_di_tempat` dan `transfer_manual`.
- **3 pesanan contoh** dengan status berbeda.
- Unit bernomor seri untuk setiap produk yang berstok.

## 6. Kebutuhan Fungsional

### 6.1 Halaman Flutter (7 halaman wajib)

| Halaman | Isi wajib | Catatan Zenvora |
|---------|-----------|-----------------|
| Katalog | Daftar produk dari `GET /api/produk`, filter kategori, pencarian nama, penanda habis, ikon keranjang dengan lencana | `GridView.builder` atau `ListView.builder` + lazy load |
| Rincian produk | Semua atribut, termasuk `berat_gram`, `garansi_bulan`, pemilih jumlah, tombol tambah | Tombol dimatikan bila habis |
| Keranjang | Daftar item, ubah jumlah, hapus, subtotal dari server | Keadaan kosong yang ramah |
| Checkout | Form nama dan alamat, pilih kurir dari `GET /api/kurir`, pilih metode bayar, ringkasan subtotal + ongkir | Ongkir berubah saat kurir diganti, nilainya dari server |
| Rincian pesanan | Nomor pesanan, status, item dengan harga saat beli, total, metode bayar, tombol bayar simulasi | Tampilkan garansi dan nomor seri tiap unit |
| Riwayat pesanan | Daftar terbaru ke terlama beserta status | |
| Kelola produk | Daftar + tambah, ubah, hapus | Konfirmasi dialog sebelum hapus |

### 6.2 Empat keadaan layar (setiap halaman pemanggil API)

`enum KeadaanMuat { memuat, berhasil, kosong, galat }` — **kosong tidak boleh ditampilkan sebagai galat**.

### 6.3 Penanganan galat (5 jenis, tampilan berbeda)

| Galat | Pemicu | Tampilan |
|-------|--------|----------|
| Tidak ada sambungan | Server mati / mode pesawat | Pesan sambungan gagal + tombol coba lagi |
| Batas waktu | Jaringan lambat / `.timeout` | Pesan server tidak membalas + tombol coba lagi |
| 422 | Kolom kosong atau tidak valid | Pesan per kolom di bawah kolom |
| 409 | Stok kurang, status tidak sah | Pesan dari server di layar yang sama, tanpa pindah halaman |
| 500 | Galat server | Pesan umum + coba lagi, tanpa jejak galat |

Dilarang: menampilkan `e.toString()`, `catch` kosong, atau satu pesan untuk semua jenis galat.

## 7. Aturan Bisnis Khas Domain (Elektronik dan Gawai)

### 7.1 Ongkir dari total berat (aturan yang ditegakkan di checkout)

```
total_berat_gram = Σ (berat_gram produk × jumlah)
berat_kg         = ceil(total_berat_gram / 1000)      // dibulatkan ke atas per kg
ongkir           = berat_kg × tarif_per_kg(kurir/wilayah terpilih)
total_pesanan    = subtotal + ongkir
```

- Seluruhnya dihitung **di server**; Flutter hanya menampilkan.
- Tanpa batas berat maksimum.
- Contoh: 1 laptop 1.800 g + 1 tablet 480 g = 2.280 g → 3 kg → ongkir = 3 × tarif.
- Kurir tidak valid atau keranjang kosong ditolak dengan 422.

### 7.2 Nomor seri per unit

- Setiap unit fisik produk punya baris di tabel unit dengan `nomor_seri` unik dan `status` (`tersedia`, `terjual`).
- **Stok = jumlah unit berstatus `tersedia`.** Kolom `stok` pada produk tetap ada (ketentuan 7 kolom wajib) dan harus selalu sama dengan jumlah unit tersedia; hanya diubah di dalam transaksi bersama perubahan status unit.
- Saat checkout, server mengunci dan memilih N unit tersedia per item, mengubah statusnya, dan menautkan `nomor_seri` ke detail pesanan.

### 7.3 Garansi

- `garansi_bulan` disalin ke detail pesanan bersama harga saat pembelian, jadi pesanan lama tidak berubah bila produk diedit.
- Rincian pesanan menampilkan garansi dan nomor seri setiap unit.

## 8. Model Data (tingkat PRD)

Detail kolom dan relasi ada di `database-schema.md`. Entitas inti:

`produk` · `unit_produk` (nomor seri) · `keranjang` (item) · `kurir` · `pesanan` · `detail_pesanan` · `pelanggan`

Kolom produk (7 wajib + khas domain):

| Kolom | Tipe | Catatan |
|-------|------|---------|
| id | int | |
| nama | string | |
| harga | int | Rupiah bulat |
| kategori | string | gadget, laptop, tv, monitor, tablet |
| stok | int | = jumlah unit tersedia |
| tersedia | bool | Terpisah dari stok |
| deskripsi | string / null | Flutter wajib menangani null |
| **berat_gram** | int | Khas domain |
| **garansi_bulan** | int | Khas domain |
| merek (opsional) | string | Penunjang tampilan |

## 9. Kontrak API (ringkas)

Detail di `api-contract.md`. 14 endpoint wajib:

| Metode dan jalur | Kode utama |
|------------------|-----------|
| GET `/api/produk` (`?kategori=`, `?cari=`, paginasi lazy load) | 200 (tetap 200 saat kosong) |
| GET `/api/produk/{id}` | 200, 404 |
| POST `/api/produk` | 201, 422 |
| PUT `/api/produk/{id}` | 200, 404, 422 |
| DELETE `/api/produk/{id}` | 200, 404, 409 (terpakai pesanan aktif) |
| GET `/api/keranjang` | 200 (subtotal dari server) |
| POST `/api/keranjang` | 201/200, 409 (stok kurang), 422 |
| PUT `/api/keranjang/{id}` | 200, 409, 422 (jumlah ≤ 0) |
| DELETE `/api/keranjang/{id}` | 200 |
| GET `/api/kurir` | 200 |
| POST `/api/checkout` (header `X-Kunci-Idempoten`) | 201, 409, 422 |
| GET `/api/pesanan` | 200 (terbaru dulu) |
| GET `/api/pesanan/{id}` | 200, 404 |
| PATCH `/api/pesanan/{id}/status` | 200, 409 (perpindahan tidak sah) |

Pembungkus respons seragam:

```json
{ "status": "sukses", "code": "200", "message": "...", "data": [] }
{ "status": "gagal",  "code": "422", "message": "...", "errors": { "kolom": ["..."] } }
```

**Lazy load:** `GET /api/produk?halaman=1&per_halaman=10`. Akhir daftar dikenali Flutter ketika jumlah item yang kembali kurang dari `per_halaman`, sehingga pembungkus tidak perlu kunci tambahan.

## 10. Status Pesanan dan Pembayaran Simulasi

```
menunggu_pembayaran → menunggu_konfirmasi → dibayar → diproses → dikirim → selesai
dibatalkan: hanya dari 2 status pertama
```

- Perpindahan tidak sah (mis. `selesai` → `diproses`) ditolak server dengan **409**.
- Pembeli menekan "Bayar" → `PATCH` ke `menunggu_konfirmasi`; admin mengonfirmasi → `dibayar`.
- Metode bayar: `tunai_di_tempat` dan `transfer_manual`.

## 11. Kebutuhan Non-Fungsional

1. **Transaksi**: pengurangan stok/unit, penyimpanan pesanan, dan pengosongan keranjang dalam satu transaksi dengan `lockForUpdate`.
2. **Idempotensi**: `X-Kunci-Idempoten` dibuat sekali per percobaan di Flutter, dipakai ulang saat coba lagi; server mengembalikan pesanan yang sama.
3. **Tombol checkout** dimatikan selama permintaan berjalan.
4. **Timeout** pada setiap pemanggilan (contoh 10 detik) dan ditampilkan sebagai galat.
5. Tidak ada pemanggilan jaringan di `build`; seluruh panggilan di satu kelas `LayananApi`.
6. Alamat server dalam satu konstanta (emulator: `http://10.0.2.2:8000/api`).
7. Respons server tidak membocorkan galat basis data mentah atau HTML.
8. Harga, total, ongkir, dan ketersediaan **tidak** dihitung di Dart.

## 12. Lingkungan Pengembangan

| Komponen | Versi |
|----------|-------|
| PHP | 8.3.28 (Laragon) |
| Composer | 2.9.2 |
| Laravel Installer | 5.26.1 (belum ada di PATH; gunakan `composer create-project laravel/laravel backend`) |
| MySQL | 8.0.30 (Laragon) |
| Flutter | 3.44.8 stable (Dart 3.12.2) |
| Alat AI | Claude, Antigravity, opencode |

Pengujian: emulator Android **dan** HP fisik.

Catatan HP fisik: server dijalankan dengan `php artisan serve --host=0.0.0.0`, alamat di Flutter memakai IP LAN laptop (bukan `10.0.2.2`), laptop dan HP satu jaringan, dan HTTP non-HTTPS memerlukan `android:usesCleartextTraffic="true"` pada build debug.

## 13. Keluaran Pengumpulan

1. **Repositori** (`backend/`, `mobile/`, `README.md` dengan 9 butir, seeder, `.env.example`).
2. **Dokumentasi API** PDF 6–10 halaman, nama `PAPB-UTS_Kelompok03_Elektronik.pdf` (koleksi Postman sangat dianjurkan).
3. **Video demo ≤ 5 menit** (termasuk demonstrasi 5 jenis galat, dengan menyebut cara memicunya).

Aturan tambahan: tiap anggota minimal 5 commit bermakna atas namanya; pemakaian AI dicatat di README pada tingkat berkas atau fungsi; tiap anggota harus bisa menjelaskan semua kode.

## 14. Jadwal (Kamis 5 Nov – Senin 9 Nov 2026)

| Hari | Fokus |
|------|-------|
| Kamis malam (5 Nov) | Dokumen perencanaan, setup proyek Laravel dan Flutter |
| Jumat (6 Nov) | Migrasi, seeder, endpoint produk/kurir/keranjang, kerangka Flutter |
| Sabtu (7 Nov) | Checkout transaksional + idempotensi, status pesanan, halaman checkout dan pesanan |
| Minggu (8 Nov) | Penanganan 5 galat, lazy load, uji skenario, Postman, dokumentasi PDF, video |
| Senin (9 Nov) | Perapian README, daftar periksa Bagian 11, pengumpulan di LMS |

Rincian tugas per orang ada di `todo.md`.

## 15. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Waktu sangat singkat (4 hari) | Fitur tidak selesai | Kerjakan berurutan: backend inti dulu, nilai tambah terakhir |
| `stok` dan jumlah unit tidak sinkron | Kriteria 5 turun | Ubah keduanya hanya di dalam transaksi; uji dengan skenario di `testing.md` |
| Kode hasil AI tidak dipahami anggota | Kriteria 9 nol per orang | Review silang; tiap anggota membaca kode anggota lain |
| Satu commit besar di hari terakhir | Kriteria 8 turun | Commit kecil sejak awal; format pesan commit di `conventions.md` |
| Seeder gagal di komputer bersih | Tidak bisa diuji | Uji `migrate --seed` di akhir setiap hari |
| HP fisik tidak terhubung | Demo gagal | Siapkan emulator sebagai cadangan |
| Menghitung di Dart tanpa sadar | Kriteria 5 skor 1 | Tinjau `grep` untuk penjumlahan harga di `mobile/lib` |

## 16. Pertanyaan Terbuka

1. Nama kelompok, anggota, NIM, dan peran (diperlukan untuk README, dilewati dulu).
2. Identitas pelanggan: Bearer token statis atau header `pelanggan_id`.
3. Nama dan tarif 3 kurir/wilayah.
4. Konfirmasi ke dosen tentang **jalur C** (disebut di rubrik Bagian 9, tetapi tidak didefinisikan di Bagian 5).

## 17. Dokumen Pendamping

`database-schema.md` · `api-contract.md` · `architecture.md` · `conventions.md` · `agent.md` · `skill.md` · `workflow.md` · `todo.md` · `testing.md` · `submission.md` · `uji-petik.md`
