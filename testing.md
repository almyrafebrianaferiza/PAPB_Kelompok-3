# Rencana Pengujian — Zenvora

> Pendamping `prd.md`, `database-schema.md`, dan `api-contract.md`. Setiap skenario di sini menjawab satu butir **daftar periksa PDF Bagian 11** atau satu pertanyaan uji petik.
> Cara pakai: jalankan skenario, isi kolom **Hasil** (`LULUS`/`GAGAL` + catatan singkat), dan simpan bukti (tangkapan layar Postman atau hasil SQL). Bukti yang sama bisa dipakai untuk contoh nyata di PDF dokumentasi.
> Nama tabel dan kolom pada SQL mengikuti `database-schema.md`; bila ada perbedaan nama kolom, sesuaikan dengan skema yang sebenarnya.

---

## 0. Persiapan

| Butir | Perintah / nilai |
|-------|------------------|
| Reset data bersih | `php artisan migrate:fresh --seed` (dari folder `backend/`) |
| Jalankan server | `php artisan serve` (emulator) atau `php artisan serve --host=0.0.0.0` (HP fisik) |
| Header Postman (semua permintaan) | `Accept: application/json`, `Authorization: Bearer zenvora-dev-token-2026` |
| Variabel Postman | `{{base}}` = `http://127.0.0.1:8000/api`, `{{token}}`, `{{kunci}}` (isi UUID baru tiap percobaan checkout) |
| Klien SQL | HeidiSQL atau terminal MySQL bawaan Laragon, database `zenvora` |

**Aturan:** ulangi `migrate:fresh --seed` sebelum kelompok skenario yang mengubah data (K, T, S). Skenario yang hanya membaca tidak perlu reset.

### 0.1 Kueri invarian (jalankan setelah seeder, dan setelah setiap uji checkout/batal)

Semua kueri **harus mengembalikan 0 baris**.

```sql
-- I1: produk.stok harus sama dengan jumlah unit berstatus tersedia
SELECT p.id, p.nama, p.stok, COUNT(u.id) AS unit_tersedia
FROM produk p
LEFT JOIN unit_produk u ON u.produk_id = p.id AND u.status = 'tersedia'
GROUP BY p.id, p.nama, p.stok
HAVING p.stok <> COUNT(u.id);

-- I2: stok tidak pernah negatif
SELECT id, nama, stok FROM produk WHERE stok < 0;

-- I3: unit terjual wajib tertaut ke detail pesanan; unit tersedia wajib tidak tertaut
SELECT id, nomor_seri, status, detail_pesanan_id FROM unit_produk
WHERE (status = 'terjual'  AND detail_pesanan_id IS NULL)
   OR (status = 'tersedia' AND detail_pesanan_id IS NOT NULL);

-- I4: jumlah unit tertaut pada tiap detail pesanan sama dengan jumlahnya
-- (Pesanan dibatalkan dikecualikan: unit memang dilepas kembali ke 'tersedia'
--  sesuai api-contract 4.14 dan database-schema Bagian 4, tetapi baris detail tetap ada)
SELECT d.id, d.jumlah, COUNT(u.id) AS unit_tertaut
FROM detail_pesanan d
JOIN pesanan p ON p.id = d.pesanan_id
LEFT JOIN unit_produk u ON u.detail_pesanan_id = d.id
WHERE p.status <> 'dibatalkan'
GROUP BY d.id, d.jumlah
HAVING d.jumlah <> COUNT(u.id);

-- I5: total pesanan = subtotal item + ongkir
SELECT p.id, p.total, SUM(d.harga_satuan * d.jumlah) + p.ongkir AS seharusnya
FROM pesanan p JOIN detail_pesanan d ON d.pesanan_id = p.id
GROUP BY p.id, p.total, p.ongkir
HAVING p.total <> SUM(d.harga_satuan * d.jumlah) + p.ongkir;

-- I6: tidak ada nomor seri ganda
SELECT nomor_seri, COUNT(*) FROM unit_produk GROUP BY nomor_seri HAVING COUNT(*) > 1;

-- I7: tidak ada kunci idempoten ganda per pelanggan
SELECT pelanggan_id, kunci_idempoten, COUNT(*) FROM pesanan
GROUP BY pelanggan_id, kunci_idempoten HAVING COUNT(*) > 1;
```

