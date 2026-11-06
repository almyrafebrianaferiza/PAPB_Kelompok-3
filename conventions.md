# Konvensi Kode dan Kerja — Zenvora

> Pendamping `architecture.md`. Dokumen ini berisi aturan yang **bisa dicek**: penamaan, larangan keras dari dosen, perintah pemeriksaan otomatis, format commit, dan aturan berkas. Dibaca oleh anggota dan oleh AI coding (lihat `agent.md`).

---

## 1. Bahasa dan Penamaan

Bahasa kerja: **Bahasa Indonesia** untuk dokumen, nama tabel/kolom/jalur API, pesan galat, pesan validasi, dan komentar. Istilah teknis baku boleh Inggris (`controller`, `middleware`, `widget`, `timeout`).

| Objek | Gaya | Contoh |
|-------|------|--------|
| Tabel, kolom DB | `snake_case`, Indonesia, tunggal | `unit_produk`, `berat_gram` |
| Kunci JSON | `snake_case`, sama persis dengan kolom/kontrak | `harga_satuan`, `status_berikutnya` |
| Jalur API | huruf kecil, Indonesia | `/api/keranjang`, `/api/metode-pembayaran` |
| Kelas PHP | `PascalCase` | `ServisCheckout`, `BentrokException` |
| Metode/variabel PHP | `camelCase` | `bolehPindahKe()`, `$idProduk` |
| Berkas Dart | `snake_case.dart` | `layanan_api.dart` |
| Kelas Dart | `PascalCase` | `KatalogPage`, `SambunganGagalException` |
| Variabel/metode Dart | `camelCase` | `_sedangKirim`, `daftarProduk()` |
| Konstanta Dart | `camelCase` | `alamatServer`, `batasWaktu` |
| Enum | tipe `PascalCase`, nilai `camelCase` (Dart) / `snake_case` (string di DB/JSON) | `KeadaanMuat.galat`, `menunggu_pembayaran` |
| Halaman Flutter | akhiran `Page` | `CheckoutPage` |
| Kelas layanan PHP | awalan `Servis` | `ServisOngkir` |

Aturan tambahan:
- Model Eloquent **wajib** `protected $table = 'nama_tunggal';` (Laravel menjamakkan dengan kaidah Inggris).
- Tidak ada singkatan samar (`prd`, `tmp`, `x1`). Nama menjelaskan isi.
- Satu kelas publik utama per berkas; nama berkas = nama kelas.

---

## 2. Aturan Keras dari Dokumen Tugas (dinilai langsung)

| # | Aturan | Dampak bila dilanggar |
|---|--------|-----------------------|
| H1 | Tidak ada hitungan harga, subtotal, total, ongkir, berat, atau ketersediaan di Dart | Kriteria 5 skor 1 |
| H2 | Tidak ada pemanggilan jaringan di `build()` | Kriteria 7 skor 1 |
| H3 | Tidak menampilkan `e.toString()` ke pengguna | Kriteria 6 skor 1 |
| H4 | Tidak ada `catch` kosong | Kriteria 6 skor 1 |
| H5 | Lima galat memakai tampilan berbeda (bukan satu pesan untuk semua) | Kriteria 6 turun |
| H6 | Semua pemanggilan API hanya di `LayananApi` | Kriteria 7 turun ke 3 |
| H7 | Daftar memakai `ListView.builder` / `GridView.builder`, bukan `Column` berisi semua produk | Kriteria 2 turun |
| H8 | Filter/cari mengirim ulang permintaan ke server | Kriteria 2 skor 3 |
| H9 | Daftar kosong = keadaan `kosong`, bukan `galat` | Kriteria 7 skor 2 |
| H10 | Setiap respons Laravel memakai pembungkus seragam; tidak ada HTML atau galat SQL mentah | Kriteria 4 skor 3, Kriteria 6 |
| H11 | Endpoint di kode = endpoint di dokumentasi (15), tidak lebih, tidak kurang | Kriteria 4 skor 2 |
| H12 | Tidak ada `print`/`debugPrint`/`var_dump`/`dd()` sisa, tidak ada kode mati | Daftar periksa Bagian 11 |
| H13 | `.env` asli tidak masuk repositori | Daftar periksa Bagian 11 |
| H14 | Tidak memakai Provider/Riverpod/Bloc; hanya `setState`, constructor, callback | Tidak menambah nilai, wajib dijelaskan bila dipakai |

