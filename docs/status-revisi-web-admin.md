# Status dan Catatan Revisi Web Admin Zenvora

> Dokumen handoff untuk menjaga konteks saat berganti model/anggota.
> Dokumen ini mencatat keadaan kode, keputusan, penyimpangan, dan pekerjaan
> dokumentasi yang masih terbuka. Dokumen ini **bukan pengganti kontrak resmi**
> sampai revisi pada `docs/Perancangan/` benar-benar dilakukan.

| Atribut | Nilai |
|---|---|
| Versi dokumen | 1.0 |
| Tanggal | 2026-11-12 |
| Basis commit | `2c98d91` (branch `main`) |
| Status revisi | Disetujui pada 2026-11-12 |
| Pemilik keputusan | Pengguna proyek |
| Lingkup | Mobile pembeli, Web Admin penjual, backend Laravel, dokumentasi |
| Sifat | Catatan implementasi + addendum draf |

Catatan bukti persetujuan: persetujuan dicatat dari arahan pengguna pada
2026-11-12. Surat/email resmi dosen belum dilampirkan di repositori. Jika ada
bukti tertulis, lampirkan ke dokumen ini agar tidak menimbulkan bias.

---

## 0. Ringkasan eksekutif

- Arah yang dipilih adalah **Opsi A**:
  - **Mobile = pembeli, read-only.**
  - **Web Admin `/admin` = penjual**, memakai sesi web dan CSRF.
  - Web admin berada di `backend/routes/web.php`; **tidak ada rute API baru**.
- Kontrak jumlah endpoint tetap: **15 rute API** dan **16 rute web admin**
  (termasuk login/logout), diverifikasi 2026-11-12.
- Perbaikan Tahap 5 **tidak melanggar jumlah endpoint**, tetapi **mengubah
  perilaku** yang tertulis di PDF tugas, PRD, dan API contract. Perubahan itu
  disetujui sebagai revisi, sehingga dokumen lama wajib diselaraskan.
- Kondisi verifikasi terakhir:
  - `php artisan test`: **25 tes PASS**, 93 assertion.
  - `flutter analyze`: **No issues found**.
  - E1, E5, E7, F1a: **PASS** di Chrome.
  - Audit viewport 360x640: tidak ada overflow.
  - `pint --test`: **belum hijau** pada 7 berkas; lihat Bagian 13.
- Tiga hal yang paling mudah menimbulkan salah paham:
  1. `produk_varian` adalah tabel domain ke-9, bukan bagian dari 8 tabel inti.
  2. Varian sudah tampil dan punya harga/stok sendiri, tetapi keranjang/checkout
     masih memakai produk induk dan **belum mengirim `varian_id`**.
  3. API masih mengizinkan token pembeli memanggil mutasi produk/status;
     pemisahan peran baru ditegakkan di UI mobile, belum di API.

---

## 1. Cara memakai dokumen ini

1. Baca Bagian 2-4 untuk memahami keputusan dan batasan.
2. Baca Bagian 5-6 untuk melihat apa yang sudah dikerjakan dan buktinya.
3. Sebelum mengubah kode, baca Bagian 7-10 dan Bagian 13.
4. Sebelum mengubah dokumen, pakai Bagian 11 sebagai daftar kerja.
5. Jangan menganggap daftar di Bagian 15 sudah selesai; itu backlog.

Label yang dipakai:

- **FAKTA**: diverifikasi dari kode, rute, tes, atau commit.
- **KEPUTUSAN**: arah yang sudah dipilih pengguna.
- **GAP**: belum selesai, berisiko, atau masih bertentangan.
- **RENCANA**: belum dikerjakan.

---

## 2. Keputusan revisi (Opsi A)

### 2.1 Isi keputusan

**KEPUTUSAN:** revisi dosen yang diadopsi adalah pemisahan kanal:

| Kanal | Peran | Wewenang |
|---|---|---|
| Mobile Flutter | Pembeli | Katalog, keranjang, checkout, riwayat, rincian pesanan read-only |
| Web Admin Laravel | Penjual/admin | Dashboard, pesanan, transisi status, resi, katalog, varian, unit serial |

Konsekuensi yang diterima:

- Tombol **Bayar simulasi** di mobile dihapus.
- CRUD produk dari dalam aplikasi mobile dihapus.
- Panel admin mobile dihapus.
- Aksi penjual dipindahkan ke web admin.
- Revisi ini **mengesampingkan** butir PDF yang mewajibkan tombol bayar dan
  CRUD produk di dalam aplikasi, untuk lingkup tugas ini.

### 2.2 Yang tetap dipertahankan

- 15 endpoint API dan bentuk kontrak dasarnya.
- 8 tabel domain inti.
- Token statis `zenvora-dev-token-2026` untuk API mobile.
- Aturan H1: tidak ada perhitungan bisnis di Dart.
- Timeout HTTP 10 detik.
- Transisi status hanya lewat state machine server.
- Web admin terpisah dari API mobile.

### 2.3 Hal yang belum boleh diklaim

- Jangan menyebut integrasi varian sudah transaksional.
- Jangan menyebut status berubah real-time; aplikasi memuat ulang saat dibuka
  atau di-refresh.
- Jangan menyebut pembeli bisa melacak resi di mobile; API belum mengirim resi.
- Jangan menyebut API sudah role-aware; otorisasi API belum diperketat.

---

## 3. Hierarki dokumen dan status sinkron

| Prioritas | Dokumen | Status |
|---|---|---|
| 1 | `docs/Perancangan/Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.md` (PDF) | Acuan awal; butir mobile tertentu sudah direvisi |
| 2 | `docs/status-revisi-web-admin.md` (dokumen ini) | Catatan revisi; addendum draf |
| 3 | `zenvora-master-context (3).md` | Belum diperbarui untuk revisi dan tabel ke-9 |
| 4 | `docs/Perancangan/prd (1).md` | Belum sinkron dengan web admin/read-only |
| 5 | `docs/Perancangan/database-schema.md` | Belum memuat `nomor_resi` dan `produk_varian` |
| 6 | `docs/Perancangan/api-contract (1).md` | Belum memuat `varian` dan aturan peran baru |
| 7 | `docs/Perancangan/architecture (1).md` dan `conventions.md` | Sebagian besar masih berlaku |
| 8 | `docs/admin/01-05` | Rancangan awal; beberapa klaim sudah tidak sesuai kode |

Aturan konflik:

1. Jangan mengedit PDF tugas.
2. Catat revisi di dokumen ini, lalu selaraskan dokumen prioritas 3-6.
3. Dokumen admin adalah dokumentasi implementasi, bukan kontrak API.
4. Jika kode dan dokumen berbeda, catat perbedaannya dulu; jangan diam-diam
   memilih salah satu.

---

## 4. Batasan keras

| Batasan | Status | Catatan |
|---|---|---|
| 15 rute API | Dipatuhi | `backend/routes/api.php`, diverifikasi 15 |
| Rute admin di `web.php` | Dipatuhi | 16 rute, termasuk masuk/keluar |
| 8 tabel domain inti | Tidak lagi literal | `produk_varian` menjadi tabel ke-9 |
| Tidak ada perhitungan bisnis di Dart (H1) | Dipatuhi | Angka uang/berat/ongkir dari server |
| Token statis | Dipatuhi | Hanya dibentuk di `LayananApi::_header()` |
| Timeout 10 detik | Dipatuhi | `batasWaktu` di `konfigurasi.dart` |
| Web admin terpisah dari API | Dipatuhi | Sesi web + CSRF |
| Transisi status server-side | Dipatuhi | `StatusPesanan::bolehPindahKe()` |
| Tidak menambah tabel tanpa addendum | Perlu dijaga | Tabel ke-9 sudah ada; jangan tambah lagi tanpa catatan |
| Jangan klaim real-time | Perlu dijaga | Tidak ada websocket/polling |

Konsekuensi 8 tabel: jika dosen menilai jumlah tabel secara literal, kondisi
sekarang adalah **9 tabel domain**. Ini harus disebut jujur di laporan, bukan
disembunyikan. Tabel framework (`users`, `cache`, `jobs`) tetap di luar
hitungan domain.

---

## 5. Register perubahan