Catatan: `harga_satuan` dan `jumlah` dipakai pada I5 hanya sebagai **pemeriksaan data di basis data**; hitungan ini tidak boleh ada di kode Dart.

---

## 1. Seeder dan Data Awal (Bagian 11: butir 2, 3, 4)

| ID | Langkah | Hasil yang diharapkan | Hasil |
|----|---------|-----------------------|-------|
| S1 | Di komputer bersih (atau database dihapus): `php artisan migrate --seed` sekali jalan | Selesai tanpa galat, tanpa langkah manual tambahan | |
| S2 | `SELECT COUNT(*) FROM produk;` | ≥ 12 (target 15) | |
| S3 | `SELECT kategori, COUNT(*) FROM produk GROUP BY kategori;` | ≥ 2 kategori (target 5 kategori × 3 produk) | |
| S4 | `SELECT nama, stok, tersedia FROM produk WHERE stok = 0 OR tersedia = 0;` | ≥ 2 baris (iPhone 15 dan TCL 32" stok 0; Samsung 27" Curved `tersedia = 0`) | |
| S5 | `SELECT nama, tarif_per_kg FROM kurir;` | 3 kurir dengan tarif berbeda | |
| S6 | `SELECT * FROM metode_pembayaran;` | 2 baris: `tunai_di_tempat`, `transfer_manual` | |
| S7 | `SELECT nomor_pesanan, status FROM pesanan;` | 3 pesanan dengan status berbeda | |
| S8 | `SELECT COUNT(*) FROM produk WHERE deskripsi IS NULL;` | ≥ 2 (untuk uji penanganan null di Flutter) | |
| S9 | Jalankan kueri invarian I1–I7 | Semua 0 baris | |

---

## 2. Kontrak API dan Pembungkus (Bagian 11: butir 5; Kriteria 4)

Panggil **seluruh 15 endpoint** sekali dari Postman dan bandingkan dengan `api-contract.md`.

