# todo.md — Rencana Eksekusi untuk AI Coding (Zenvora)

> Dibaca dan dijalankan oleh Claude Code / Antigravity / opencode, **satu langkah per giliran**, berurutan mengikuti jalur kritis. Tidak memuat pembagian anggota: siapa pun yang menjalankan langkah wajib memahami hasilnya (lihat `agent.md` Bagian 6).
> Sebelum mulai: baca `agent.md`, lalu rujukan tiap langkah. Setiap langkah selesai hanya bila **kriteria selesai** terbukti oleh perintah verifikasi (jangan menyatakan selesai dari perkiraan).
> Tandai kotak `[x]` setelah terbukti. Tenggat internal: **Senin 9 Nov 2026**. Tanda ★ = jalur kritis (tidak boleh dilewati); ◇ = nilai tambah (kerjakan hanya bila semua ★ selesai).
> Setelah setiap langkah: tambah baris di `docs/log-ai.md`, commit dengan pesan Conventional Commits, lalu **langsung push ke `origin/main`** (aturan di `conventions.md` Bagian 7.3).

---

## Fase A — Fondasi proyek

### [x] A1 ★ Buat repositori dan kerangka proyek
- **Tujuan**: struktur `backend/`, `mobile/`, `docs/`, `README.md` kosong, `.gitignore`.
- **Berkas**: `backend/` (`composer create-project laravel/laravel backend`), `mobile/` (`flutter create mobile --org id.ac.itsk` atau nama bebas), `.gitignore` akar (`.env`, `vendor/`, `build/`, `.dart_tool/`), `docs/log-ai.md` (tabel kosong dari `agent.md` Bagian 7), `docs/postman/`.
- **Rujukan**: `architecture.md` Bagian 2, `conventions.md` Bagian 8.
- **Verifikasi**: `cd backend && php artisan --version`; `cd mobile && flutter --version`; `git ls-files | grep -E "(^|/)\.env$"` → kosong.
- **Selesai bila**: kedua proyek terbuat, `.env` terabaikan git.

### [ ] A2 ★ Konfigurasi Laravel dasar
- **Tujuan**: koneksi MySQL `zenvora`, zona waktu, rute api.
- **Berkas**: `.env` & `.env.example` (`DB_DATABASE=zenvora`, `APP_TIMEZONE=Asia/Jakarta`, `APP_DEBUG=false` pada contoh, `ZENVORA_TOKEN_PEMBELI`, `ZENVORA_LAMBAT_DETIK=0`, `ZENVORA_PAKSA_GALAT=false`), `config/zenvora.php` (kategori, token, flag demo), `php artisan install:api` (atau buat `routes/api.php` dan daftarkan di `bootstrap/app.php`), `config/app.php` timezone.
- **Rujukan**: `architecture.md` 2.1, `conventions.md` Bagian 8.
- **Verifikasi**: buat basis data `zenvora` (utf8mb4) lalu `php artisan migrate:status` tidak galat; `php artisan route:list` menampilkan prefiks `api`.
- **Selesai bila**: Laravel terhubung ke MySQL dan rute `api/*` aktif.

---

## Fase B — Basis data dan data awal

### [ ] B1 ★ Migrasi 8 tabel (urutan benar)
- **Berkas**: `database/migrations/` untuk `pelanggan`, `produk` (+ `softDeletes`), `kurir`, `metode_pembayaran`, `keranjang`, `pesanan`, `detail_pesanan`, `unit_produk` (urutan persis `database-schema.md` Bagian 3).
- **Rujukan**: `database-schema.md` Bagian 2–3 (tipe kolom, unique `(pelanggan_id, produk_id)` dan `(pelanggan_id, kunci_idempoten)`, indeks `(produk_id, status)`).
- **Verifikasi**: `php artisan migrate:fresh` sukses; `SHOW CREATE TABLE` pada `pesanan` dan `unit_produk` memuat unique/indeks yang diminta.
- **Selesai bila**: semua tabel dan kunci unik ada; tidak ada referensi melingkar.

### [ ] B2 ★ Model Eloquent
- **Berkas**: `app/Models/*` (8 model), tiap model `protected $table = '...'`, `$fillable`/`$guarded`, relasi (`Produk`↔`UnitProduk`, `Pesanan`↔`DetailPesanan`, `DetailPesanan`↔`UnitProduk`, dst.), `Produk` memakai `SoftDeletes`.
- **Verifikasi**: `php artisan tinker` → `\App\Models\Produk::count()` tidak galat meski kosong.
- **Selesai bila**: tidak ada galat nama tabel (`produks`).