| ID | Commit | Perubahan | Alasan | Bukti/berkas utama |
|---|---|---|---|---|
| C1 | `95511c6` | Deteksi GPS + reverse geocoding OSM di checkout | Revisi dosen: isi alamat otomatis | `checkout_page.dart`, `layanan_api.dart`, `pubspec.yaml`, E4 |
| C2 | `4580bcf` | Ongkir dinamis RajaOngkir + pilihan kota tujuan | Revisi dosen: tarif per kota | `ServisRajaOngkir.php`, `KurirController.php`, E4; rute tetap 15 |
| C3 | `8bea0f2` | Varian RAM/penyimpanan/warna + selector chips | Revisi dosen: multi-SKU | migrasi `produk_varian`, model, seeder, `rincian_produk_page.dart`; E2 |
| C4 | `dda44fd` | Dashboard admin mobile ditambahkan | Eksperimen Fase 4 | `dashboard_admin_page.dart` (kemudian dihapus) |
| C5 | `3930d08` | Dokumen arsitektur/SOP admin 01-05 | Perencanaan web admin | `docs/admin/*` |
| C6 | `24d19e2` | Fondasi web admin: sesi, layout, dashboard | Penjual pindah ke web | `AuthController`, `PastikanAdmin`, `routes/web.php`, 5 tes |
| C7 | `8c4178b` | Modul pesanan: filter, transisi, resi, rollback | Fulfillment penjual | `Admin/PesananController.php`, migrasi `nomor_resi`, 7 tes |
| C8 | `97bdf0d` | CRUD katalog, varian, unit serial | Penjual mengelola stok | `Admin/ProdukController.php`, `Admin/UnitProdukController.php`, 11 tes |
| C9 | `3f852ca` | README root dan tautan dokumen | Satu sumber petunjuk | `README.md` |
| C10 | `34ebb92` | Mobile dijadikan khusus pembeli | Pemisahan peran | Hapus 3 layar admin, hapus tombol status, read-only card, tes E1/E5/E7/F1a |
| C11 | `655cf85` | Sinkronisasi registran plugin `geolocator` | Build Flutter | `android/`, `pubspec.yaml` |
| C12 | `2c98d91` | Tahap 5 ditandai selesai | Dokumentasi status | `docs/admin/05-rencana-eksekusi.md`, `docs/log-ai.md` |

Catatan: C4 sengaja dicatat karena sempat ada, lalu dibatalkan oleh C10. Jangan
menganggap dashboard admin mobile masih ada.

---

## 6. Status per fase

| Fase | Status | Ringkasan | Verifikasi |
|---|---|---|---|
| Fase 1: GPS + alamat otomatis | Selesai | Geolocator + Nominatim; isi alamat checkout | E4 PASS; analyze bersih |
| Fase 2: RajaOngkir | Selesai | Tarif dinamis per kota; dropdown kota | E4 PASS; 15 rute tetap |
| Fase 3: Varian produk | Selesai di UI/API, belum transaksional | Varian tampil dan punya harga/stok; keranjang belum memilih varian | E2 PASS; lihat G1 |
| Fase 4: Web admin | Selesai Tahap 1-4 | Dashboard, pesanan, resi, katalog, varian, unit serial | 23 tes admin PASS; total suite 25 PASS |
| Fase 5: Mobile read-only | Selesai | Admin mobile dan tombol status dihapus | E1/E5/E7/F1a PASS; 360x640 aman |

---

## 7. Perubahan database

### 7.1 Daftar tabel domain

1. `pelanggan`
2. `produk`
3. `produk_varian` (tabel ke-9, tambahan revisi)
4. `kurir`
5. `metode_pembayaran`
6. `keranjang`
7. `pesanan`
8. `detail_pesanan`
9. `unit_produk`

### 7.2 `produk_varian`

Migrasi: `backend/database/migrations/2026_11_12_000001_create_produk_varian_table.php`

| Kolom | Tipe | Catatan |
|---|---|---|
| `id` | bigint PK | |
| `produk_id` | FK -> `produk.id` | cascade delete |
| `nama_varian` | string(100) | Contoh RAM/SSD/warna |
| `harga` | unsigned int | Harga varian |
| `stok` | unsigned int | Stok varian |
| `berat_gram` | unsigned int | Berat varian |
| `sku` | string(50), nullable | Belum dipakai checkout |
| timestamps | | |

Relasi: `Produk::varian()` = `hasMany(ProdukVarian::class)`.

### 7.3 `nomor_resi`

Migrasi: `backend/database/migrations/2026_11_12_032611_add_nomor_resi_to_pesanan_table.php`

