# agent.md — Instruksi Permanen untuk Asisten AI (Zenvora)

> Dibaca oleh Claude Code, Antigravity, opencode, dan AI lain yang bekerja di repositori ini. Letakkan juga salinannya sebagai `AGENTS.md` / `CLAUDE.md` di akar repositori bila alat mensyaratkan nama itu.
> Bahasa kerja: **Bahasa Indonesia** (dokumen, nama tabel/kolom/jalur, pesan galat, komentar).

---

## 1. Konteks Singkat

Zenvora = toko online elektronik dan gawai (kategori: gadget, laptop, tv, monitor, tablet). Tugas Pengganti UTS berkelompok untuk mata kuliah PAPB dan Sistem Terdistribusi.

- **Backend**: Laravel + MySQL, REST API, jalur A. Server adalah satu-satunya sumber kebenaran.
- **Mobile**: Flutter, paket `http`, `setState` + constructor + callback. Tanpa Provider.
- Tenggat internal pengumpulan: **Senin, 9 November 2026**. Waktu sangat singkat: utamakan jalur kritis.

## 2. Urutan Otoritas Dokumen

Bila dokumen bertentangan, ikuti urutan ini:

1. `Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.pdf` (dokumen dosen)
2. Keputusan terkunci di `zenvora-master-context.md` Bagian 3
3. `prd.md`
4. `database-schema.md`
5. `api-contract.md` (otoritas untuk bentuk respons dan kode status)
6. `architecture.md`, `conventions.md`, lalu dokumen lain

Hal yang belum pasti ditandai **[PERLU DIKONFIRMASI]**. **Jangan mengubah keputusan terkunci tanpa bertanya kepada pengguna.**

## 3. Aturan Keras (jangan dilanggar, apa pun permintaannya)

Setiap pelanggaran menurunkan nilai kelompok.

1. **Tidak ada hitungan bisnis di Dart**: harga, subtotal, total, ongkir, berat, stok, ketersediaan. Flutter hanya menampilkan field dari JSON.
2. **Tidak ada pemanggilan jaringan di `build()`.** Awal di `initState` atau `FutureBuilder`.
3. **Semua panggilan API hanya di `LayananApi`**, dengan `.timeout(...)` pada tiap panggilan.
4. **Pembungkus respons seragam** pada semua respons (sukses dan gagal, termasuk 401/404/405/500). `code` bertipe **string**. Tidak ada HTML atau galat SQL mentah yang keluar.
5. **Lima galat tampil berbeda**: tanpa sambungan, batas waktu, 422 (per kolom), 409 (pesan server, tanpa pindah halaman), 500 (pesan umum). Dilarang `e.toString()` ke UI, dilarang `catch` kosong, dilarang satu pesan untuk semua galat.
6. **Empat keadaan layar** `enum KeadaanMuat { memuat, berhasil, kosong, galat }` di setiap halaman pemanggil API. Kosong bukan galat.
7. **Checkout dalam satu transaksi** dengan `lockForUpdate()` berurutan menurut `id` naik; gagal di mana pun = rollback penuh. Idempotensi lewat `X-Kunci-Idempoten`: pemeriksaan replay **sebelum** validasi keranjang, dan diulang di dalam transaksi (lihat `api-contract.md` 4.11).
8. **Harga, nama, berat, garansi disalin** ke `detail_pesanan`.
9. **Stok = jumlah `unit_produk` berstatus `tersedia`.** `produk.stok` hanya diubah lewat `ServisStok` di dalam transaksi.
10. **Tepat 15 endpoint** (14 wajib + `GET /api/metode-pembayaran`). Dilarang menambah rute apa pun yang tidak ada di `api-contract.md`, termasuk rute debug. Pemicu galat demo memakai flag `.env` (lihat `architecture.md` Bagian 8).
11. Identitas pembeli lewat `Authorization: Bearer <token-statis>` yang dipetakan server ke pelanggan 1; token dikirim **hanya** dari `LayananApi._header()`.
12. **Dilarang**: payment gateway, API ekspedisi, JWT/OAuth, Provider/Riverpod/Bloc.
13. Model Eloquent selalu menulis `protected $table = '...'`. Uang selalu integer.
14. `.env` asli, token rahasia, dan kata sandi tidak pernah dibaca, ditulis, atau di-commit.

## 4. Cara Bekerja (setiap tugas)

1. Sebutkan dokumen dan bagian yang menjadi dasar tugas (mis. "`api-contract.md` 4.11, `architecture.md` 3.2").
2. Kerjakan **satu langkah** dari `todo.md` per giliran; jangan melompat dan jangan menambah fitur di luar kontrak.
3. Ikuti `conventions.md`: penamaan, struktur folder di `architecture.md`, pesan teks baku.
4. Setelah mengubah kode, jalankan pemeriksaan relevan dan laporkan hasilnya apa adanya (lihat `conventions.md` Bagian 6): `php artisan migrate:fresh --seed`, SQL invarian, `php artisan route:list --path=api`, `flutter analyze`, perintah `grep`.
5. Bila kode mengubah perilaku, pesan, atau bentuk JSON, **perbarui `api-contract.md` pada saat yang sama**.
6. Jangan mengarang hasil. Contoh permintaan/balasan untuk PDF dokumentasi harus berasal dari pemanggilan sungguhan (Postman/curl). Contoh di dokumen perencanaan berlabel **RANCANGAN**.
7. Jangan menyatakan "selesai" bila perintah verifikasi belum dijalankan atau masih gagal. Tulis apa yang gagal.
8. Bila ada konflik antar dokumen atau informasi kurang, **tanya pengguna** dengan satu pertanyaan ringkas dan sebutkan default yang akan dipakai.