| ID | Endpoint dan kasus | Hasil yang diharapkan | Hasil |
|----|--------------------|-----------------------|-------|
| A1 | GET `/produk` | 200, `data` array, semua kunci produk ada, `code` bertipe string | |
| A2 | GET `/produk?kategori=laptop` | 200, hanya `kategori = laptop` | |
| A3 | GET `/produk?cari=asus` (huruf kecil) | 200, mencocokkan nama/merek tanpa peka huruf besar-kecil | |
| A4 | GET `/produk?cari=zzzxxx` | **200** dengan `data: []` (bukan 404) | |
| A5 | GET `/produk/{id}` ada | 200, objek produk | |
| A6 | GET `/produk/99999` | 404, pembungkus `gagal` | |
| A7 | POST `/produk` valid | 201; dicek SQL: jumlah baris `unit_produk` = `stok`, I1 lolos | |
| A8 | POST `/produk` body kosong | 422 dengan `errors` per kolom | |
| A9 | PUT `/produk/{id}` valid (ubah harga) | 200; pesanan lama tidak berubah (lihat K6) | |
| A10 | PUT `/produk/99999` | 404 | |
| A11 | PUT `/produk/{id}` `stok` dinaikkan lalu diturunkan | Unit bertambah/berkurang sesuai target; I1 lolos; unit terjual tidak tersentuh | |
| A12 | DELETE produk yang tidak ada di pesanan | 200; produk hilang dari GET dan keranjang | |
| A13 | DELETE produk yang ada di pesanan berstatus aktif | **409** dengan pesan dari server | |
| A14 | DELETE produk yang hanya ada di pesanan `selesai`/`dibatalkan` | 200 (soft delete); riwayat pesanan tetap menampilkan nama produk | |
| A15 | GET `/keranjang` (kosong) | 200, `item: []`, `subtotal: 0`, `total_jumlah: 0` | |
| A16 | POST `/keranjang` produk baru | **201** | |
| A17 | POST `/keranjang` produk yang sama lagi | **200**, `jumlah` bertambah, **tetap satu baris** | |
| A18 | POST `/keranjang` jumlah melebihi stok | 409, pesan dari server, keranjang tidak berubah | |
| A19 | POST `/keranjang` produk stok 0 / `tersedia=false` | 409 | |
| A20 | POST `/keranjang` `jumlah: 0` dan `jumlah: -1` | 422, `errors.jumlah` | |
| A21 | PUT `/keranjang/{id}` `jumlah: 0` | 422 | |
| A22 | PUT `/keranjang/{id}` jumlah > stok | 409 | |
| A23 | DELETE `/keranjang/{id}` lalu ulang | 200, lalu 404 | |
| A24 | GET `/kurir` dengan keranjang berisi | 200, tiap kurir memuat `ongkir` dan `total_estimasi` sesuai rumus | |
| A25 | GET `/kurir` dengan keranjang kosong | 200, `berat_kg_tertagih`, `ongkir`, `total_estimasi` = 0 | |
| A26 | GET `/metode-pembayaran` | 200, 2 metode | |
| A27 | GET `/pesanan` | 200, urut terbaru ke terlama | |
| A28 | GET `/pesanan/{id}` | 200, `item[].nomor_seri` sebanyak `jumlah`, `status_berikutnya` ada | |
| A29 | GET `/pesanan/99999` | 404 | |
| A30 | Tanpa header `Authorization` | 401, pembungkus `gagal` (bukan HTML) | |
| A31 | GET `/rute-tidak-ada` | 404, pembungkus `gagal` (bukan halaman HTML) | |
| A32 | `DELETE /api/kurir` (metode tidak didukung) | 405, pembungkus `gagal` | |
| A33 | Periksa **semua** respons di atas | Selalu `status`, `code` (string), `message`; `errors` hanya pada 422 | |

---

## 3. Checkout, Transaksi, dan Idempotensi (Bagian 11: butir 6, 7, 8, 9; Kriteria 3 dan 5)

Persiapan umum: `migrate:fresh --seed`, tambahkan item ke keranjang, siapkan `{{kunci}}` baru.

### 3.1 Checkout sukses

| ID | Langkah | Hasil yang diharapkan | Hasil |
|----|---------|-----------------------|-------|
| K1 | Keranjang: Vivobook ×1 + Tab A9+ ×1. POST `/checkout` (kurir Zenvora Jawa) | 201; subtotal 11.698.000; 1.910 g → 2 kg; ongkir 15.000; total 11.713.000 | |
| K2 | Setelah K1: periksa SQL | Stok Vivobook 3 → 2, Tab A9+ 5 → 4; 2 unit `terjual` bertaut ke `detail_pesanan`; I1–I7 lolos | |
| K3 | Setelah K1: GET `/keranjang` | Keranjang kosong (dikosongkan oleh server) | |
| K4 | Setelah K1: GET `/pesanan/{id}` | Nomor seri tampil per unit, garansi tampil (24 dan 12 bulan) | |
| K5 | Ulangi checkout dengan keranjang kosong | 422 (`errors.keranjang`), tidak ada perubahan data | |
| K6 | Ubah harga produk lewat PUT, lalu GET pesanan lama | Harga di pesanan lama **tidak berubah** (jawaban uji petik C3) | |
| K7 | Ubah tarif kurir di basis data, lalu GET pesanan lama | `kurir.tarif_per_kg` dan `ongkir` pesanan lama tidak berubah | |