- Kolom `pesanan.nomor_resi`, string(50), nullable.
- Diisi dari web admin saat status `diproses` menuju `dikirim`.
- **Belum diekspos** oleh `GET /api/pesanan/{id}`.
- **Belum ditampilkan** di mobile.
- **Belum tercatat** di `database-schema.md`.

### 7.4 Invarian stok

- `produk.stok = COUNT(unit_produk WHERE status = 'tersedia')`.
- Checkout memilih unit fisik dan mengubahnya menjadi `terjual`.
- Pembatalan mengembalikan unit dan stok melalui `ServisPesanan`/`ServisStok`.
- Stok varian belum memengaruhi alokasi unit fisik. Jangan mengklaim stok
  varian sebagai stok yang dijual sampai ada `varian_id` pada transaksi.

### 7.5 Dampak skema

- `database-schema.md` masih menyebut 8 tabel dan urutan migrasi lama.
- Dokumen belum memuat relasi `produk_varian`.
- Dokumen belum memuat `nomor_resi`.
- Perubahan skema ini harus masuk ke laporan, bukan hanya ke kode.

---

## 8. API dan otorisasi

### 8.1 Jumlah rute

**FAKTA (2026-11-12):**

- `routes/api.php`: **15 rute**.
- `routes/web.php`: **16 rute admin**, termasuk `admin/masuk`, `admin/masuk`
  (POST), `admin/keluar`, dashboard, pesanan, resi, status, produk, dan unit.
- Tidak ada endpoint API baru untuk web admin.

### 8.2 Perubahan bentuk respons

`GET /api/produk` dan `GET /api/produk/{id}` sekarang memuat relasi `varian`
karena `ProdukController` memakai `with('varian')`.

Konsekuensi:

- Field `varian` **tidak ada** di objek Produk pada `api-contract`.
- Mobile memakai field ini untuk selector, jadi field ini tidak bisa dihapus
  tanpa mengubah UI.
- Dokumen kontrak harus menambahkan `varian` sebagai field opsional/array.

### 8.3 Otorisasi API

**GAP:** semua rute API berada di bawah middleware
`MiddlewareDemo` + `AutentikasiTokenStatis`, tanpa pembedaan peran. Token pembeli
masih dapat memanggil:

- `POST/PUT/DELETE /api/produk`
- `PATCH /api/pesanan/{id}/status`

UI mobile sudah tidak menyediakan tombolnya, tetapi API belum menolak. Ini
adalah **perbedaan antara UI dan kontrak keamanan**.

Jika otorisasi API akan diperketat:

- Tidak perlu menambah endpoint.
- Perlu addendum `api-contract` dan PRD.
- Perlu memperbarui Postman, tes, dan dokumentasi peran.
- Jangan mengerjakannya diam-diam karena akan mengubah perilaku kontrak.

### 8.4 Resi

- Web admin dapat menyimpan resi.
- API pesanan belum mengembalikan `nomor_resi`.
- Mobile belum menampilkan resi.
- Klaim di `docs/admin/02` bahwa pembeli dapat melacak resi di mobile adalah
  **tidak benar untuk kode saat ini**.

---

## 9. Mobile

### 9.1 Layar yang ada

`mobile/lib/screens/`:

- `katalog_page.dart`
- `keranjang_page.dart`
- `checkout_page.dart`
- `rincian_produk_page.dart`
- `riwayat_pesanan_page.dart`
- `rincian_pesanan_page.dart`

Tidak ada lagi:

- `dashboard_admin_page.dart`
- `kelola_produk_page.dart`
- `form_produk_page.dart`

### 9.2 Perubahan read-only

- Ikon dashboard/admin di katalog dihapus.
- Tombol transisi status di rincian pesanan dihapus.
- Rincian pesanan menampilkan kartu informasi bahwa status dikelola penjual.
- `status_berikutnya` masih dikirim API, tetapi tidak dipakai untuk menampilkan
  aksi penjual di mobile.

### 9.3 Varian di mobile

- `rincian_produk_page.dart` menampilkan pilihan varian.
- `_hargaAktif` dan `_stokAktif` memakai varian terpilih.
- Tetapi `tambahKeranjang(_produk!.id, _kuantitas)` **hanya mengirim ID produk**.
- Akibatnya harga/stok yang tampil bisa berbeda dari yang dipakai keranjang dan
  checkout, yang masih memakai produk induk.

