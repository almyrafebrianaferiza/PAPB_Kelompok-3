# Zenvorā — Toko Elektronik & Gawai (Laravel REST API + Flutter)

Tugas Pengganti UTS PAPB dan Sistem Terdistribusi — **Kelompok 3**.

## 1. Anggota kelompok Zenvora

| Nama | NIM | Peran |
|---|---|---|
| Aini Nur Azizah | 241020003 | Dokumentasi |
| Annisa Kholifatul | 241020005 | Dokumentasi |
| Inas Hasna Mufida | 241020012 | Laporan |
| Maylany Helena Pratama Putri | 241020014 | ER Diagram dan dokumentasi|
| Ahmad Dio | 2410200 | Mobile, pengujian, dokumentasi teknis |
| Almyra Febriana Feriza | 24102054 | Mobile, Dokumentasi dan README |
| M Mardiansyah | 24102037 | Backend, integrasi mobile, pengujian |

## 2. Domain dan aturan bisnis

Domain: toko online khusus perangkat elektronik dan gawai (kategori `gadget`, `laptop`, `tv`, `monitor`, `tablet`).

Aturan bisnis khas: ongkos kirim dihitung **di server** dari total berat keranjang, bukan tarif tetap:

```text
ongkir = tarif_dasar + ceil(total_berat_gram / 1000) × tarif_per_kg
```

Server menolak checkout dengan **409** bila total berat melebihi `max_berat_gram` kurir. Flutter hanya menampilkan angka yang dikirim server; tidak ada perhitungan harga, subtotal, total, berat, atau stok di Dart.

## 3. Menjalankan backend

Prasyarat: PHP >= 8.3, Composer, dan MySQL/XAMPP.

```bash
cd backend
composer install
copy .env.example .env      # Linux/Mac: cp .env.example .env
php artisan key:generate
# Buat database MySQL kosong bernama "zenvora" (utf8mb4) di phpMyAdmin
php artisan migrate:fresh --seed
php artisan serve
```

Uji cepat:

```bash
curl -H "Authorization: Bearer zenvora-dev-token-2026" http://127.0.0.1:8000/api/produk
```

Berkas `.env` asli tidak di-commit; yang ada di repositori hanya `.env.example`.

## 4. Menjalankan aplikasi Flutter

Prasyarat: Flutter >= 3.22.

```bash
cd mobile
flutter pub get
flutter run --dart-define=ALAMAT_SERVER=http://10.0.2.2:8000/api
```

Alamat server diubah di **`mobile/lib/config/konfigurasi.dart`** (nilai default), atau lewat `--dart-define=ALAMAT_SERVER=...` tanpa mengubah kode. Contoh untuk Chrome/desktop:

```bash
flutter run -d chrome --dart-define=ALAMAT_SERVER=http://127.0.0.1:8000/api
```

Android: `android:usesCleartextTraffic="true"` sudah aktif di `mobile/android/app/src/main/AndroidManifest.xml`. Untuk build release, pastikan `<uses-permission android:name="android.permission.INTERNET"/>` juga ada di manifest utama.

## 5. Alamat server pengembangan dan alasannya

- Emulator Android: `http://10.0.2.2:8000/api` — `10.0.2.2` menunjuk host laptop; `localhost` di emulator menunjuk emulator itu sendiri.
- Chrome/desktop: `http://127.0.0.1:8000/api`.
- HP fisik: jalankan `php artisan serve --host=0.0.0.0`, lalu pakai IP LAN laptop, misalnya `http://192.168.1.10:8000/api`.

## 6. Identitas pelanggan dan token statis

Semua permintaan mengirim header:

```http
Authorization: Bearer zenvora-dev-token-2026
```

Server memetakan token tersebut ke `pelanggan_id = 1`. Header dibentuk hanya di satu tempat: `mobile/lib/services/layanan_api.dart` pada `_header()`. Token ini token pengembangan untuk tugas, bukan rahasia produksi.