### [ ] B3 ★ Enum dan layanan inti tanpa HTTP
- **Berkas**: `app/Enums/StatusPesanan.php` (7 nilai, `bolehPindahKe()`, `berikutnya()`), `app/Services/ServisOngkir.php`, `app/Services/ServisStok.php` (buat/tambah/hapus unit, sinkron `produk.stok`, penomoran seri `ZNV-P{kodeProduk 2 digit}-{urut4}`).
- **Rujukan**: `database-schema.md` Bagian 4–6, `api-contract.md` 5.1 dan 5.4.
- **Verifikasi**: uji di `tinker`: 1.000 g → 1 kg; 1.001 g → 2 kg; 1.910 g × 7.500 = 15.000; `StatusPesanan::from('selesai')->bolehPindahKe(...)` → false untuk semua.
- **Selesai bila**: rumus dan tabel status cocok persis dengan kontrak.

### [ ] B4 ★ Seeder
- **Berkas**: `database/seeders/` (`PelangganSeeder`, `KurirSeeder`, `MetodePembayaranSeeder`, `ProdukSeeder` + unit, `PesananContohSeeder`, `DatabaseSeeder` berurutan). Pesanan contoh dibuat **lewat logika checkout** (panggil `ServisCheckout` setelah C-fase, atau tunda langkah ini sampai C6 selesai lalu kembali).
- **Rujukan**: `database-schema.md` Bagian 7 (15 produk, dua stok nol, satu `tersedia=false`, dua `deskripsi` NULL; 3 kurir; 2 metode; 3 pesanan A/B/C).
- **Verifikasi**: `php artisan migrate:fresh --seed` sekali jalan tanpa galat; SQL invarian → 0 baris; `SELECT COUNT(*) FROM produk` = 15; stok akhir Redmi 7, Tab A9+ 5, Vivobook 3, LG 24" 5.
- **Catatan**: bila `ServisCheckout` belum ada, kerjakan seeder produk/kurir/metode/pelanggan dulu (B4a), lalu `PesananContohSeeder` setelah C6 (B4b).
- **Selesai bila**: seeder lolos di basis data kosong dan invarian bersih.

---

## Fase C — Backend inti

### [ ] C1 ★ Pembungkus, penangan galat global, middleware token
- **Berkas**: `app/Support/Respons.php`, `bootstrap/app.php` (`withExceptions`, `shouldRenderJsonWhen` untuk `api/*`), `app/Exceptions/BentrokException.php`, `TokenTidakValidException.php`, `app/Http/Middleware/AutentikasiTokenStatis.php` (token → `pelanggan` melalui kolom `token_statis`), `JsonResource::withoutWrapping()`.
- **Rujukan**: `api-contract.md` 1.1–1.3, `architecture.md` Bagian 4.
- **Verifikasi**: `curl` rute tak ada → JSON 404 berpembungkus; tanpa token → 401 JSON; `GET` pada rute POST → 405 JSON; `code` bertipe string.
- **Selesai bila**: tidak ada respons HTML pada kondisi apa pun, termasuk 404/405.

### [ ] C2 ★ Endpoint produk (#1–#5)
- **Berkas**: `ProdukController`, `SimpanProdukRequest`, `ProdukResource`, `routes/api.php`.
- **Rujukan**: `api-contract.md` 4.1–4.5, `database-schema.md` Bagian 4 (`POST/PUT` lewat `ServisStok`, `DELETE` soft delete + 409 untuk pesanan aktif).
- **Verifikasi (curl/Postman)**: daftar kosong via `?cari=zzz` → 200 `data: []`; `?kategori=tablet` → 3 item; `?halaman=2&per_halaman=10` → 5 item; produk 9999 → 404; POST tanpa nama → 422 per kolom; PUT stok naik/turun menjaga invarian; DELETE produk pada pesanan A → 409.
- **Selesai bila**: semua kode status pada tabel kontrak teramati; invarian 0 baris.