**GAP G1:** integrasi varian belum end-to-end. Jangan menyatakan varian sudah
masuk transaksi sampai `varian_id` ada di keranjang/detail/checkout dan
invarian stoknya jelas.

### 9.4 Bukti uji mobile

- E1 katalog: PASS (memakai scroll karena hero landing page).
- E5 rincian pesanan: PASS (read-only, tanpa tombol status).
- E7 pemisahan peran: PASS (tidak ada ikon admin, rincian read-only).
- F1a sambungan putus: PASS (katalog, riwayat, keranjang; port 8099).
- `flutter analyze`: No issues found (2026-11-12).
- Audit viewport 360x640: tidak ada overflow.

Catatan menjalankan tes integrasi:

- Server PHP dan MySQL harus hidup.
- Gunakan `--platform chrome` dan `--dart-define=ALAMAT_SERVER=...`.
- Jalankan satu file tes pada satu waktu (RAM terbatas).
- `--reporter expanded` untuk melihat `print`/`catat`.

---

## 10. Web admin

### 10.1 Rute dan fitur

- Login/logout: `/admin/masuk`, `POST /admin/masuk`, `POST /admin/keluar`.
- Dashboard KPI: `/admin`.
- Pesanan: daftar, rincian, ubah status, simpan resi.
- Produk: daftar, tambah, ubah, hapus.
- Unit: daftar unit serial dan ubah status tersedia/rusak.

### 10.2 Autentikasi

- Sesi web + CSRF, bukan token API.
- Middleware `PastikanAdmin` memeriksa session `admin_terautentikasi`.
- Kredensial dari `config/admin.php`:
  - `ADMIN_EMAIL` (default `admin@zenvora.test`)
  - `ADMIN_PASSWORD` (default `zenvora2026`)
  - `ADMIN_NAMA` (default `Administrator Zenvora`)
- Rate limit login 5 percobaan/menit.
- Ini kredensial pengembangan; jangan dipakai di produksi.

### 10.3 Sinkronisasi data

- Web admin dan mobile memakai database yang sama.
- Tidak ada websocket, push, atau polling otomatis.
- Perubahan status/resi terlihat di mobile setelah halaman dimuat ulang.
- Klaim "real-time" di dokumen admin harus diganti menjadi "tersinkron setelah
  refresh/reopen".

### 10.4 Bukti uji backend

- `AdminPanelTest`: 5 tes.
- `AdminPesananTest`: 7 tes.
- `AdminProdukTest`: 11 tes.
- Total suite: 25 tes, 93 assertion, PASS pada 2026-11-12.

---

## 11. Matriks kepatuhan dan deviasi

| Butir | Sumber | Status | Penjelasan |
|---|---|---|---|
| 15 endpoint API | API contract | Patuh | Jumlah dan jalur tidak berubah |
| Web admin tidak menambah API | Arsitektur admin | Patuh | Semua rute admin di `web.php` |
| Tombol bayar simulasi di mobile | PDF baris 320 | Menyimpang (disetujui) | Dihapus; pembayaran diproses penjual di web |
| CRUD produk dari aplikasi | PDF baris 324, 334, 568 | Menyimpang (disetujui) | CRUD dipindah ke web admin |
| Admin mobile tanpa login | PRD baris 47-52 | Menyimpang (disetujui) | Admin sekarang web + login |
| Semua aksi status di mobile | API contract baris 550 | Menyimpang (disetujui) | Mobile read-only |
| 8 tabel domain | Master context | Tidak literal | Ada 9 tabel karena `produk_varian` |
| H1 tanpa hitungan di Dart | Conventions/PDF | Patuh | Tidak ada perhitungan bisnis baru |
| Token statis API | PDF/contract | Patuh | Tetap dipakai |
| Varian transaksional | Revisi/plan | Belum | `varian_id` belum masuk keranjang/checkout |
| Resi terlihat pembeli | Dokumen admin 02 | Belum | API belum mengekspos resi |
| Real-time | Dokumen admin 01/02/05 | Tidak benar | Hanya refresh/reopen |
| Otorisasi API berbasis peran | PRD/keamanan | Belum | Token pembeli masih bisa mutasi |

---

## 12. Dampak dan rencana revisi dokumen

