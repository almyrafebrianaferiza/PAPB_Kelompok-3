# Zenvora — Master Konteks Proyek (Handoff untuk AI)

> Tujuan file ini: satu berkas yang cukup agar AI mana pun (akun lain, model lain) bisa melanjutkan pekerjaan tanpa mengulang diskusi.
> Dibuat: Jumat, 6 November 2026. Tenggat internal pengumpulan: **Senin, 9 November 2026**.
> Bahasa kerja: **Bahasa Indonesia** (dokumen, nama tabel/kolom/jalur API, pesan galat, komentar).

---

## 0. Cara memakai file ini (untuk AI yang baru masuk)

1. Baca berkas berikut berurutan: (a) file ini, (b) `Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.pdf` (dokumen tugas dosen = **sumber otoritas tertinggi**), (c) `prd.md`, (d) `database-schema.md`, (e) semua file `.md` lain yang sudah jadi (lihat Bagian 6, kolom Status).
2. Bila ada konflik antar dokumen, urutan otoritas: **PDF tugas > keputusan terkunci di Bagian 3 file ini > prd.md > database-schema.md > dokumen lain**.
3. Jangan mengubah keputusan terkunci tanpa bertanya kepada pengguna. Hal yang belum pasti ditandai **[PERLU DIKONFIRMASI]**.
4. Satu dokumen per giliran, sesuai urutan di Bagian 6. Setelah selesai, perbarui tabel status di Bagian 6 (pengguna akan menempelkan versi terbaru).
5. Jangan mengarang hasil pemanggilan API atau tangkapan layar: dokumen tugas mewajibkan contoh permintaan/balasan berasal dari pemanggilan nyata. Dokumen perencanaan boleh memuat contoh **rancangan**, diberi label "rancangan".

## 1. Identitas proyek

| Butir | Isi |
|-------|-----|
| Tugas | Tugas Pengganti UTS (berkelompok), bobot 20% pada masing-masing mata kuliah |
| Mata kuliah | Pemrograman Aplikasi Perangkat Bergerak (PAPB, 2010MWP0507) dan Sistem Terdistribusi (ST); satu pekerjaan dinilai dua kali |
| Dosen | Ahsanun Naseh Khudori, S.Kom., M.Kom. |
| Kampus | S1 Informatika, ITSK RS dr. Soepraoen Kesdam V/BRW |
| Produk | **Zenvora**, toko online elektronik dan gawai |
| Domain | **No. 3 — Elektronik dan gawai** |
| Kategori awal | gadget, laptop, tv, monitor, tablet (aksesoris/printilan ditunda) |
| Stack | Backend: Laravel + MySQL. Mobile: Flutter (paket `http`, `setState`, tanpa Provider) |
| Jalur backend | **A** (Laravel sendiri) |
| Penilaian | Pertemuan 8: demo 3 menit, tanya jawab 7 menit, tugas modifikasi 5 menit |
| Nama kelompok/anggota/NIM | **[PERLU DIKONFIRMASI]**, sengaja dilewati. Contoh nama PDF di tugas (`Kelompok03`) hanyalah contoh, jangan diasumsikan nomor kelompok sebenarnya |

## 2. Ringkasan dokumen tugas (aturan keras)

### 2.1 Batasan sistem
- Pembayaran **simulasi** (perubahan status), dilarang payment gateway. Metode: `tunai_di_tempat`, `transfer_manual`.
- Pengantaran dari **tabel kurir internal**, dilarang API ekspedisi. Ongkir dihitung server.
- **Tanpa autentikasi penuh**; identitas = token statis atau `pelanggan_id` tetap. JWT baru Pertemuan 14.
- Proyek ini **dilanjutkan** ke Pertemuan 9–14 (tidak ganti proyek), jadi kode harus rapi dan kirim-identitas hanya di satu tempat di `LayananApi`.