---

## 3. Aturan Flutter

### 3.1 Struktur halaman
- Setiap halaman yang memanggil API memiliki `KeadaanMuat _keadaan` dan, bila galat, `GalatApi? _galat`.
- Panggilan awal di `initState()` (atau `FutureBuilder`), **tidak pernah** di `build()`.
- Setelah setiap `await` di dalam `State`, cek `if (!mounted) return;` sebelum `setState`.
- `dispose()` membersihkan `TextEditingController`, `ScrollController`, dan `Timer`.
- `build()` hanya membaca field dan menyusun widget. Tidak ada `await`, tidak ada `http`, tidak ada perhitungan angka bisnis.

### 3.2 Penanganan galat
- Tangkap tipe spesifik: `on GalatApi catch (e)`. Pengecualian tak terduga (bug) dibiarkan terlihat saat pengembangan; jangan ditelan.
- Pesan ke pengguna berasal dari: (a) `message` server untuk 409/422, atau (b) teks tetap per jenis galat. Tidak ada `'$e'` dan `e.toString()` di UI.
- 422 → `errorText` per kolom form. 409 → pesan server di layar yang sama. Sambungan/batas waktu/500 → `TampilanGalat` dengan tombol **Coba lagi**. 404 → `TampilanKosong`.

### 3.3 Model dan data
- Model hanya `fromJson`; tanpa metode hitung. `deskripsi` bertipe `String?`.
- Tipe sesuai kontrak: `harga`, `stok`, `berat_gram`, `garansi_bulan` = `int`; `tersedia` = `bool`.
- Menampilkan rupiah (format "Rp 8.499.000") **boleh** di Flutter karena hanya pemformatan satu nilai dari server. Satu fungsi `formatRupiah(int)` di satu berkas; tidak boleh menjumlah beberapa nilai.

### 3.4 Gaya
- `flutter analyze` harus bersih (0 isu) sebelum setiap commit ke `main`.
- `dart format .` sebelum commit.
- Widget yang dipakai ≥ 2 halaman dipindah ke `widgets/`.
- `const` pada widget statis bila memungkinkan.

---

## 4. Aturan Laravel

- Controller tipis: validasi lewat `FormRequest`, logika bisnis di `Services/`, bentuk JSON di `Resources/`, pembungkus lewat `Respons`.
- **Satu-satunya** tempat mengubah `produk.stok` dan `unit_produk`: `ServisStok`. Tidak ada controller yang menulisnya langsung.
- **Satu-satunya** tempat menghitung subtotal/berat/ongkir/total: `ServisOngkir`.
- Aturan perpindahan status hanya di `StatusPesanan::bolehPindahKe()`; `status_berikutnya` dibentuk dari enum yang sama.
- Setiap operasi yang menulis lebih dari satu tabel memakai `DB::transaction`.
- Penguncian `lockForUpdate()` selalu `orderBy('id')` (naik).
- Uang: `unsignedInteger`, tanpa `float`/`decimal`.
- Pesan validasi dan galat berbahasa Indonesia, kalimat lengkap, tanpa nama kolom mentah (mis. "Jumlah harus lebih besar dari nol", bukan "The jumlah field must be...").
- Tidak ada `dd()`, `dump()`, `var_dump()`, `Log::info` penelusuran sisa di kode yang di-commit. `Log::error` di penangan global diperbolehkan.
- `APP_DEBUG=false` pada `.env.example`.
- Tidak ada rute selain 15 endpoint di `routes/api.php`.

---

## 5. Pesan Teks Baku

Dipakai konsisten agar dokumentasi dan aplikasi sama. Bila `message` berubah di kode, ubah juga `api-contract.md` dan PDF.