### [ ] C3 ★ Kurir, metode pembayaran, keranjang (#6–#10, #15)
- **Berkas**: `KurirController` (estimasi dari `ServisOngkir`), `MetodePembayaranController`, `KeranjangController`, `TambahKeranjangRequest`, `UbahKeranjangRequest`, resource terkait.
- **Rujukan**: `api-contract.md` 4.6–4.10, 4.15.
- **Verifikasi**: tambah produk sama dua kali → 1 baris (201 lalu 200); jumlah melebihi stok → 409 berpesan server; produk stok nol → 409; `jumlah=0` → 422; `GET /api/kurir` dengan keranjang Vivobook+Tab A9+ → ongkir 8.000/15.000/30.000; keranjang kosong → ketiga nilai 0.
- **Selesai bila**: subtotal, `total_jumlah`, estimasi ongkir semuanya dari server dan cocok kontrak.

### [ ] C4 ★ ServisCheckout + endpoint checkout (#11)
- **Berkas**: `ServisCheckout`, `CheckoutController`, `CheckoutRequest`, `RincianPesananResource`.
- **Rujukan**: `api-contract.md` 4.11 (9 langkah, **replay dicek sebelum validasi keranjang** dan diulang di dalam transaksi), `architecture.md` 3.1–3.2.
- **Verifikasi**: (1) checkout sukses → 201, stok berkurang di DB, unit `terjual`, keranjang kosong, `nomor_seri` terisi; (2) ulangi dengan kunci **sama** → 201 pesanan yang sama, jumlah pesanan tidak bertambah; (3) tanpa header kunci → 422; (4) stok kurang → 409 + `data.item_kurang`, stok tidak berubah; (5) paksa kegagalan di tengah (lempar exception setelah pengurangan unit, sementara) → rollback penuh, lalu hapus kode uji; (6) invarian 0 baris.
- **Selesai bila**: semua enam butir terbukti.

### [ ] C5 ★ Pesanan: daftar, rincian, ubah status (#12–#14)
- **Berkas**: `PesananController`, `ServisPesanan`, `UbahStatusRequest`, `RingkasanPesananResource`.
- **Rujukan**: `api-contract.md` 4.12–4.14, 5.4.
- **Verifikasi**: riwayat urut terbaru dulu; PATCH `menunggu_pembayaran → menunggu_konfirmasi` 200; `selesai → diproses` 409; status ngawur → 422; `dibatalkan` mengembalikan unit dan stok (invarian 0 baris); rincian pesanan lama tetap menampilkan harga saat beli setelah harga produk diubah.
- **Selesai bila**: 15 endpoint ada (`php artisan route:list --path=api` = 15 rute).

### [ ] C6 ★ Pesanan contoh di seeder (B4b) dan middleware demo
- **Berkas**: `PesananContohSeeder` (pesanan A `menunggu_pembayaran`, B `dibayar`, C `selesai` lewat `ServisCheckout` + `ServisPesanan`), `MiddlewareDemo` (`ZENVORA_LAMBAT_DETIK`, `ZENVORA_PAKSA_GALAT`).
- **Rujukan**: `database-schema.md` 7.4, `architecture.md` Bagian 8.
- **Verifikasi**: `migrate:fresh --seed` → 3 pesanan berstatus berbeda, invarian 0 baris; dengan flag demo `true`/`15` perilaku berubah, dengan nilai bawaan (`false`/`0`) tidak ada efek.
- **Selesai bila**: seeder lengkap dalam sekali jalan di basis data kosong.

---

## Fase D — Kerangka Flutter

### [ ] D1 ★ Konfigurasi, galat, model, `LayananApi`
- **Berkas**: `lib/config/konfigurasi.dart`, `lib/enums/keadaan_muat.dart`, `lib/exceptions/galat_api.dart`, `lib/models/*` (`fromJson` saja), `lib/services/layanan_api.dart` (15 metode lewat satu `_kirim`, timeout 10 dtk, token hanya di `_header()`), `pubspec.yaml` (`http`).
- **Rujukan**: `architecture.md` 5.2, `api-contract.md` 1.4 dan Bagian 2.
- **Verifikasi**: `flutter analyze` bersih; skrip uji sementara memanggil `daftarProduk()` ke server lokal dan mencetak jumlah item (hapus skrip setelahnya, tidak ada `print` tersisa).
- **Selesai bila**: tiap jenis galat dilempar sebagai tipe bertipe saat server mati (sambungan), lambat (batas waktu), 422, 409, 500.