### 3.2 Aturan ongkir dari total berat (aturan bisnis khas domain)

Hitung harapan dari berat seeder. Uji dengan beberapa kombinasi keranjang dan lihat `GET /kurir` serta hasil checkout.

| ID | Total berat | Kurir | Harapan |
|----|-------------|-------|---------|
| O1 | 1.000 g | tarif T | 1 kg → ongkir = 1 × T |
| O2 | 1.001 g | tarif T | **2 kg** → ongkir = 2 × T (pembulatan ke atas) |
| O3 | 1.910 g | 7.500 | 2 kg → 15.000 |
| O4 | 2.280 g | 7.500 | 3 kg → 22.500 |
| O5 | Berat sangat besar (mis. 3 monitor/TV, > 20 kg) | tarif T | Tetap dihitung tanpa batas maksimum |
| O6 | Ganti kurir pada keranjang yang sama | — | Ongkir **berubah** sesuai tarif; nilai dari server |
| O7 | `kurir_id` tidak ada / tidak aktif | — | 422 |

### 3.3 Checkout gagal tidak meninggalkan perubahan (butir 8)

| ID | Langkah | Hasil yang diharapkan | Hasil |
|----|---------|-----------------------|-------|
| G1 | Keranjang berisi produk A (stok cukup) dan produk B. Di basis data, turunkan stok B sampai kurang dari jumlah di keranjang (sesuaikan unit agar I1 tetap lolos). POST `/checkout` | 409, `data.item_kurang` memuat B | |
| G2 | Setelah G1: kueri stok A dan B, jumlah pesanan, isi keranjang | Stok A **tidak berkurang**, tidak ada pesanan baru, keranjang **masih utuh**, I1–I7 lolos | |
| G3 | Beli produk stok 0 (iPhone 15) | 409 dengan pesan dari server | |
| G4 | Beli produk `tersedia = false` | 409 | |
| G5 | **Paksa kegagalan di tengah transaksi** (sementara): di `ServisCheckout`, tambahkan `throw new \Exception('uji')` tepat setelah langkah pengurangan stok/penautan unit. Jalankan checkout valid | 500 dengan pesan umum; stok, status unit, pesanan, dan keranjang **semua tetap seperti sebelum** (rollback penuh); I1–I7 lolos | |
| G6 | **Hapus** baris `throw` dari G5, lalu jalankan checkout valid sekali lagi | Berhasil 201 (membuktikan kode kembali normal) | |

Peringatan G5: baris `throw` tidak boleh ikut di-commit (kode mati dan merusak checkout).

### 3.4 Idempotensi dan klik ganda (butir 9; uji petik C4)

| ID | Langkah | Hasil yang diharapkan | Hasil |
|----|---------|-----------------------|-------|
| D1 | POST `/checkout` dengan `{{kunci}}` = X, sukses. Ulangi **permintaan yang sama persis** dengan kunci X | Respons sama (pesanan yang sama, nomor pesanan sama); `SELECT COUNT(*) FROM pesanan` bertambah **hanya 1** | |
| D2 | Dua permintaan **bersamaan** dengan kunci X (Postman Runner atau `curl ... & curl ... & wait` di Git Bash) | Hanya satu pesanan; stok berkurang sekali; I1, I7 lolos | |
| D3 | Tanpa header `X-Kunci-Idempoten` | 422 (`errors.kunci_idempoten`) | |
| D4 | Kunci sama, tetapi isi body berbeda (mis. alamat lain) | Pesanan lama dikembalikan, tidak ada pesanan baru | |
| D5 | Di aplikasi: tekan tombol Checkout dua kali cepat | Tombol mati saat permintaan berjalan; hanya satu pesanan terbentuk | |
| D6 | Di aplikasi: matikan server tepat saat checkout, lalu tekan **Coba lagi** setelah server hidup | Kunci yang sama dipakai ulang (periksa log server); pesanan tidak ganda | |