| Situasi | Pesan |
|---------|-------|
| Daftar produk berhasil | "Daftar produk berhasil diambil" |
| Produk tidak ada | "Produk tidak ditemukan" |
| Validasi gagal (umum) | "Data yang dikirim tidak lengkap" |
| Stok kurang di keranjang | "Stok {nama} tidak mencukupi (tersisa {n})" |
| Stok kurang saat checkout | "Stok beberapa barang tidak mencukupi" |
| Status tak sah | "Pesanan berstatus {sekarang} tidak dapat dipindah ke {tujuan}" |
| Hapus produk ditolak | "Produk tidak dapat dihapus karena masih ada pada pesanan yang berjalan" |
| Galat server | "Terjadi kesalahan pada server" |
| Sambungan gagal (Flutter) | "Tidak dapat terhubung ke server" |
| Batas waktu (Flutter) | "Server tidak membalas" |
| Form kosong (validator Flutter) | "{Kolom} wajib diisi" |

---

## 6. Pemeriksaan Otomatis (jalankan sebelum commit ke `main`)

Jalankan dari akar repositori. Hasil yang diharapkan tertulis di kolom kanan.

| Aturan | Perintah | Diharapkan |
|--------|----------|-----------|
| `e.toString()` ke UI (H3) | `grep -rnE "\.toString\(\)\|'\$e'\|\"\$e\"" mobile/lib` | 0 baris yang mengarah ke `Text(...)`; periksa tiap temuan |
| `catch` kosong (H4) | `grep -rnE "catch *\([^)]*\) *\{ *\}" mobile/lib backend/app` | 0 baris |
| Sisa `print` (H12) | `grep -rnE "\bprint\(\|debugPrint\(" mobile/lib` | 0 baris |
| Sisa debug PHP (H12) | `grep -rnE "\bdd\(\|\bdump\(\|var_dump\(" backend/app backend/routes` | 0 baris |
| Hitungan di Dart (H1) | `grep -rnE "(harga\|subtotal\|total\|ongkir\|berat\|stok)[A-Za-z_]* *[\+\*\/-] \|\.reduce\(\|\.fold\(\|\.ceil\(\|\.round\(" mobile/lib` | 0 baris yang menghitung nilai bisnis; periksa tiap temuan |
| Jaringan di luar layanan (H6) | `grep -rln "package:http" mobile/lib` | hanya `services/layanan_api.dart` |
| `http.` di luar layanan | `grep -rn "http\.\(get\|post\|put\|patch\|delete\)" mobile/lib` | hanya di `layanan_api.dart` |
| Provider dipakai (H14) | `grep -rniE "provider\|riverpod\|flutter_bloc" mobile/pubspec.yaml` | 0 baris |
| Rute tak terdokumentasi (H11) | `php artisan route:list --path=api` | tepat 15 rute |
| `.env` ikut (H13) | `git ls-files \| grep -E "(^\|/)\.env$"` | 0 baris |
| Analisis statis Flutter | `cd mobile && flutter analyze` | No issues found |
| Seeder bersih | `cd backend && php artisan migrate:fresh --seed` | selesai tanpa galat |
| Invarian stok | SQL di `database-schema.md` Bagian 4 | 0 baris |

Catatan: `grep` di atas adalah jaring kasar. Temuan harus dibaca manusia; tidak semua temuan adalah pelanggaran (mis. `harga.toString()` untuk format rupiah). Di Windows gunakan Git Bash, atau `Select-String` di PowerShell.

---

## 7. Git: Cabang, Commit, dan Pembagian Kerja

### 7.1 Cabang
- `main`: selalu bisa dijalankan (`migrate:fresh --seed` berhasil, aplikasi terbuka).
- `feat/<topik>`, `fix/<topik>`, `docs/<topik>` untuk pekerjaan. Contoh: `feat/checkout-transaksional`.
- Gabung ke `main` setelah satu anggota lain membaca perubahannya (review silang; lihat `workflow.md`).

### 7.2 Format pesan commit (Conventional Commits berbahasa Indonesia)

