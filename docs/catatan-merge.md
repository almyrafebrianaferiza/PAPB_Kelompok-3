# Catatan Eksekusi: Merge Zenvora (7 Nov 2026)

Tujuan: memindahkan proyek Zenvora dari hasil ekspor AI Studio
(`C:\Users\ADMIN\Downloads\zenvora---toko-online-elektronik-&-gawai (1)`)
ke folder utama `C:\Users\ADMIN\Pbap-uts` (backend & mobile), lalu commit + push.

Keputusan user sebelum eksekusi:
1. Pindah + rekonsiliasi mobile langsung (sampai `flutter analyze` bersih).
2. 3 migrasi framework (users, cache, jobs) **dipertahankan**.
3. README ekspor (NIM fiktif) **tidak dipindah**.

## Hasil analisis (ringkas)

### Backend — cocok
- 15 rute persis api-contract; wrapper `Respons` seragam (code string, errors hanya 422).
- `ServisCheckout`: replay sebelum validasi, recheck di tx, lockForUpdate urut id, 409 item_kurang.
- 8 migrasi domain urut, 5 seeder + urutan benar, 15 produk, `.env.example` sesuai konvensi §8.

### Backend — masalah (B1–B6)
- B1 `app/Http/Controllers/Controller.php` hilang di ekspor → dipertahankan punya scaffold.
- B2 skeleton Laravel hilang (artisan, bootstrap/, config/, public/, storage/) → merge ke scaffold, bukan ganti.
- B3 composer.json ekspor ^11.0 → pakai scaffold ^13.40.
- B4 belum ada global exception handler (404/405/500 non-wrapper) → tunda (izin terpisah).
- B5 routes/api.php butuh `php artisan install:api`.
- B6 MiddlewareDemo pakai `env()` langsung → tunda (bersama A2).

### Mobile — masalah (M1–M3)
- M1 9 nama method screens ≠ `layanan_api.dart` (contoh: `ambilKatalog` vs `daftarProduk`, `buatPesanan` vs `checkout`).
- M2 `main.dart` memanggil konstruktor `LayananApi(basisUrl:, tokenStatis:)` + kelas `Konfigurasi` yang tidak ada.
- M3 pelanggaran H1: `checkout_page.dart` baris ~104/111/312 menghitung ongkir/total di Dart;
  GET /api/kurir sudah mengirim `ongkir` + `total_estimasi` (model `Kurir` sudah siap).
- `checkout_page` kirim `noTelepon`/`catatan` di luar kontrak → dihapus.
- Ekspor `android/` hanya 3 file parsial → pakai scaffold. Tanpa `test/`, `analysis_options.yaml` → pakai scaffold.

### Tidak dipindah
`src/`, `server/`, `public/`, `package.json`, `vite*`, `tsconfig`, `.aistudio`,
clone kosong `PAPB_Kelompok-3/`, README ekspor, `docs/` ekspor (kosong).

## Log eksekusi (7 Nov 2026)

- [x] Catatan ini dibuat.
- [x] Backend: routing API ditambahkan di `bootstrap/app.php` (`withRouting(api: ...)`
      tanpa `install:api`/Sanctum — token via middleware `TokenStatis`) + salin berkas
      (Controllers/Api, 8 model domain, 8 migrasi, 6 seeder, Requests/Middleware/Services/
      Support/Enums/Exceptions, `routes/api.php`, `.env.example`).
- [x] Backend: `route:list --path=api` = 15 rute persis kontrak; `migrate:fresh --seed`
      sukses (produk 15, pelanggan 1, kurir 3, metode 2, pesanan 3,
      token `zenvora-dev-token-2026`); smoke in-proses 200 & 401 = wrapper `Respons` ✓.
- [x] Backend: `laravel/boost` dipasang sebagai dev dependency + `boost:install`
      (AGENTS.md, CLAUDE.md, skills, .mcp.json).
- [x] Mobile: salin `lib/` (24 file) + `pubspec.yaml`; `test/widget_test.dart` &
      `pubspec.lock` ekspor dihapus; `flutter pub get` sukses; scaffold `android/` & `test/` utuh.
- [x] Mobile: rekonsiliasi M1–M3 + H1; enum `KeadaanMuat.galat`; konstana top-level
      `konfigurasi.dart`; idempoten nullable hex32; kategori 5 nilai kontrak;
      `per_halaman: 50` di kelola (batas backend); hapus SKU/gambar/`noTelepon`/`catatan`.
- [x] Mobile: `flutter analyze` awal 151 issue (109 error) → **No issues found (0)**.
- [x] Commit + push (3 commit: `feat(backend)`, `feat(mobile)`, `docs(merge)`).

## Lanjutan 7 Nov 2026 — A2, B6, C1 (B4 internal)

- [x] `config/zenvora.php` (kategori 5 nilai, token pembeli, flag demo) + timezone
      `Asia/Jakarta` di `config/app.php`; `MiddlewareDemo` & `SimpanProdukRequest` &
      `PelangganSeeder` kini membaca config, `env()` tinggal di file config saja.
- [x] `withExceptions` global: 404, 405, 422 (jaring pengaman), 409 `BentrokException`
      (bawa `data`), 401 `TokenTidakValidException`, 500 `Throwable` (pesan umum).
- [x] `.env` lokal = Laragon MySQL (`zenvora`, utf8mb4, root/kosong), `APP_DEBUG=true`
      untuk pengembangan (contoh `.env.example` tetap `false`); DB `zenvora` dibuat,
      `key:generate`, `migrate:fresh --seed` sukses; `database.sqlite` lama dihapus.
- [x] Smoke test (server :8000) — semua balasan **wrapper JSON**:
      200 daftar produk, 401 tanpa token, 404 endpoint tak ada, 405 GET di rute POST,
      422 POST kosong (errors per kolom), 409 `selesai→diproses`, 422 status ngawur,
      500 header `X-Demo-Error`, 500 Throwable saat DB mati (APP_DEBUG=true, tanpa jejak
      SQL) — lolos uji C13; setelah pulih `.env` → 200 lagi.

## Temuan saat eksekusi

- B5 selesai tanpa `install:api`: cukup `api: __DIR__.'/../routes/api.php'` di
  `withRouting` — kontrak tidak memakai Sanctum.
- `PUT /api/keranjang/{id}` membalas **item** yang diubah, bukan keranjang penuh →
  layar keranjang memuat ulang `ambilKeranjang()` setelah update jumlah agar
  subtotal/total ikut segar dari server (H1).
- `GET /api/produk` tidak punya field `total` → halaman habis bila
  `length < per_halaman` (katalog: halaman 1, `per_halaman: 10`).
- `POST /api/checkout` 201 = objek rincian 2.6 **tanpa wrapper** → checkout
  `pushReplacement` ke `RincianPesananPage(idPesanan: respon.id)` + snackbar
  `respon.nomorPesanan`.
- Backend menolak 409 bila jumlah > stok / produk `!tersedia` (termasuk saat update
  keranjang); dialog 409 checkout tetap di layar checkout (tombol "Tutup").
- 404/405/500 masih format default Laravel (B4) — tertunda, izin terpisah.