## 7. Daftar endpoint (15)

| Metode | Jalur | Keterangan |
|---|---|---|
| GET | `/api/produk` | `?kategori=` `?cari=` `?halaman=` `?per_halaman=`; tetap 200 saat kosong |
| GET | `/api/produk/{id}` | 200 / 404 |
| POST | `/api/produk` | 201 / 422 |
| PUT | `/api/produk/{id}` | 200 / 404 / 422; `stok` = target jumlah unit |
| DELETE | `/api/produk/{id}` | 200 / 404 / 409 bila dipakai pesanan aktif |
| GET | `/api/keranjang` | item, `total_jumlah`, `subtotal` dari server |
| POST | `/api/keranjang` | 201 / 200 bila sudah ada / 409 stok kurang / 422 |
| PUT | `/api/keranjang/{id}` | 200 / 409 / 422 (jumlah <= 0) |
| DELETE | `/api/keranjang/{id}` | 200 / 404 |
| GET | `/api/kurir` | daftar kurir + estimasi ongkir dari berat keranjang |
| POST | `/api/checkout` | header `X-Kunci-Idempoten` wajib; 201 / 409 / 422 |
| GET | `/api/pesanan` | riwayat terbaru ke terlama |
| GET | `/api/pesanan/{id}` | rincian + harga saat beli + nomor seri |
| PATCH | `/api/pesanan/{id}/status` | 200 / 404 / 409 perpindahan tidak sah / 422 |
| GET | `/api/metode-pembayaran` | 200 |

Dokumentasi kontrak lengkap: [`api-contract (1).md`](docs/Perancangan/api-contract%20%281%29.md). Koleksi Postman: `docs/postman/zenvora.postman_collection.json`.

## 8. Video demo

Tautan video demo: **(menyusul)**.

## 9. Catatan pemakaian AI, pustaka, dan flag demo

- Pemakaian AI dicatat per berkas/fungsi di [`docs/log-ai.md`](docs/log-ai.md).
- Pustaka pihak ketiga: `http` (klien HTTP), `intl` (format Rupiah), dan font **Poppins** (SIL Open Font License, lihat `mobile/assets/fonts/OFL.txt`).
- Flag demo galat di backend: `ZENVORA_LAMBAT_DETIK=15` untuk simulasi batas waktu dan `ZENVORA_PAKSA_GALAT=true` untuk simulasi 500. Nilai bawaan `0` dan `false`.
- Pemeriksaan cepat: `cd mobile && flutter analyze`; tes F2: `flutter test test/uji_f2_katalog_test.dart`. Tes integrasi E1–E7 dan F1 ada di `mobile/test/`.

## 10. Web Admin (Seller Panel)

Selain aplikasi mobile untuk pembeli, backend Laravel menyediakan panel penjual berbasis web (Blade) untuk memproses pesanan dan mengelola katalog.

```bash
cd backend
php artisan migrate
php artisan storage:link
php artisan serve
# Buka http://127.0.0.1:8000/admin
```

Kredensial awal (dapat diubah melalui `.env` pada `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `ADMIN_NAMA`):

```text
Email    : admin@zenvora.test
Password : zenvora2026
```

Fitur panel admin:

- **Dashboard**: omzet selesai, pesanan perlu diproses, produk aktif, dan stok kritis.
- **Pesanan Masuk**: filter status, rincian pesanan + nomor seri, konfirmasi pembayaran, transisi status sesuai state machine, serta input/perbarui nomor resi.
- **Katalog Produk**: CRUD produk, unggah gambar produk, varian multi-SKU (RAM/penyimpanan/warna), sinkronisasi stok dengan unit fisik.
- **Unit & Serial**: pemantauan nomor seri (IMEI/SN) dan penandaan unit rusak/tersedia.

Panel admin memakai sesi web + CSRF dan terpisah dari 15 endpoint API mobile. Rancangan lengkap ada di [`docs/admin/`](docs/admin/).