### 3.5 Dua pembeli unit terakhir (uji petik C2)

Cara 1 (disarankan, paling dekat dengan skenario): buat `pelanggan` ke-2 dengan token uji sendiri (hanya untuk pengujian), set stok produk X = 1 (satu unit tersedia), masukkan X ke keranjang kedua pelanggan, lalu kirim checkout keduanya **bersamaan** dengan kunci berbeda.

Cara 2 (tanpa pelanggan kedua): isi keranjang dengan X (jumlah 1, stok 1), kirim dua checkout bersamaan dengan kunci **berbeda**.

| ID | Hasil yang diharapkan | Hasil |
|----|-----------------------|-------|
| U1 | Tepat **satu** pesanan sukses (201). Permintaan lain: Cara 1 → 409 stok kurang; Cara 2 → 409 atau 422 (keranjang sudah kosong) | |
| U2 | Stok X = 0 (**tidak minus**), satu unit `terjual`; I1–I3 lolos | |
| U3 | Jelaskan lisan: urutan kunci baris (`lockForUpdate`) dan mengapa pembeli kedua menunggu lalu melihat stok 0 | |

---

## 4. Status Pesanan (Bagian 11 tidak menyebut khusus, tetapi dinilai pada Kriteria 3 dan 4)

Gunakan PATCH `/pesanan/{id}/status`.

| ID | Dari → ke | Harapan |
|----|-----------|---------|
| P1 | `menunggu_pembayaran` → `menunggu_konfirmasi` | 200 (tombol Bayar) |
| P2 | `menunggu_konfirmasi` → `dibayar` | 200 (konfirmasi admin) |
| P3 | `dibayar` → `diproses` → `dikirim` → `selesai` | masing-masing 200 |
| P4 | `selesai` → `diproses` | **409** dengan pesan dari server |
| P5 | `dibayar` → `dibatalkan` | 409 (pembatalan hanya dari dua status pertama) |
| P6 | `menunggu_pembayaran` → `dibatalkan` | 200; unit kembali `tersedia`, stok bertambah, I1 dan I3 lolos |
| P7 | Status ke dirinya sendiri | 409 |
| P8 | `status: "ngawur"` | 422 |
| P9 | `status_berikutnya` pada tiap status | Sama dengan tabel di `api-contract.md` 5.4 |

---

## 5. Lazy Load dan Katalog

| ID | Langkah | Hasil yang diharapkan | Hasil |
|----|---------|-----------------------|-------|
| L1 | GET `/produk?halaman=1&per_halaman=10` | 10 item, `id` naik | |
| L2 | GET `halaman=2&per_halaman=10` | 5 item (< 10 → akhir daftar) | |
| L3 | GET `halaman=3&per_halaman=10` | 200, `data: []` | |
| L4 | `per_halaman=0`, `halaman=abc` | 422 | |
| L5 | Di aplikasi: gulir sampai bawah | Halaman berikutnya dimuat otomatis; berhenti di akhir tanpa menampilkan keadaan kosong atau galat | |
| L6 | Di aplikasi: ganti kategori atau ketik pencarian | Daftar reset ke halaman 1 dan **mengirim ulang permintaan ke server** (periksa log server) | |
| L7 | Di aplikasi: kategori/pencarian tanpa hasil | Keadaan **kosong** (bukan galat) dengan saran | |

---

## 6. Aplikasi Flutter: Lima Jenis Galat (Bagian 11: butir 10; Kriteria 6)

Setiap galat harus **tampil berbeda** dan direkam di video dengan menyebut cara memicunya.