### 2.2 Arsitektur
- Laravel = satu-satunya sumber kebenaran. Flutter hanya menampilkan. **Dilarang menghitung harga, total, ongkir, atau ketersediaan di Dart** (kehilangan nilai Kriteria 5).
- MySQL tidak boleh menyimpan total sebagai satu-satunya sumber tanpa detail per item.
- Laravel tidak boleh membalas HTML atau galat mentah basis data.

### 2.3 Empat belas endpoint wajib

| # | Metode dan jalur | Ketentuan |
|---|------------------|-----------|
| 1 | GET `/api/produk` | `?kategori=`, `?cari=`; **tetap 200 saat kosong** |
| 2 | GET `/api/produk/{id}` | 404 bila tidak ada |
| 3 | POST `/api/produk` | 201 / 422 |
| 4 | PUT `/api/produk/{id}` | 200 / 404 / 422 |
| 5 | DELETE `/api/produk/{id}` | 409 bila terpakai pesanan aktif |
| 6 | GET `/api/keranjang` | subtotal dari server |
| 7 | POST `/api/keranjang` | `produk_id`, `jumlah`; 409 bila stok kurang |
| 8 | PUT `/api/keranjang/{id}` | jumlah ≤ 0 → 422 |
| 9 | DELETE `/api/keranjang/{id}` | 200 |
| 10 | GET `/api/kurir` | daftar kurir + tarif |
| 11 | POST `/api/checkout` | header **`X-Kunci-Idempoten`** wajib; 201 |
| 12 | GET `/api/pesanan` | terbaru dulu |
| 13 | GET `/api/pesanan/{id}` | memuat harga saat pembelian |
| 14 | PATCH `/api/pesanan/{id}/status` | hanya perpindahan sah (selain itu 409) |