```
<tipe>(<lingkup>): <ringkasan dalam bentuk perintah, ≤ 72 karakter>

[badan opsional: mengapa, bukan apa]
```

| Tipe | Dipakai untuk |
|------|---------------|
| `feat` | fitur baru |
| `fix` | perbaikan galat |
| `refactor` | ubah struktur tanpa ubah perilaku |
| `docs` | dokumen, README, Postman |
| `test` | skenario uji |
| `chore` | konfigurasi, dependensi, seeder |
| `style` | format saja |

Lingkup contoh: `produk`, `keranjang`, `checkout`, `pesanan`, `kurir`, `seeder`, `layanan-api`, `katalog`, `galat`, `lazy-load`, `readme`.

Contoh baik:
- `feat(checkout): kunci baris produk dengan lockForUpdate urut id`
- `fix(keranjang): tolak jumlah nol dengan 422`
- `feat(katalog): tambah lazy load dengan ScrollController`
- `docs(readme): isi sembilan butir dan catatan pemakaian AI`

Contoh buruk (jangan): `final`, `update`, `fix bug`, `tambah semua fitur`, `commit 1`.

### 7.3 Aturan commit
- Setiap anggota **minimal 5 commit bermakna atas namanya** (Kriteria 8). Target realistis: 8–12 per anggota.
- Commit kecil dan sering: satu perubahan logis per commit. Dilarang satu commit besar di hari terakhir.
- Pastikan `git config user.name` dan `user.email` tiap anggota benar di laptop masing-masing; commit hasil AI tetap di-commit atas nama anggota yang mereviewnya dan memahaminya.
- Jangan membuat commit atas nama orang lain, dan jangan menulis ulang riwayat (`push --force`) setelah anggota lain menarik cabang.
- Jangan menggabungkan perubahan yang belum dipahami penggabungnya.

### 7.4 Tracking pemakaian AI
Setiap kali AI menghasilkan atau mengubah kode yang masuk repo, catat di `docs/log-ai.md` (atau bagian README) pada tingkat berkas/fungsi: tanggal, alat (Claude/Antigravity/opencode), berkas/fungsi, anggota yang mereview. Formatnya ada di `agent.md`.

---

## 8. Aturan Berkas dan Rahasia

- `.env` tidak pernah di-commit; hanya `.env.example` dengan nilai kosong/aman. Tambahkan `.env` di `.gitignore` sebelum commit pertama.
- Isi `.env.example` yang wajib: `APP_NAME`, `APP_DEBUG=false`, `DB_*` (nama `zenvora`, pengguna/kata sandi kosong), `APP_TIMEZONE=Asia/Jakarta`, `ZENVORA_TOKEN_PEMBELI`, `ZENVORA_LAMBAT_DETIK=0`, `ZENVORA_PAKSA_GALAT=false`.
- Token statis pengembangan ditulis di README (diminta dosen); itu **bukan** rahasia produksi.
- Jangan commit: `vendor/`, `node_modules/`, `build/`, `.dart_tool/`, `storage/logs/*`, berkas IDE pribadi, tangkapan layar berisi data pribadi.
- Boleh commit: `composer.lock`, `pubspec.lock`, koleksi Postman (`docs/postman/`), PDF dokumentasi (`docs/`).
- Pustaka pihak ketiga yang ditambahkan (pub.dev/Packagist) **wajib** disebut di README beserta alasannya.

---

## 9. Definisi Selesai (Definition of Done) per Fitur

Sebuah fitur dianggap selesai bila:

1. Sesuai `api-contract.md` (jalur, body, kode status, pembungkus).
2. Dipanggil sekali dari Postman dan hasilnya cocok dengan kontrak (sisi backend).
3. Berjalan di Flutter dengan empat keadaan layar dan galat bertipe (sisi mobile).
4. Lolos pemeriksaan otomatis Bagian 6.
5. Dikomit dengan pesan sesuai Bagian 7.2.
6. Dibaca oleh satu anggota lain yang bisa menjelaskan ulang cara kerjanya.
7. Bila ada perubahan perilaku atau pesan, `api-contract.md` ikut diperbarui.