### [ ] D2 ★ Widget bersama dan alur navigasi
- **Berkas**: `widgets/tampilan_galat.dart` (5 variasi), `tampilan_kosong.dart`, `lencana_keranjang.dart`, `penanda_habis.dart`, `kartu_produk.dart`, `lib/main.dart`, fungsi `formatRupiah(int)`.
- **Rujukan**: `architecture.md` 5.4 dan 5.6.
- **Verifikasi**: `flutter run` di emulator membuka Katalog tanpa galat.
- **Selesai bila**: aplikasi berjalan di emulator dengan `alamatServer = http://10.0.2.2:8000/api`.

---

## Fase E — Tujuh halaman (urut mengikuti alur belanja)

> Setiap halaman: empat `KeadaanMuat`, `mounted` setelah `await`, tombol **Coba lagi**, tanpa hitungan bisnis. Setelah tiap halaman jalankan grep di `conventions.md` Bagian 6.

### [ ] E1 ★ Katalog (+ lencana keranjang)
- **Rujukan**: `prd.md` 6.1, `api-contract.md` 4.1 dan 6.
- **Verifikasi**: daftar `GridView.builder`/`ListView.builder`; kategori dan pencarian **mengirim ulang** permintaan (periksa log server); produk stok nol/`tersedia=false` bertanda habis dan tombolnya mati; hasil pencarian kosong → keadaan **kosong** bukan galat.