Nama jalur boleh disesuaikan domain asal ditulis di dokumentasi dan konsisten di Flutter. Endpoint tambahan (mis. #15) **harus didokumentasikan** (jika ada endpoint di kode yang tak terdokumentasi, Kriteria 4 turun).

### 2.4 Objek produk (7 kunci inti + min. 2 khas domain)
`id`(int), `nama`(string), `harga`(int rupiah bulat), `kategori`(string), `stok`(int), `tersedia`(bool, terpisah dari stok), `deskripsi`(string|null, Flutter wajib tangani null). Khas domain Zenvora: `berat_gram`, `garansi_bulan` (+ `merek` opsional).

### 2.5 Pembungkus respons seragam (semua endpoint, tanpa kecuali)
```json
{ "status": "sukses", "code": "200", "message": "...", "data": [] }
{ "status": "gagal",  "code": "422", "message": "...", "errors": { "kolom": ["pesan"] } }
```
Catatan: `code` berupa **string**.

### 2.6 Kode status dan perlakuan di Flutter

| Kode | Arti | Perlakuan Flutter |
|------|------|-------------------|
| 200 | berhasil baca/ubah | tampilkan data |
| 201 | dibuat | pindah ke halaman hasil (mis. rincian pesanan) |
| 404 | tidak ditemukan | keadaan kosong, bukan dialog teknis |
| 409 | bertentangan dengan keadaan server (stok kurang, status tidak sah) | tampilkan **pesan server**, tolak lanjut, tetap di layar |
| 422 | validasi gagal | pesan **per kolom** di bawah kolom |
| 500 | galat server | pesan umum + tombol coba lagi, tanpa jejak galat |

### 2.7 Status pesanan
`menunggu_pembayaran → menunggu_konfirmasi → dibayar → diproses → dikirim → selesai`. `dibatalkan` hanya dari dua status pertama. Perpindahan tak sah → **409**.

### 2.8 Checkout (zona transaksi)
Dalam **satu transaksi DB**: kunci baris produk (`lockForUpdate`) → cek stok → kurangi stok → simpan pesanan (+detail, ongkir, total di server) → kosongkan keranjang → commit → 201 + nomor pesanan. Gagal di langkah mana pun = rollback penuh (+409 dan daftar item kurang stok bila stok tidak cukup). **Idempotensi**: Flutter membuat nilai acak **sekali per percobaan checkout**, dipakai ulang saat coba lagi; server yang mengenali kunci sama mengembalikan pesanan yang sudah ada.

### 2.9 Ketentuan sisi Flutter
1. Semua panggilan API di satu kelas (`LayananApi`), bukan di widget.
2. Alamat server satu konstanta (emulator `http://10.0.2.2:8000/api`).
3. Paket `http` (materi Pertemuan 7).
4. Setiap panggilan punya `.timeout(...)` (contoh 10 detik), ditampilkan sebagai galat.
5. **Tidak ada panggilan jaringan di `build`**; awal di `initState` atau `FutureBuilder`.
6. Manajemen state: `setState` + constructor + callback. Tanpa Provider.
7. Empat keadaan eksplisit di setiap halaman pemanggil API: `enum KeadaanMuat { memuat, berhasil, kosong, galat }`. **Kosong ≠ galat.**

### 2.10 Tujuh halaman wajib
Katalog · Rincian produk · Keranjang · Checkout · Rincian pesanan · Riwayat pesanan · Kelola produk. Detail isi dan perpindahan ada di PDF Bagian 6 dan `prd.md` Bagian 6.1.

Aturan tambahan penting: daftar pakai `ListView.builder`/`GridView.builder`; filter dan cari **mengirim ulang permintaan ke server**; produk habis ditandai dan tombol dimatikan; hapus produk pakai dialog konfirmasi; CRUD menyegarkan daftar; keranjang dibaca dari server; tambah produk yang sudah ada = naikkan jumlah; form checkout pakai `Form` + validator pesan Indonesia; tombol checkout mati selama request; pembayaran simulasi lewat PATCH; rincian pesanan → kembali ke katalog dengan tumpukan halaman dibersihkan.

### 2.11 Lima galat (tampilan harus berbeda dan terbukti di video)
Tidak ada sambungan · Batas waktu · 422 (per kolom) · 409 (pesan server, tanpa pindah halaman) · 500 (pesan umum). **Dilarang:** menampilkan `e.toString()`, `catch` kosong, satu pesan untuk semua galat.

### 2.12 Ukuran minimum data
≥ 12 produk di ≥ 2 kategori · ≥ 2 produk stok nol/tidak tersedia · 3 kurir/wilayah bertarif berbeda · 2 metode bayar · 3 pesanan contoh berstatus berbeda · `php artisan migrate --seed` sekali jalan di komputer bersih.

### 2.13 Keluaran pengumpulan (3 buah, harus saling cocok)
1. **Repositori** (GitHub/GitLab): `backend/` (migrations, seeders, `.env.example`), `mobile/lib/`, `README.md`. README wajib **9 butir** (nama kelompok+anggota+NIM+peran; domain + satu aturan bisnis; cara jalankan backend; cara jalankan Flutter + tempat ubah alamat server; alamat server + alasan; pengenal pelanggan/token statis; daftar endpoint ringkas + tautan dokumentasi; tautan video; **catatan pemakaian AI di tingkat berkas/fungsi**). Tiap anggota ≥ 5 commit bermakna atas namanya. `.env` asli tidak boleh ikut.
2. **PDF dokumentasi API** 6–10 halaman, nama `PAPB-UTS_Kelompok-NN_Elektronik.pdf`, 7 bagian: (1) ERD, (2) tabel endpoint + kode status, (3) contoh permintaan/balasan **nyata** untuk 5 endpoint (daftar produk, tambah keranjang, lihat keranjang, checkout, rincian pesanan), (4) cara hitung subtotal/ongkir/total, (5) aturan bisnis domain + kode penolakan, (6) cara kerja `X-Kunci-Idempoten`, (7) daftar perpindahan status sah. Koleksi Postman = nilai tambah Kriteria 4.
3. **Video demo ≤ 5 menit** (termasuk 5 galat dengan menyebut cara memicunya; tautan harus bisa dibuka dari peramban lain).

Setiap anggota mengumpulkan tugas kelompok yang sama lewat LMS.

### 2.14 Rubrik (bobot PAPB / ST)

| K | Kriteria | PAPB | ST |
|---|----------|-----:|---:|
| 1 | Penyesuaian domain dan skema | 8 | 10 |
| 2 | Katalog dan CRUD | 10 | 5 |
| 3 | Keranjang dan checkout | 12 | 8 |
| 4 | Kontrak API dan dokumentasi | 8 | 18 |
| 5 | Konsistensi data dan transaksi | 8 | 20 |
| 6 | Penanganan galat dan ketahanan jaringan | 12 | 12 |
| 7 | Keadaan dan kualitas kode Flutter | 20 | 7 |
| 8 | Repositori, README, video, dokumentasi | 7 | 5 |
| 9 | Kesiapan uji petik (**per mahasiswa**) | 15 | 15 |

Skor 0–4; nilai = (skor/4) × bobot. Anggota yang tak bisa menjelaskan kode yang ia commit = **0 di K9** dan K7 kelompok turun satu tingkat.

### 2.15 Uji petik Pertemuan 8
Bank pertanyaan A (state/Flutter), B (kontrak API), C (konsistensi/transaksi), D (domain/rancangan), masing-masing 6 pertanyaan, plus 6 kemungkinan tugas modifikasi 5 menit. Tiap anggota mendapat ≥ 2 pertanyaan, ≥ 1 dari kategori yang bukan bagiannya. Daftar lengkap ada di PDF Bagian 10 (bahan `uji-petik.md`).

### 2.16 Aturan AI dan kejujuran akademik
AI boleh dipakai sebagai asisten; **tiap anggota wajib bisa menjelaskan setiap baris kode**. Pemakaian AI dicatat di README (berkas/fungsi). Menyalin repo kelompok lain = nol. Pustaka pub.dev/Packagist boleh bila disebutkan di README.

### 2.17 Ketidakjelasan di dokumen dosen
Rubrik menyebut **jalur C** (batas skor ≤ 1 di K4 dan K5) tetapi Bagian 5 hanya mendefinisikan A dan B. Tidak memengaruhi kita (jalur A), tetapi **[PERLU DIKONFIRMASI]** ke dosen bila ingin aman.

---

## 3. Keputusan terkunci (sudah disetujui pengguna)

| # | Keputusan |
|---|-----------|
| K1 | Nama toko **Zenvora**; kategori gadget, laptop, tv, monitor, tablet |
| K2 | Jalur backend **A** |
| K3 | **Stok = jumlah unit `tersedia`** pada tabel `unit_produk` (nomor seri per unit); `produk.stok` selalu sama dan hanya berubah dalam transaksi |
| K4 | Ongkir = `ceil(total_berat_gram / 1000) × tarif_per_kg` (kurir/wilayah terpilih), **tanpa batas berat**, dihitung server |
| K5 | `garansi_bulan` disalin ke `detail_pesanan` dan tampil di rincian pesanan bersama nomor seri |
| K6 | Nilai tambah: **lazy load** (`GET /api/produk?halaman=1&per_halaman=10`; habis bila item kembali < `per_halaman`; pembungkus tidak diubah). Postman: dianjurkan, ikut jika sempat |
| K7 | Lingkungan: PHP 8.3.28 (Laragon), Composer 2.9.2, MySQL 8.0.30, Flutter 3.44.8 / Dart 3.12.2. `laravel` belum di PATH → pakai `composer create-project laravel/laravel backend` |
| K8 | Uji di **emulator dan HP fisik** (HP: `php artisan serve --host=0.0.0.0`, IP LAN laptop, `usesCleartextTraffic` di build debug) |
| K9 | Alat AI: Claude, Antigravity, opencode (dicatat di README) |
| K10 | Tenggat internal 9 November 2026; sisa waktu sangat singkat |

## 4. Usulan default yang menunggu persetujuan  **[PERLU DIKONFIRMASI]**

Jika pengguna tidak menjawab, pakai default (kolom Default) dan catat di dokumen terkait.

| # | Pertanyaan | Default yang dipakai |
|---|------------|----------------------|
| Q1 | Tambah endpoint ke-15 `GET /api/metode-pembayaran`? | **TERKUNCI: Ya** (disetujui 6 Nov), sudah ada di `api-contract.md` |
| Q2 | Arti `stok` pada `PUT /api/produk/{id}` | **Target jumlah unit** (tambah unit / hapus unit tersedia; unit terjual tak disentuh) |
| Q3 | Penghapusan produk | **Soft delete**; 409 bila ada di pesanan berstatus selain `selesai`/`dibatalkan` |
| Q4 | Pembatalan pesanan | Mengembalikan unit dan stok (dalam transaksi) |
| Q5 | Identitas pembeli | **Header `Authorization: Bearer <token-statis>`** dipetakan server ke `pelanggan_id = 1`; kode kirim-token hanya di satu tempat di `LayananApi`. (Alternatif: header `pelanggan_id` langsung; lebih sederhana tetapi kurang siap untuk JWT) |
| Q6 | Nama dan tarif kurir | Zenvora Kota 4.000/kg · Zenvora Jawa 7.500/kg · Zenvora Nusantara 15.000/kg |
| Q7 | Hosting repo | **GitHub** (dosen diundang bila privat) |
| Q8 | Siapa boleh PATCH ke status apa? (tanpa login) | Tidak dibatasi per peran; yang dijaga hanya **perpindahan sah** |
| Q9 | Tabel `riwayat_status` | Tidak dibuat dulu |
| Q10 | Isi `skill.md` | Kumpulan instruksi reusable untuk AI (mis. "cara membuat halaman Flutter dengan `KeadaanMuat`", "cara membuat endpoint bertransaksi"), **bukan** daftar keahlian anggota |
| Q11 | Idempotensi: kunci sama tetapi isi permintaan berbeda | Kembalikan pesanan lama (sederhana); bila sempat, balas 409 |
| Q12 | Nomor kelompok, jumlah anggota, NIM, peran | Dikosongkan (hanya untuk README/PDF nanti) |

> Catatan: `api-contract.md` Bagian 8 memuat 6 keputusan rancangan tambahan (estimasi ongkir di `GET /api/kurir`, `status_berikutnya`, replay idempotensi 201, kode 401, `data.item_kurang` pada 409 checkout, nilai token).

## 5. Hal yang ditemukan tidak konsisten / perlu dirapikan

1. `prd.md` Bagian 7.1 memberi contoh ongkir laptop 1.800 g + tablet 480 g, sedangkan `database-schema.md` memakai 1.400 g + 510 g. Samakan agar dokumentasi PDF konsisten (usulan: ikut data seeder di schema).
2. `prd.md` Bagian 9 menyebut 14 endpoint; jika Q1 = Ya, jumlah menjadi 15 dan PRD harus diperbarui satu baris.
3. `prd.md` Bagian 4 mengusulkan Bearer token, sedangkan Bagian 16 masih menanyakannya sebagai pertanyaan terbuka. Tutup setelah Q5 dijawab.
4. Isi **body** `POST /api/checkout` belum didefinisikan di mana pun. Usulan: `kurir_id`, `metode_pembayaran_id`, `nama_penerima`, `alamat_penerima` (+ header `X-Kunci-Idempoten`). Tetapkan di `api-contract.md`.
5. Jadwal `prd.md` Bagian 14 dimulai Kamis 5 Nov; hari ini Jumat 6 Nov, jadi sisa waktu efektif ±3 hari. Dokumen pendukung yang tidak memengaruhi nilai langsung sebaiknya dibuat ringkas (lihat Prioritas di Bagian 6).

---

## 6. Rencana seluruh file `.md`

Urutan pengerjaan dan prioritas. **P1** = langsung dipakai menulis kode atau menentukan nilai; **P2** = membantu tetapi bisa ringkas.

| # | Berkas | Prioritas | Status |
|---|--------|-----------|--------|
| 1 | `prd.md` | P1 | **Selesai** (draf 1) |
| 2 | `database-schema.md` | P1 | **Selesai** (8 tabel, seeder, invarian) |
| 3 | `zenvora-master-context.md` (file ini) | P1 | **Selesai** |
| 4 | `api-contract.md` | P1 | **Selesai** (15 endpoint, draf 1; contoh masih RANCANGAN) |
| 5 | `architecture.md` | P1 | **Selesai** (draf 1, 6 Nov; kerangka kode masih RANCANGAN) |
| 6 | `conventions.md` | P1 | **Selesai** (draf 1, 7 Nov) |
| 7 | `agent.md` | P1 | **Selesai** (draf 1, 7 Nov) |
| 8 | `skill.md` | P2 | Belum |
| 9 | `workflow.md` | P2 | Belum |
| 10 | `todo.md` | P1 | **Selesai** (draf 1, 7 Nov; fase A–H, tanda ★/◇) |
| 11 | `testing.md` | P1 | Belum |
| 12 | `submission.md` | P2 | Belum |
| 13 | `uji-petik.md` | P2 | Belum |

### 6.1 Spesifikasi isi tiap berkas

**`api-contract.md`**: sumber bahan PDF dokumentasi (Bagian 2–3, 5–7 PDF). Isi: pembungkus respons; tabel 14/15 endpoint (metode, jalur, header, parameter query, body, kode status, contoh respons **rancangan**); body checkout; skema objek (produk, item keranjang, kurir, pesanan, detail pesanan dengan `nomor_seri[]`); format galat 422/409/500 (409 checkout memuat daftar item kurang stok); aturan lazy load; ketentuan header `Authorization` dan `X-Kunci-Idempoten`; perlakuan tiap kode di Flutter; daftar perpindahan status. Contoh ditandai "rancangan" sampai diganti hasil panggilan nyata.

**`architecture.md`**: diagram komponen (Flutter → LayananApi → Laravel → MySQL); struktur folder usulan `backend/` (Controllers, Requests, Resources, Services/`ServisCheckout`, Enums/`StatusPesanan`, trait/helper pembungkus respons, handler pengecualian yang memetakan semua galat ke pembungkus seragam, middleware token statis) dan `mobile/lib/` (`config/`, `models/`, `services/layanan_api.dart`, `screens/`, `widgets/`, `enums/keadaan_muat.dart`, `exceptions/`); diagram urutan checkout (transaksi, urutan kunci menurut `id` naik, idempotensi); pemetaan galat Dart (kelas pengecualian bertipe: sambungan, batas waktu, validasi, bentrok, server); alur navigasi 7 halaman; strategi lazy load.

**`conventions.md`**: penamaan (Indonesia, `snake_case` DB/JSON, `camelCase`/`PascalCase` Dart/PHP); aturan "tidak ada hitungan di Dart" + perintah `grep` pengecekan; aturan "tidak ada jaringan di build"; larangan `e.toString()`, `catch` kosong, `print` sisa; format pesan commit (Conventional Commits berbahasa Indonesia, mis. `feat(checkout): ...`); aturan ≥ 5 commit bermakna per anggota dan commit kecil; aturan `.env`; pesan validasi bahasa Indonesia.

**`agent.md`**: instruksi permanen untuk asisten AI di repo (dibaca Claude Code/Antigravity/opencode): konteks proyek singkat, aturan keras (Bagian 2 + 3 file ini), larangan, cara mencatat pemakaian AI (format log: berkas/fungsi, alat, tanggal, anggota yang mereview), kewajiban menjelaskan kode, tautan ke dokumen lain.

**`skill.md`**: resep reusable untuk AI: (a) membuat halaman Flutter dengan `KeadaanMuat` dan 4 tampilan; (b) menambah metode di `LayananApi` dengan timeout dan pemetaan galat; (c) membuat endpoint Laravel dengan pembungkus seragam; (d) menulis transaksi + `lockForUpdate`; (e) membuat migrasi/seeder; (f) menulis kasus uji. Tiap resep: kapan dipakai, langkah, contoh kerangka, cek mandiri.

**`workflow.md`**: alur kerja tim dan AI: cabang Git (`main`, `feat/...`), siklus kerja per fitur (baca kontrak → backend → uji Postman → Flutter → uji → commit), aturan review silang (tiap anggota membaca kode anggota lain untuk Kriteria 9), cara memakai tiga alat AI tanpa saling menimpa, ritual harian (`migrate:fresh --seed` + SQL invarian), siapa merge.

**`todo.md`** (**diputuskan pengguna 6 Nov: todo untuk AI pengguna, bukan pembagian tugas kelompok**): rencana eksekusi langkah demi langkah yang dibaca dan dijalankan AI coding (Claude Code/Antigravity/opencode). Tiap langkah: nomor, tujuan, berkas yang dibuat/diubah, dokumen rujukan, perintah menjalankan, **kriteria selesai yang bisa diverifikasi**, dan kotak centang. Urutan mengikuti jalur kritis: setup proyek → migrasi → seeder → endpoint produk/kurir/metode bayar/keranjang → checkout transaksional + idempotensi → status pesanan → kerangka Flutter + `LayananApi` → halaman 1–7 → lima galat → lazy load → pengujian → Postman → dokumentasi/README. Tidak memuat nama anggota atau pembagian orang.

**`testing.md`**: skenario uji per butir daftar periksa PDF Bagian 11: checkout dua kali (satu pesanan), rollback saat gagal tengah jalan, dua pembeli unit terakhir (stok tidak minus), 5 galat + cara memicunya, daftar kosong ≠ galat, invarian stok (SQL), perpindahan status sah/tidak sah, ongkir untuk beberapa kombinasi berat, validasi 422, soft delete 409, lazy load halaman terakhir, null `deskripsi`. Format: ID, langkah, hasil yang diharapkan, kolom hasil nyata (diisi saat uji).

**`submission.md`**: README 9 butir (kerangka siap isi), naskah video ≤ 5 menit dengan stopwatch per adegan, nama berkas PDF, daftar periksa Bagian 11 dengan kotak centang, log pemakaian AI, tabel hitungan commit per anggota, langkah verifikasi tautan video dan repositori dari peramban lain.

**`uji-petik.md`**: 24 pertanyaan A–D (salin dari PDF Bagian 10) beserta jawaban rancangan khusus Zenvora dengan penunjuk berkas/baris (diisi setelah kode jadi); 6 tugas modifikasi dengan berkas yang harus dibuka; tabel "siapa menjelaskan apa" supaya tiap anggota menguasai bagian orang lain.

---

## 7. Ringkasan `prd.md` dan `database-schema.md` (agar tidak perlu dibaca ulang seluruhnya)

- **PRD**: ruang lingkup, 7 halaman, 4 keadaan layar, 5 galat, aturan ongkir/nomor seri/garansi, kontrak 14 endpoint, status pesanan, kebutuhan non-fungsional (transaksi, idempotensi, timeout, tanpa jaringan di build), lingkungan, jadwal 4 hari, risiko, 4 pertanyaan terbuka.
- **Skema**: DB `zenvora` (utf8mb4), 8 tabel (`pelanggan`, `produk`, `unit_produk`, `keranjang`, `kurir`, `metode_pembayaran`, `pesanan`, `detail_pesanan`). Urutan migrasi: pelanggan, produk, kurir, metode_pembayaran, keranjang, pesanan, detail_pesanan, unit_produk. Model wajib `protected $table = '...'`. `pesanan` menyalin `tarif_per_kg_saat_pesan`; `detail_pesanan` menyalin nama, harga, berat, garansi. Unique `(pelanggan_id, produk_id)` di keranjang dan `(pelanggan_id, kunci_idempoten)` di pesanan. Keranjang **tidak** mereservasi stok. `nomor_pesanan` format `ZNV-YYYYMMDD-{id 5 digit}`, nomor seri `ZNV-P{kodeProduk}-{urut4digit}`. Seeder: 15 produk (stok nol: iPhone 15, TCL 32"; `tersedia=false`: Samsung 27" Curved; dua `deskripsi` NULL), 3 kurir, 2 metode bayar, 3 pesanan contoh dibuat lewat logika checkout (A `menunggu_pembayaran`, B `dibayar`, C `selesai`). Kunci lock berurutan menurut `id` naik. SQL invarian harus 0 baris.

## 8. Prompt pembuka untuk AI di akun lain (salin-tempel)

```
Kamu melanjutkan proyek tugas kuliah "Zenvora" (Laravel + Flutter, domain Elektronik dan Gawai).
Saya lampirkan: zenvora-master-context.md, Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.pdf,
prd.md, database-schema.md, dan file .md lain yang sudah jadi.
Langkah: (1) baca master-context dulu, lalu PDF tugas, lalu sisanya; (2) rangkum pemahamanmu
dalam maksimal 10 poin dan sebutkan hal yang bertentangan atau belum jelas; (3) jangan
mengubah keputusan terkunci (Bagian 3) tanpa bertanya; (4) kerjakan SATU berkas berikutnya
sesuai tabel status di Bagian 6, dalam Bahasa Indonesia, lalu perbarui tabel status itu.
Berkas berikutnya: api-contract.md
```

## 9. Daftar berkas yang harus diunggah saat pindah akun

Wajib: `zenvora-master-context.md`, `Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.pdf`, `prd.md`, `database-schema.md`.
Tambahkan **setiap berkas `.md` baru** yang sudah dibuat sesudah ini (mis. `api-contract.md`, `architecture.md`, ...), dalam versi terbaru.
Setelah kode mulai ditulis: unggah juga potongan kode yang relevan (migrasi, `ServisCheckout`, `layanan_api.dart`) atau tempel struktur folder (`tree`), karena AI baru tidak melihat repositori Anda.
Jangan unggah: `.env` asli, token, atau kata sandi.

---

## 10. Log perubahan

| Tanggal | Perubahan |
|---------|-----------|
| 2026-11-06 | File master dibuat. `prd.md` dan `database-schema.md` sudah ada. Menunggu jawaban Q1–Q12 (Bagian 4). |
| 2026-11-07 | `todo.md` selesai (rencana eksekusi untuk AI, tanpa nama anggota). Berikutnya: `testing.md`. |
| 2026-11-07 | `agent.md` selesai (aturan keras, cara kerja, kewajiban menjelaskan, format `docs/log-ai.md`). Berikutnya: `todo.md`. |
| 2026-11-07 | `conventions.md` selesai (14 aturan keras, perintah grep pemeriksaan, format commit, pesan baku). Berikutnya: `agent.md`. |
| 2026-11-06 | `api-contract.md` direvisi: urutan checkout (replay idempotensi dicek sebelum validasi keranjang + cek ulang di dalam transaksi), contoh tablet jadi 3 produk, aksi status dipusatkan di Rincian pesanan. `architecture.md` selesai; pemicu galat demo lewat flag `.env` (tanpa endpoint ke-16). Berikutnya: `conventions.md`. |
| 2026-11-06 | Q1 terkunci (15 endpoint). `api-contract.md` selesai. `todo.md` didefinisikan sebagai rencana eksekusi untuk AI. Default Q2–Q11 dipakai di `api-contract.md` sampai dikoreksi. |