### P0 - harus segera, karena memengaruhi penilaian/evaluasi

1. `docs/Perancangan/database-schema.md`
   - Tambah `nomor_resi` pada `pesanan`.
   - Tambah bagian `produk_varian` dan relasinya.
   - Ubah klaim 8 tabel menjadi "8 tabel inti + 1 tabel varian" atau setarakan
     dengan keputusan revisi.
   - Perbarui urutan migrasi.
2. `docs/Perancangan/api-contract (1).md`
   - Tambah `varian` pada objek Produk.
   - Perjelas bahwa aksi status tidak lagi dilakukan dari mobile.
   - Catat perbedaan otorisasi API yang masih terbuka.
   - Jika resi akan dikirim ke mobile, tambahkan field dan contoh respons.
3. `docs/Perancangan/prd (1).md`
   - Ganti "admin mobile tanpa login" dengan "web admin sesi + login".
   - Tegaskan mobile hanya untuk pembeli.
4. `docs/Perancangan/plan.md`
   - FASE 4 yang menyebut dashboard admin mobile harus diganti menjadi web
     admin.
5. `docs/admin/01-arsitektur-admin.md`
   - Label `Api\PesananController`/`Api\ProdukController` sebagai "Mobile Read"
     belum benar secara API; jelaskan bahwa UI mobile read-only, API belum
     di-hardening.
   - Hapus klaim real-time.
   - Snippet rute lama tidak memuat login/logout dan nama metode yang berbeda
     dari kode; selaraskan.
6. `docs/admin/02-alur-pemrosesan-pesanan.md`
   - Pembeli tidak lagi mengubah `menunggu_konfirmasi`, membatalkan, atau
     menyelesaikan dari mobile.
   - Hapus klaim real-time dan pelacakan resi di mobile sampai API mendukung.
7. `docs/admin/05-rencana-eksekusi.md`
   - Klaim "instan" setelah perubahan status harus dikoreksi.
   - Status Tahap 5 tetap selesai, tetapi detail verifikasi diselaraskan.

### P1 - penting agar dokumen tidak menyesatkan

8. `docs/Perancangan/testing.md`
   - E7 masih "kelola produk"; ganti menjadi "pemisahan peran".
   - F14/F15 masih menguji CRUD mobile; tandai dipindahkan ke web admin atau
     hapus dari cakupan mobile.
9. `docs/Perancangan/testing (1).md`
   - Samakan dengan `testing.md`; jangan biarkan dua versi berbeda.
10. `docs/Perancangan/todo.md`
    - Baris E7 "Kelola produk + Form produk" sudah tidak berlaku.
    - Perbarui bukti E7 dan F1a yang menyebut halaman kelola.
11. `README.md`
    - NIM Ahmad Dio masih `2410200` (terpotong).
    - Video demo masih `(menyusul)`.
    - Tambahkan satu paragraf tegas: mobile read-only, penjual di web.
12. `zenvora-master-context (3).md`
    - Tambah addendum revisi dan tabel ke-9; jangan mengubah PDF.
13. `docs/log-ai.md`
    - Catat pembuatan dokumen ini dan revisi dokumen berikutnya.

---

## 13. Risiko, gap, dan hal di luar cakupan

| ID | Gap/risiko | Dampak | Tindakan |
|---|---|---|---|
| G1 | Varian belum transaksional | Harga tampil bisa beda dari keranjang | Putuskan `varian_id` di skema/kontrak |
| G2 | API belum role-aware | Token pembeli bisa mutasi | Addendum + hardening + tes |
| G3 | Resi tidak diekspos API | Pembeli tidak bisa lacak resi | Tambah field/kontrak atau koreksi dokumen |
| G4 | Dokumen stale | Evaluator membaca klaim yang salah | Kerjakan P0/P1 |
| G5 | Bukti bayar belum ada | Alur pembayaran belum lengkap | Putuskan web-only/API; jangan tambah endpoint tanpa revisi |
| G6 | Tidak ada CI | Regresi tidak otomatis terdeteksi | Pertimbangkan workflow test/analyze |
| G7 | `pint --test` gagal di 7 berkas saat ini | Gaya kode belum seragam | Commit terpisah khusus format |
| G8 | Tidak ada real-time | Ekspektasi dokumen tidak terpenuhi | Koreksi dokumen atau tambah polling |
| G9 | 9 tabel domain | Berbeda dari batas literal | Catat sebagai revisi resmi |
| G10 | README placeholder | Laporan belum final | Lengkapi NIM/video |
| G11 | Tes integrasi manual | Hasil bergantung server/DB | Dokumentasikan perintah dan state server |
| G12 | Kredensial admin plaintext config | Tidak layak produksi | Sebut sebagai batas tugas/dev |

