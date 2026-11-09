# Toko Elektronik & Gawai (Laravel REST API + Flutter)

Tugas Pengganti UTS PAPB dan Sistem Terdistribusi. Domain: **Elektronik dan Gawai** (Kelompok 3).

## 1. Anggota
| Nama | NIM |
|---|---|
|Aini Nur Azizah | 241020003| 
|Anisa Kholifatul | 241020012|
|Inas Hasna Mufida| 241020012|
|Maylany Helena Pratama Putri| 241020014|
|Ahmad Dio | 2410200|
|Almyra Febriana Feriza | 24102054|
|M Mardiansyah | 24102037| 

## 2. Domain dan aturan bisnis
Atribut khas: `berat_gram`, `garansi_bulan`, tabel `unit_produk` (nomor seri per unit).
Aturan bisnis: ongkos kirim dihitung server = `tarif_dasar + ceil(total_berat/1000) x tarif_per_kg`.
Server menolak checkout (409) bila total berat melebihi batas kurir (`max_berat_gram`).

## 3. Menjalankan backend (butuh PHP >= 8.2, Composer, MySQL/XAMPP)
```bash
composer create-project laravel/laravel backend      # lewati bila folder backend sudah berisi proyek Laravel
# salin isi folder backend/ dari paket ini ke dalam proyek Laravel tersebut (timpa bila ditanya)
cd backend
copy .env.example .env      # Windows (Linux/Mac: cp)
# buat database kosong "toko_elektronik" di phpMyAdmin
composer install
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```
Uji cepat: buka http://127.0.0.1:8000/api/produk // ini masih blm tau

## 4. Menjalankan Flutter (butuh Flutter >= 3.22)
```bash
flutter create mobile            # lewati bila sudah ada
# ganti folder mobile/lib dengan lib/ dari paket ini
cd mobile
flutter pub add http
flutter run
```
Android: pada `android/app/src/main/AndroidManifest.xml` tambahkan
`<uses-permission android:name="android.permission.INTERNET"/>` (sebelum `<application>`) dan
`android:usesCleartextTraffic="true"` di dalam tag `<application ...>`.
Alamat server diubah di **`mobile/lib/konstanta.dart`** (`alamatServer`).

## 5. Alamat server
Emulator Android: `http://10.0.2.2:8000/api` (10.0.2.2 = laptop; `localhost` di emulator menunjuk emulator itu sendiri).
HP fisik: jalankan `php artisan serve --host=0.0.0.0` lalu pakai IP laptop, mis. `http://192.168.1.10:8000/api`.

## 6. Identitas pelanggan
Statis: `pelanggan_id = 1` (header `X-Pelanggan-Id`, dikirim dari satu tempat: `LayananApi._header()`).

## 7. Endpoint (15)
| Metode | Jalur | Keterangan |
|---|---|---|
| GET | /api/produk | `?kategori=` `?cari=`; 200 meski kosong |
| GET | /api/produk/{id} | 404 bila tidak ada |
| POST | /api/produk | 201 / 422 |
| PUT | /api/produk/{id} | 200 / 404 / 422 |
| DELETE | /api/produk/{id} | 200 / 404 / 409 (dipakai pesanan aktif) |
| GET | /api/keranjang | subtotal, berat; `?kurir_id=` menambah ongkir dan total |
| POST | /api/keranjang | 201 / 409 stok kurang / 422 |
| PUT | /api/keranjang/{id} | 200 / 409 / 422 (jumlah <= 0) |
| DELETE | /api/keranjang/{id} | 200 / 404 |
| GET | /api/kurir | kurir dan tarif |
| GET | /api/metode-pembayaran | tambahan: tunai_di_tempat, transfer_manual |
| POST | /api/checkout | header `X-Kunci-Idempoten` wajib; 201 / 409 / 422 |
| GET | /api/pesanan | terbaru dulu |
| GET | /api/pesanan/{id} | item dengan harga saat pembelian dan nomor seri |
| PATCH | /api/pesanan/{id}/status | 200 / 409 (perpindahan tidak sah) / 422 |