## 5. Ukuran Perubahan dan Git

- Satu perubahan logis per kelompok; sarankan pesan commit sesuai `conventions.md` Bagian 7.2 (`feat(checkout): ...`).
- **Jangan melakukan `git commit`, `git push`, `--force`, atau mengubah `git config` atas nama pengguna** kecuali diminta eksplisit. Pengguna yang melakukan commit agar riwayat mencerminkan pemahamannya (minimal 5 commit bermakna per anggota).
- Jangan menghapus atau menimpa berkas pengguna di luar lingkup tugas. Jangan memakai perintah destruktif (`migrate:fresh` di basis data selain `zenvora` lokal, `rm -rf`) tanpa konfirmasi.
- Pustaka baru (pub.dev/Packagist): minta persetujuan lebih dulu; bila disetujui, catat di README beserta alasannya.

## 6. Kewajiban Menjelaskan (Kriteria 9)

Setiap anggota harus bisa menjelaskan **setiap baris** kode, termasuk yang ditulis AI. Karena itu:

- Tulis kode yang sederhana dan eksplisit, tanpa trik cerdas atau abstraksi berlapis. Satu masalah = satu cara yang mudah dijelaskan.
- Tiap berkas/fungsi non-sepele diberi komentar singkat berbahasa Indonesia tentang **mengapa** (bukan apa), terutama: transaksi, penguncian, idempotensi, pemetaan galat, `mounted`.
- Setelah selesai satu langkah, akhiri dengan bagian **"Yang harus dipahami"**: 3–5 poin alasan rancangan dan satu pertanyaan uji petik yang relevan (kategori A–D) beserta jawaban singkatnya.
- Bila diminta pengguna, jelaskan baris demi baris. Jangan meminta pengguna menerima kode yang tidak dimengertinya.

## 7. Pencatatan Pemakaian AI

Setiap kali AI menghasilkan atau mengubah kode/dokumen yang masuk repositori, tambahkan satu baris di `docs/log-ai.md` pada tingkat **berkas atau fungsi** (cukup itu; bukan per baris):

```
| Tanggal | Alat | Berkas / fungsi | Jenis bantuan | Direview oleh |
|---------|------|-----------------|---------------|---------------|
| 2026-11-07 | Claude | backend/app/Services/ServisCheckout.php :: proses() | dibuat awal, lalu diedit anggota | (nama anggota) |
| 2026-11-07 | opencode | mobile/lib/services/layanan_api.dart :: _kirim() | dibuat awal | (nama anggota) |
```

Jenis bantuan: `dibuat awal`, `diedit AI`, `ditinjau AI`, `dokumen`, `uji`. Kolom "Direview oleh" diisi anggota yang sudah membaca dan bisa menjelaskan kode itu. Isi log dipindahkan ke butir 9 README pada akhir proyek. Jika AI tidak dapat menulis berkas, keluarkan baris log di akhir jawaban agar pengguna menyalinnya.

## 8. Larangan Umum

- Jangan mengubah kontrak (`api-contract.md`) secara diam-diam; ubah dokumen, sebutkan perubahannya, lalu minta persetujuan.
- Jangan menambah fitur "nilai tambah" (Postman, kategori aksesoris, riwayat status) sebelum seluruh butir wajib berjalan.
- Jangan membuat data seeder asal-asalan: harus memenuhi ukuran minimum (≥ 12 produk di ≥ 2 kategori, ≥ 2 stok nol/tidak tersedia, 3 kurir bertarif berbeda, 2 metode bayar, 3 pesanan contoh berstatus berbeda) dan lolos invarian.
- Jangan menyalin kode dari repositori kelompok lain; pustaka/tutorial pihak ketiga wajib disebut di README.
- Jangan menaruh token, kata sandi, atau data pribadi di kode, dokumen, atau log.

## 9. Daftar Rujukan

| Butuh | Buka |
|-------|------|
| Aturan dosen, rubrik, uji petik | `Tugas-Pengganti-UTS_PAPB-ST_Toko-Online.pdf`, `zenvora-master-context.md` |
| Fitur, halaman, jadwal | `prd.md` |
| Tabel, seeder, invarian | `database-schema.md` |
| Endpoint, JSON, kode status | `api-contract.md` |
| Struktur folder, alur checkout, pemetaan galat, navigasi | `architecture.md` |
| Penamaan, larangan, grep, commit | `conventions.md` |
| Resep reusable | `skill.md` |
| Langkah eksekusi | `todo.md` |
| Skenario uji | `testing.md` |