### [ ] E2 ★ Rincian produk
- **Verifikasi**: menampilkan `berat_gram`, `garansi_bulan`, `deskripsi` null → teks pengganti tanpa crash (produk #9/#12); tombol tambah mati bila habis; tambah berhasil → ke Keranjang; stok nol/jumlah berlebih → pesan 409 dari server di layar yang sama.

### [ ] E3 ★ Keranjang
- **Verifikasi**: ubah jumlah dan hapus memanggil server dan subtotal berubah dari server; keranjang kosong → keadaan kosong ramah dengan tombol kembali ke katalog; tutup-buka aplikasi → isi tetap.

### [ ] E4 ★ Checkout
- **Rujukan**: `architecture.md` 5.5, `api-contract.md` 4.10–4.11.
- **Verifikasi**: `Form` + validator (pesan Indonesia); ganti kurir → ongkir dan total estimasi berubah (dari `GET /api/kurir`, tanpa hitungan Dart); tombol mati saat permintaan berjalan; `_kunci` dibuat sekali dan dipakai ulang saat **Coba lagi**; 422 → pesan per kolom; 409 → pesan server tanpa pindah halaman; 201 → `pushReplacement` ke Rincian pesanan. Ketuk dua kali cepat → satu pesanan (periksa DB).

### [ ] E5 ★ Rincian pesanan
- **Verifikasi**: nomor pesanan, status, item dengan harga saat beli, garansi, `nomor_seri` per unit, total, metode bayar; satu tombol per nilai `status_berikutnya` (Bayar → `menunggu_konfirmasi`, konfirmasi → `dibayar`, dst.) mengirim PATCH nyata; 409 ditampilkan; tombol "Kembali ke katalog" memakai `pushAndRemoveUntil`.

### [ ] E6 ★ Riwayat pesanan
- **Verifikasi**: urut terbaru → terlama; ketuk baris ke Rincian; tanpa pesanan → keadaan kosong.

### [ ] E7 ★ Kelola produk + Form produk
- **Verifikasi**: tambah/ubah/hapus lewat dialog konfirmasi hapus; daftar menyegarkan dari server setelah tiap operasi; 422 per kolom di form; 409 hapus produk pada pesanan aktif → pesan server, tetap di daftar; kembali dengan `pop(true/false)`.

---

## Fase F — Ketahanan dan nilai tambah

### [ ] F1 ★ Lima galat terbukti di aplikasi
- **Rujukan**: `architecture.md` 5.4 dan Bagian 8.
- **Verifikasi**: picu satu per satu dan catat tampilan: (1) hentikan `php artisan serve`; (2) `ZENVORA_LAMBAT_DETIK=15`; (3) alamat kosong → 422 per kolom; (4) produk stok nol → 409; (5) `ZENVORA_PAKSA_GALAT=true` → 500 pesan umum tanpa jejak. Kelimanya tampil **berbeda**; semua halaman daftar punya Coba lagi. Kembalikan flag `.env` ke nilai bawaan.

### [ ] F2 ◇ Lazy load Katalog
- **Rujukan**: `architecture.md` 5.7, `api-contract.md` 4.1.
- **Verifikasi**: `per_halaman=10` memuat 10 lalu 5 item saat digulir; berhenti tanpa menampilkan "kosong" setelah halaman terakhir; ganti kategori/cari mereset ke halaman 1 (tiket usang diabaikan); galat halaman lanjutan tidak menghapus daftar.

### [ ] F3 ★ Perapian kode
- **Verifikasi**: semua perintah di `conventions.md` Bagian 6 lolos; tidak ada `print`, kode mati, atau berkas tak terpakai; `flutter analyze` bersih; rute API = 15.

---

## Fase G — Pengujian dan bukti

### [ ] G1 ★ Jalankan seluruh skenario `testing.md`
- **Verifikasi**: kolom "hasil nyata" terisi; setiap kegagalan diperbaiki lalu diuji ulang; SQL invarian 0 baris setelah seluruh uji.

### [ ] G2 ★ Uji di HP fisik
- **Berkas**: ubah `alamatServer` ke IP LAN; `php artisan serve --host=0.0.0.0`; manifes debug `usesCleartextTraffic`.
- **Selesai bila**: alur belanja utuh berjalan di HP; emulator tetap tersedia sebagai cadangan.

### [ ] G3 ◇ Koleksi Postman
- **Berkas**: `docs/postman/zenvora.postman_collection.json` (15 endpoint + variabel `{{base_url}}`, `{{token}}`, `{{kunci}}`; contoh 422/409/idempoten).
- **Selesai bila**: ekspor memuat semua 15 request dan seluruhnya berhasil dijalankan berurutan pada basis data hasil seeder.

---

## Fase H — Pengumpulan

### [ ] H1 ★ Dokumentasi API (PDF 6–10 halaman)
- **Berkas**: `docs/PAPB-UTS_Kelompok-NN_Elektronik.pdf` (nomor kelompok **[PERLU DIKONFIRMASI]**).
- **Rujukan**: `submission.md`, `api-contract.md`, PDF tugas Bagian 7 (tujuh bagian).
- **Aturan**: contoh permintaan/balasan untuk 5 endpoint inti (daftar produk, tambah keranjang, lihat keranjang, checkout, rincian pesanan) **diambil dari panggilan nyata**, bukan dari contoh RANCANGAN; `message` dan kunci sama persis dengan respons.

### [ ] H2 ★ README sembilan butir
- **Rujukan**: `submission.md`. Isi nama kelompok/anggota/NIM/peran (oleh pengguna), domain + aturan ongkir, cara menjalankan backend dan Flutter (tempat ubah alamat), alamat server + alasan, token statis, daftar 15 endpoint + tautan dokumentasi, tautan video, catatan pemakaian AI dari `docs/log-ai.md`, serta pustaka pihak ketiga dan mekanisme flag demo galat.

### [ ] H3 ★ Video demo ≤ 5 menit dan daftar periksa akhir
- **Rujukan**: `submission.md` (naskah per adegan, stopwatch).
- **Verifikasi**: lima galat + cara memicunya disebut; tautan video dibuka dari peramban lain; seluruh daftar periksa PDF tugas Bagian 11 tercentang; setiap anggota ≥ 5 commit atas namanya; `.env` tidak ada di repositori.

---

## Urutan Ringkas dan Estimasi Kasar

| Hari | Target |
|------|--------|
| Sabtu 7 Nov | A1–A2, B1–B3, B4a, C1–C6 (backend lengkap + seeder), D1–D2 |
| Minggu 8 Nov | E1–E7, F1, F3, G1; F2 bila ★ beres |
| Senin 9 Nov | G2, G3 (bila sempat), H1–H3, pengumpulan |

Bila waktu habis, **buang ◇ lebih dulu** (F2, G3). Jangan mengorbankan C4, E4, F1: ketiganya menentukan Kriteria 3, 5, dan 6.

## Catatan Eksekusi

- Backend selalu didahulukan; Flutter baru dikerjakan setelah endpoint terkait terbukti lewat curl/Postman.
- Bila hasil verifikasi gagal, jangan lanjut: perbaiki, ulangi verifikasi, laporkan apa adanya.
- Bila kontrak harus berubah, perbarui `api-contract.md` lebih dulu dan minta persetujuan pengguna.