| ID | Jenis galat | Cara memicu | Tampilan yang diharapkan | Hasil |
|----|-------------|-------------|--------------------------|-------|
| E1 | Tidak ada sambungan | Hentikan `php artisan serve` (Ctrl+C) lalu buka/muat ulang halaman | Pesan sambungan gagal + tombol **Coba lagi** | |
| E2 | Batas waktu | Mode pesawat di emulator, atau tambahkan `sleep(15)` sementara pada satu endpoint (**hapus sesudahnya**) | Pesan "server tidak membalas" + **Coba lagi** (teks berbeda dari E1) | |
| E3 | 422 | Kirim form checkout dengan alamat kosong (dan lewati validator lokal bila perlu agar server yang menolak) | Pesan **per kolom** di bawah kolom, bukan dialog umum | |
| E4 | 409 | Pesan produk stok 0 (atau jumlah melebihi stok) | Pesan **dari server** pada layar yang sedang dibuka, tanpa pindah halaman | |
| E5 | 500 | Hentikan layanan MySQL di Laragon lalu muat daftar (alternatif: rute uji yang melempar galat, hanya di lingkungan lokal dan dihapus sebelum kumpul) | Pesan umum + **Coba lagi**, **tanpa** jejak galat | |
| E6 | Tombol coba lagi | Pulihkan server lalu tekan **Coba lagi** pada E1, E2, E5 | Data berhasil dimuat tanpa menutup aplikasi | |
| E7 | Tidak ada `e.toString()` di layar | Periksa seluruh lima tampilan di atas | Tidak ada teks teknis (SocketException, stack trace, SQLSTATE) | |

---

## 7. Aplikasi Flutter: Empat Keadaan Layar dan Halaman (Bagian 11: butir 11; Kriteria 2, 3, 7)

| ID | Halaman | Skenario | Harapan | Hasil |
|----|---------|----------|---------|-------|
| F1 | Semua halaman pemanggil API | Muat data | Indikator **memuat** tampil, tombol aksi mati selama memuat | |
| F2 | Keranjang | Keranjang kosong | Keadaan **kosong** ramah (saran kembali ke katalog), **bukan** galat atau layar putih | |
| F3 | Riwayat pesanan | `migrate:fresh` tanpa seeder pesanan, atau akun tanpa pesanan | Keadaan kosong, bukan galat | |
| F4 | Katalog | Produk habis | Penanda habis jelas, tombol tambah mati di katalog dan rincian produk | |
| F5 | Rincian produk | Produk dengan `deskripsi` null | Tidak crash; tampil pengganti yang wajar | |
| F6 | Rincian produk | `berat_gram` dan `garansi_bulan` | Tampil | |
| F7 | Keranjang | Ubah jumlah, hapus item | Subtotal berubah sesuai respons server; lencana ikon keranjang ikut berubah | |
| F8 | Keranjang | Tutup aplikasi lalu buka lagi | Isi keranjang tetap (dari server) | |
| F9 | Checkout | Ganti kurir | Ongkir dan total estimasi berubah, nilainya dari server | |
| F10 | Checkout | Isi benar, kirim | 201 → pindah ke rincian pesanan; nomor pesanan tampil | |
| F11 | Rincian pesanan | Tombol Bayar | Status berubah lewat PATCH (cek di basis data), bukan hanya tampilan | |
| F12 | Rincian pesanan | Item | Garansi dan nomor seri tiap unit tampil; harga = harga saat beli | |
| F13 | Rincian pesanan | Tombol kembali | Tumpukan halaman dibersihkan, kembali ke katalog | |
| F14 | Kelola produk | Tambah, ubah, hapus | Daftar menyegarkan diri setelah tiap operasi; hapus meminta **konfirmasi dialog** dahulu | |
| F15 | Kelola produk | Hapus produk yang ada di pesanan aktif | Pesan 409 dari server tampil, produk tetap | |
| F16 | Form produk | Kosongkan kolom wajib | Pesan 422 per kolom | |
| F17 | Daftar produk | Banyak data | Memakai `ListView.builder`/`GridView.builder` | |

---