Detail G7 - `pint --test` pada 2026-11-12 melaporkan:

- `app/Http/Controllers/Api/CheckoutController.php`
- `app/Http/Controllers/Api/KeranjangController.php`
- `app/Http/Controllers/Api/PesananController.php`
- `app/Http/Middleware/AutentikasiTokenStatis.php`
- `app/Services/ServisCheckout.php`
- `app/Services/ServisPesanan.php`
- `routes/api.php`

Jangan menganggap Pint bersih hanya karena tes lulus. Perbaikan format harus
dilakukan di commit terpisah agar tidak mengaburkan perubahan dokumen.

---

## 14. Bukti verifikasi dan cara menjalankan

### 14.1 Backend

```powershell
cd backend
php artisan test
php artisan route:list --path=api
php artisan route:list --path=admin
vendor\bin\pint --test
```

Hasil terakhir:

- `php artisan test`: 25 PASS, 93 assertion, sekitar 21,7 detik.
- Rute API: 15.
- Rute admin: 16.
- `pint --test`: gagal pada 7 berkas (G7).

### 14.2 Mobile

```powershell
cd mobile
flutter analyze
flutter test test\uji_e1_katalog_test.dart --platform chrome --dart-define=ALAMAT_SERVER=http://127.0.0.1:8000/api
flutter test test\uji_e5_rincian_pesanan_test.dart --platform chrome --dart-define=ALAMAT_SERVER=http://127.0.0.1:8000/api
flutter test test\uji_e7_pemisahan_peran_test.dart --platform chrome --dart-define=ALAMAT_SERVER=http://127.0.0.1:8000/api
flutter test test\uji_f1a_sambungan_test.dart --platform chrome --dart-define=ALAMAT_SERVER=http://127.0.0.1:8099/api
```

Hasil terakhir: E1/E5/E7/F1a PASS, analyze bersih.

Prasyarat tes integrasi:

- MySQL Laragon hidup.
- `php artisan serve` di port 8000.
- Database sudah dimigrasi dan di-seed.
- Server/DB dimatikan lagi setelah tes selesai.

### 14.3 State lingkungan saat dokumen dibuat

- HEAD: `2c98d91`.
- Working tree bersih sebelum dokumen ini dibuat.
- Server PHP dan MySQL tidak dijalankan permanen.
- Dokumen ini belum mengubah kode.

---

## 15. Aturan untuk model/anggota berikutnya

### Lakukan

- Baca dokumen ini, lalu `docs/Perancangan/` dan kode aktual.
- Pertahankan 15 rute API dan 16 rute admin.
- Tempatkan aksi penjual hanya di `routes/web.php`.
- Jaga H1: angka uang/berat/ongkir/stok dari server.
- Perbarui dokumen P0/P1 setiap kali perilaku berubah.
- Tambah baris `docs/log-ai.md` untuk perubahan berarti.
- Jalankan `php artisan test` dan `flutter analyze` sebelum commit.
- Gunakan UTF-8 saat menulis log/dokumen.
- Buat commit kecil dengan pesan Conventional Commits Bahasa Indonesia.
- Sebutkan status "read-only" dan "refresh/reopen", bukan real-time.

### Jangan

- Jangan menambah endpoint API untuk fitur admin.
- Jangan menambah tabel domain tanpa addendum eksplisit.
- Jangan mengembalikan dashboard/CRUD admin ke mobile.
- Jangan menghitung harga, ongkir, subtotal, atau stok di Dart.
- Jangan mengklaim varian, resi, atau otorisasi API sudah selesai.
- Jangan mengedit PDF tugas.
- Jangan memakai `Add-Content` untuk `docs/log-ai.md` (encoding rusak).
- Jangan menganggap `pint --test` hijau sebelum dijalankan.

---

## 16. Checklist tindakan berikutnya