## 8. Pemeriksaan Kode Statis (Bagian 11: butir 12, 13, 14)

Jalankan dari akar repositori (Git Bash atau terminal Laragon). Hasil yang diharapkan tertulis di kolom kanan.

| ID | Pemeriksaan | Perintah | Harapan |
|----|-------------|----------|---------|
| C1 | Tidak ada hitungan uang di Dart | `grep -rnE "(harga\|subtotal\|total\|ongkir)[A-Za-z_]*\s*[\*\+\-/]\|[\*\+]\s*(harga\|jumlah)" mobile/lib` | Tidak ada baris yang menghitung; tinjau manual hasil yang muncul |
| C2 | Tidak ada `.fold`/`reduce` untuk total | `grep -rnE "\.fold\|\.reduce\|\.sum" mobile/lib` | Tidak ada yang menjumlahkan harga/jumlah |
| C3 | Tidak ada `e.toString()` ke pengguna | `grep -rn "toString()" mobile/lib` | Tidak ada yang berujung ke `Text(...)` |
| C4 | Tidak ada `catch` kosong | `grep -rnE "catch *\([^)]*\) *\{ *\}" mobile/lib` | Tidak ada |
| C5 | Tidak ada `print` sisa | `grep -rnE "print\(\|debugPrint\(" mobile/lib` dan `grep -rnE "dd\(\|dump\(\|var_dump\|error_log" backend/app` | Tidak ada |
| C6 | Panggilan jaringan hanya di `LayananApi` | `grep -rnE "http\.(get\|post\|put\|patch\|delete)\|Uri\.parse" mobile/lib` | Hanya di berkas layanan |
| C7 | Tidak ada panggilan jaringan di `build` | Tinjau tiap `build()` pada halaman; panggilan awal ada di `initState` atau `FutureBuilder` | Terpenuhi |
| C8 | Timeout ada di tiap panggilan | `grep -rn "timeout" mobile/lib` | Tiap metode `LayananApi` memiliki `.timeout(...)` |
| C9 | Alamat server satu konstanta | `grep -rn "10.0.2.2\|192.168" mobile/lib` | Satu lokasi |
| C10 | Token dikirim di satu tempat | `grep -rn "Authorization" mobile/lib` | Satu lokasi |
| C11 | Kode mati dan komentar sisa | Telusuri `// TODO`, kode yang dikomentari, berkas tak terpakai (`flutter analyze`) | Bersih |
| C12 | Baris `throw`/`sleep` uji (G5, E2) sudah dibuang | `grep -rnE "throw new \\\\Exception\('uji'\)\|sleep\(" backend/app` | Tidak ada |
| C13 | Respons server tidak membocorkan galat | Atur `APP_DEBUG=true` lalu picu E5 | Tetap pembungkus JSON bersih (tidak ada jejak, tidak ada SQL) |
| C14 | Server tidak menjalankan hitungan harga di luar `ServisCheckout`/Resource | Tinjau manual | Perhitungan hanya di satu tempat |

---

## 9. Pengumpulan dan Repositori (Bagian 11: butir 1, 14–18)

| ID | Pemeriksaan | Harapan | Hasil |
|----|-------------|---------|-------|
| R1 | Buka repositori dari peramban lain/mode samaran, atau dosen diundang | Dapat dibuka | |
| R2 | `git ls-files \| grep -E "^backend/\.env$"` | Kosong (hanya `.env.example` ikut) | |
| R3 | `.env.example` tidak berisi kata sandi sebenarnya | Terpenuhi | |
| R4 | Clone ke folder baru, ikuti README langkah demi langkah | Backend dan Flutter berjalan | |
| R5 | `git shortlog -sne --all` | Tiap anggota ≥ 5 commit bermakna; tidak ada satu commit "final" raksasa | |
| R6 | README | Memuat **semua butir** yang diminta (nama/NIM/peran, domain + aturan bisnis, cara jalan backend, cara jalan Flutter + lokasi alamat server, alamat server + alasan, token/pelanggan, daftar endpoint + tautan dokumentasi, tautan video, catatan pemakaian AI) | |
| R7 | Video | Durasi ≤ 5 menit; memuat demonstrasi 5 galat dengan menyebut cara memicunya; tautan terbuka dari peramban lain | |
| R8 | PDF | Nama sesuai pola `PAPB-UTS_Kelompok-NN_Elektronik.pdf`; 6–10 halaman; 7 bagian lengkap; contoh berasal dari panggilan nyata | |
| R9 | Dokumentasi vs kode | Setiap endpoint di PDF ada di kode dan sebaliknya (termasuk endpoint ke-15) | |
| R10 | Setiap anggota membaca kode anggota lain minimal sekali | Terlaksana | |

---

## 10. Uji HP Fisik

| ID | Langkah | Harapan |
|----|---------|---------|
| H1 | `php artisan serve --host=0.0.0.0`; laptop dan HP satu jaringan; ganti konstanta alamat ke IP LAN laptop | Aplikasi memuat katalog |
| H2 | Pastikan `android:usesCleartextTraffic="true"` pada build debug | Tidak ada galat sambungan akibat HTTP |
| H3 | Firewall Windows mengizinkan port 8000 | Terhubung dari HP |
| H4 | Jalankan alur utama: katalog → keranjang → checkout → rincian pesanan | Berhasil seperti di emulator |

---

## 11. Uji Cepat 10 Menit (sebelum merekam video atau mengumpulkan)

1. `migrate:fresh --seed`, kueri I1–I7 → semua 0 baris.
2. Postman: A4 (kosong 200), A6 (404), A18 (409), A20 (422), A30 (401).
3. K1–K4 (checkout sukses + SQL).
4. D1 (kunci sama → satu pesanan).
5. G1–G2 (409 tidak mengubah stok).
6. P4 (status tidak sah 409) dan P6 (batal mengembalikan stok).
7. Aplikasi: E1–E5 satu per satu, F2 (keranjang kosong), L5 (lazy load).
8. Pemeriksaan C1–C6, C12.
9. Ulangi kueri I1–I7.

---

## 12. Peta ke Daftar Periksa PDF Bagian 11

| Butir daftar periksa dosen | Skenario |
|----------------------------|----------|
| Repositori dapat dibuka | R1 |
| `migrate --seed` sekali jalan di komputer bersih | S1 |
| ≥ 12 produk, 2 stok nol | S2–S4 |
| 3 kurir bertarif berbeda | S5 |
| Seluruh endpoint dipanggil dari Postman, sesuai dokumentasi | A1–A33 |
| Aturan bisnis domain diuji sampai server menolak | O1–O7 (ongkir dari berat), K5, G3 |
| Stok benar-benar berkurang setelah checkout | K2 |
| Checkout gagal di tengah tidak mengubah stok | G1–G6 |
| Checkout ditekan dua kali, satu pesanan | D1, D2, D5 |
| Lima jenis galat dicoba, tampilan berbeda | E1–E7 |
| Daftar kosong = keadaan kosong, bukan galat | F2, F3, L7 |
| Tidak ada panggilan jaringan di `build` | C7 |
| Tidak ada `print` sisa dan kode mati | C5, C11, C12 |
| `.env` tidak ikut terunggah | R2, R3 |
| README memuat semua butir | R6 |
| Video ≤ 5 menit, tautan terbuka | R7 |
| Nama PDF sesuai pola | R8 |
| Tiap anggota ≥ 5 commit | R5 |
| Tiap anggota membaca kode anggota lain | R10 |

---

## 13. Catatan Hasil Uji

| Tanggal | Penguji | Skenario yang dijalankan | Ringkasan hasil | Temuan / tindak lanjut |
|---------|---------|--------------------------|-----------------|------------------------|
| | | | | |