- [x] Catat keputusan Opsi A dan dampaknya.
- [x] Catat register perubahan besar.
- [x] Catat status verifikasi dan gap.
- [ ] Selaraskan `database-schema.md`.
- [ ] Selaraskan `api-contract (1).md`.
- [ ] Selaraskan `prd (1).md` dan `plan.md`.
- [ ] Selaraskan `docs/admin/01`, `02`, `05`.
- [ ] Perbarui `testing.md`, `testing (1).md`, `todo.md`.
- [ ] Lengkapi README (NIM, video, peran).
- [ ] Putuskan desain varian transaksional.
- [ ] Putuskan hardening otorisasi API.
- [ ] Putuskan alur bukti pembayaran.
- [ ] Perbaiki format Pint di commit terpisah.
- [ ] Opsional: tambah CI test/analyze.

---

## 17. Lampiran: inventaris berkas kunci

### Backend

- `backend/routes/api.php` - 15 rute API.
- `backend/routes/web.php` - 16 rute admin.
- `backend/bootstrap/app.php` - routing, middleware admin, exception handler.
- `backend/config/admin.php` - kredensial admin.
- `backend/app/Http/Middleware/PastikanAdmin.php` - proteksi sesi admin.
- `backend/app/Http/Controllers/Admin/` - Auth, Dashboard, Pesanan, Produk, UnitProduk.
- `backend/app/Http/Controllers/Api/` - controller API mobile.
- `backend/app/Services/` - checkout, pesanan, stok, RajaOngkir.
- `backend/app/Enums/StatusPesanan.php` - state machine.
- `backend/resources/views/admin/` - Blade admin.
- `backend/database/migrations/2026_11_12_000001_create_produk_varian_table.php`.
- `backend/database/migrations/2026_11_12_032611_add_nomor_resi_to_pesanan_table.php`.
- `backend/tests/Feature/AdminPanelTest.php`, `AdminPesananTest.php`, `AdminProdukTest.php`.

### Mobile

- `mobile/lib/config/konfigurasi.dart` - alamat server, token, timeout.
- `mobile/lib/services/layanan_api.dart` - satu-satunya lapisan HTTP.
- `mobile/lib/screens/` - 6 layar pembeli.
- `mobile/lib/models/` - model termasuk `ProdukVarian`.
- `mobile/test/uji_e1_...` sampai `uji_e7_...`, `uji_f1a...`, `uji_f2...`.
- `mobile/test/uji_e_util.dart` - helper tes.

### Dokumen

- `docs/status-revisi-web-admin.md` - dokumen ini.
- `docs/Perancangan/Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.md` - PDF acuan.
- `docs/Perancangan/prd (1).md`.
- `docs/Perancangan/database-schema.md`.
- `docs/Perancangan/api-contract (1).md`.
- `docs/Perancangan/plan.md`.
- `docs/Perancangan/testing.md`, `testing (1).md`, `todo.md`.
- `docs/admin/01-05`.
- `docs/log-ai.md`.
- `cmd`/README root.

### Commit referensi

```text
95511c6 feat(mobile): implementasi deteksi lokasi gps dan reverse geocoding osm pada checkout
4580bcf feat: integrasi kalkulasi ongkir dinamis rajaongkir dan pemilihan kota tujuan
8bea0f2 feat: variasi produk elektronik ram storage warna dan selector chips
dda44fd feat(mobile): dashboard admin terpadu kpi omzet pemrosesan pesanan dan peringatan stok
3930d08 docs: dokumentasi arsitektur perancangan web admin dashboard backend
24d19e2 feat(admin): fondasi panel penjual web dengan sesi admin dan dashboard KPI
8c4178b feat(admin): modul pesanan dengan transisi status dan input resi
97bdf0d feat(admin): katalog produk, varian, dan unit serial
3f852ca docs: gunakan README root dan perbaiki tautan dokumen
34ebb92 feat(mobile): jadikan aplikasi hanya untuk pembeli
655cf85 chore(mobile): sinkronkan registran plugin geolocator
2c98d91 docs(admin): tandai tahap 5 selesai
```

---

## 18. Riwayat perubahan dokumen

| Versi | Tanggal | Perubahan |
|---|---|---|
| 1.0 | 2026-11-12 | Dibuat; mencatat Opsi A, register perubahan, gap, bukti verifikasi, dan rencana revisi dokumen |
