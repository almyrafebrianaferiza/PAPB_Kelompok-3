# Kontrak API — Zenvora (15 endpoint)

> Pendamping `prd.md` dan `database-schema.md`. Dokumen ini adalah **sumber kebenaran** untuk: controller dan validasi Laravel, `LayananApi` serta model Dart, koleksi Postman, dan Bagian 2–3, 5–7 PDF dokumentasi.
> Semua contoh respons di dokumen ini berlabel **RANCANGAN**. Contoh untuk PDF wajib diganti hasil pemanggilan nyata (Postman) setelah backend jalan.
> Keputusan yang dipakai: endpoint ke-15 `GET /api/metode-pembayaran` (ada), `stok` pada PUT = target jumlah unit, identitas = Bearer token statis, replay idempotensi mengembalikan pesanan lama.

---

## 1. Ketentuan Umum

### 1.1 Alamat dan header

| Butir | Nilai |
|-------|-------|
| Base URL emulator | `http://10.0.2.2:8000/api` |
| Base URL HP fisik | `http://<IP-LAN-laptop>:8000/api` (server: `php artisan serve --host=0.0.0.0`) |
| Format | JSON, UTF-8, Bahasa Indonesia untuk semua `message` |
| Header wajib semua permintaan | `Accept: application/json`, `Authorization: Bearer <token-statis>` |
| Header tambahan untuk body | `Content-Type: application/json` |
| Header khusus checkout | `X-Kunci-Idempoten: <nilai-acak>` |
| Zona waktu | `Asia/Jakarta`; waktu ditulis ISO 8601, mis. `2026-11-07T10:15:00+07:00` |
| Uang | Integer rupiah bulat, tanpa desimal dan tanpa pemisah ribuan |

**Token statis:** nilai ditulis di README (usulan `zenvora-dev-token-2026`, **[PERLU DIKONFIRMASI]**). Server memetakannya ke `pelanggan_id = 1`. Flutter mengirim token **hanya di satu tempat** (`LayananApi`, metode pembentuk header). Token hilang atau salah → **401** (lihat 1.4).

### 1.2 Pembungkus respons (seragam untuk semua endpoint)

Sukses, `code` selalu **string**:

```json
{
  "status": "sukses",
  "code": "200",
  "message": "Daftar produk berhasil diambil",
  "data": []
}
```

`data` berupa array (daftar), objek (satu sumber daya), atau `null` (mis. hasil hapus).

Gagal:

```json
{
  "status": "gagal",
  "code": "422",
  "message": "Data yang dikirim tidak lengkap",
  "errors": { "jumlah": ["Jumlah harus lebih besar dari nol"] }
}
```

- `errors` **hanya** ada pada 422, berbentuk `{ "kolom": ["pesan", ...] }`.
- Pada 409 checkout, daftar item bermasalah ada di `data.item_kurang` (lihat endpoint 11). Gagal lain tidak membawa `data`.
- Tidak boleh ada respons HTML, jejak tumpukan, atau pesan galat mentah basis data pada kondisi apa pun, termasuk rute tidak ada (404), metode salah (405), dan galat tak terduga (500). Satu penangan pengecualian global memetakan semuanya ke pembungkus ini.

### 1.3 Daftar kode status

| Kode | Dipakai ketika | Contoh pada sistem ini |
|------|----------------|------------------------|
| 200 | Baca atau ubah berhasil | daftar produk (juga saat kosong), hapus item keranjang |
| 201 | Sumber daya baru dibuat | produk baru, item keranjang baru, pesanan baru |
| 401 | Token tidak ada atau tidak dikenal | header `Authorization` salah |
| 404 | Sumber daya yang diminta tidak ada (atau bukan milik pelanggan) | `GET /api/produk/9999` |
| 409 | Permintaan sah secara bentuk tetapi bertentangan dengan keadaan server | stok kurang, produk tidak tersedia, status tidak boleh berpindah, produk dipakai pesanan aktif |
| 422 | Isi permintaan gagal validasi | `jumlah` ≤ 0, alamat kosong, keranjang kosong saat checkout |
| 500 | Galat tak terduga di server | pesan umum saja |

Perbedaan inti untuk uji petik B3: **404** = barangnya tidak ada; **422** = isi kiriman salah; **409** = kirimannya benar tetapi keadaan server menolak.

### 1.4 Perlakuan di Flutter

| Kode / kondisi | Pengecualian Dart (usulan) | Tampilan |
|----------------|----------------------------|----------|
| Tidak ada koneksi (`SocketException`, `ClientException`) | `SambunganGagalException` | Pesan "Tidak dapat terhubung ke server" + tombol **Coba lagi** |
| Batas waktu (`TimeoutException`) | `BatasWaktuException` | Pesan "Server tidak membalas" + tombol **Coba lagi** |
| 422 | `ValidasiException(errors)` | Pesan per kolom di bawah kolom form |
| 409 | `BentrokException(message, data)` | Pesan dari server di layar yang sama, tanpa pindah halaman |
| 404 | `TidakDitemukanException` | Keadaan **kosong** (bukan dialog teknis) |
| 401 | `ServerException` | Pesan umum (kasus pengembangan, tidak ada layar khusus) |
| 500, dan respons yang tidak bisa dibaca | `ServerException` | Pesan umum + **Coba lagi**, tanpa jejak galat |
| 200/201 | — | Tampilkan data / pindah halaman hasil |

Lima tampilan pertama di tabel harus **berbeda** dan terbukti di video. Dilarang: `e.toString()` ke layar, `catch` kosong, satu pesan untuk semua galat.

### 1.5 Pembagian tanggung jawab perhitungan

Seluruh nilai uang, berat, ongkir, total, stok, dan ketersediaan dihitung **di server**. Flutter hanya menampilkan field yang tersedia di respons. Tidak ada penjumlahan, perkalian, atau pembulatan di Dart. Bila layar membutuhkan sebuah angka (subtotal, ongkir, total, lencana keranjang), angka itu **harus** sudah ada di respons.

---

## 2. Objek Data

### 2.1 Produk

```json
{
  "id": 4,
  "nama": "ASUS Vivobook 14",
  "merek": "ASUS",
  "harga": 8499000,
  "kategori": "laptop",
  "stok": 3,
  "tersedia": true,
  "deskripsi": null,
  "berat_gram": 1400,
  "garansi_bulan": 24
}
```

| Kunci | Tipe JSON | Tipe Dart | Boleh null |
|-------|-----------|-----------|:----------:|
| id | int | `int` | tidak |
| nama | string | `String` | tidak |
| merek | string | `String` | tidak |
| harga | int | `int` | tidak |
| kategori | string (`gadget`, `laptop`, `tv`, `monitor`, `tablet`) | `String` | tidak |
| stok | int | `int` | tidak |
| tersedia | bool | `bool` | tidak |
| deskripsi | string | `String?` | **ya** |
| berat_gram | int | `int` | tidak |
| garansi_bulan | int | `int` | tidak |

Produk dianggap **habis** bila `stok == 0` **atau** `tersedia == false`. Penanda habis dan tombol tambah dimatikan menurut dua kunci ini (keduanya berasal dari server).

### 2.2 Item keranjang

```json
{
  "id": 12,
  "produk_id": 4,
  "nama": "ASUS Vivobook 14",
  "merek": "ASUS",
  "harga_satuan": 8499000,
  "jumlah": 1,
  "berat_gram_satuan": 1400,
  "subtotal_item": 8499000,
  "stok": 3,
  "tersedia": true
}
```

`id` adalah id baris keranjang (dipakai pada `PUT/DELETE /api/keranjang/{id}`), **bukan** `produk_id`.

### 2.3 Kurir (dengan estimasi untuk keranjang saat ini)

```json
{
  "id": 2,
  "nama": "Zenvora Jawa",
  "wilayah": "Jawa Timur lainnya",
  "tarif_per_kg": 7500,
  "berat_kg_tertagih": 2,
  "ongkir": 15000,
  "total_estimasi": 11713000
}
```

`berat_kg_tertagih`, `ongkir`, dan `total_estimasi` dihitung server dari isi keranjang pelanggan saat ini. Bila keranjang kosong ketiganya bernilai `0`. Inilah yang membuat ongkir di halaman checkout berubah ketika kurir diganti tanpa hitungan di Dart.

### 2.4 Metode pembayaran

```json
{ "id": 2, "kode": "transfer_manual", "nama": "Transfer Manual" }
```

### 2.5 Ringkasan pesanan (untuk daftar riwayat)

```json
{
  "id": 4,
  "nomor_pesanan": "ZNV-20261107-00004",
  "status": "menunggu_pembayaran",
  "total": 11713000,
  "jumlah_barang": 2,
  "dibuat_pada": "2026-11-07T10:15:00+07:00"
}
```

`jumlah_barang` = total unit (jumlah seluruh `detail_pesanan.jumlah`), dihitung server.

### 2.6 Rincian pesanan

```json
{
  "id": 4,
  "nomor_pesanan": "ZNV-20261107-00004",
  "status": "menunggu_pembayaran",
  "status_berikutnya": ["menunggu_konfirmasi", "dibatalkan"],
  "nama_penerima": "Budi Santoso",
  "alamat_penerima": "Jl. Pahlawan No. 10, Sidoarjo",
  "kurir": { "nama": "Zenvora Jawa", "wilayah": "Jawa Timur lainnya", "tarif_per_kg": 7500 },
  "metode_pembayaran": { "kode": "transfer_manual", "nama": "Transfer Manual" },
  "subtotal": 11698000,
  "total_berat_gram": 1910,
  "berat_kg_tertagih": 2,
  "ongkir": 15000,
  "total": 11713000,
  "item": [
    {
      "id": 7,
      "produk_id": 4,
      "nama_produk": "ASUS Vivobook 14",
      "harga_satuan": 8499000,
      "jumlah": 1,
      "subtotal_item": 8499000,
      "berat_gram_satuan": 1400,
      "garansi_bulan": 24,
      "nomor_seri": ["ZNV-P04-0002"]
    }
  ],
  "dibuat_pada": "2026-11-07T10:15:00+07:00"
}
```

- `kurir.tarif_per_kg` adalah **salinan** `pesanan.tarif_per_kg_saat_pesan`, bukan tarif kurir hari ini.
- Semua kolom pada `item` adalah **salinan saat pembelian** (`detail_pesanan`), bukan data produk hari ini.
- `nomor_seri` berisi satu string per unit; panjangnya sama dengan `jumlah`.
- `status_berikutnya` datang dari server (daftar perpindahan sah dari status saat ini). Flutter memakainya untuk menampilkan tombol aksi (mis. tombol **Bayar** bila memuat `menunggu_konfirmasi`), sehingga aturan perpindahan tidak diduplikasi di Dart. Untuk status akhir, nilainya `[]`.

---

## 3. Ringkasan 15 Endpoint

| # | Metode dan jalur | Fungsi | Kode status |
|---|------------------|--------|-------------|
| 1 | GET `/api/produk` | Daftar produk (filter, cari, lazy load) | 200, 422 |
| 2 | GET `/api/produk/{id}` | Rincian produk | 200, 404 |
| 3 | POST `/api/produk` | Tambah produk | 201, 422 |
| 4 | PUT `/api/produk/{id}` | Ubah produk | 200, 404, 422 |
| 5 | DELETE `/api/produk/{id}` | Hapus produk | 200, 404, 409 |
| 6 | GET `/api/keranjang` | Isi keranjang + subtotal | 200 |
| 7 | POST `/api/keranjang` | Tambah item | 201 (baru), 200 (menambah jumlah), 409, 422 |
| 8 | PUT `/api/keranjang/{id}` | Ubah jumlah | 200, 404, 409, 422 |
| 9 | DELETE `/api/keranjang/{id}` | Hapus item | 200, 404 |
| 10 | GET `/api/kurir` | Daftar kurir + estimasi ongkir | 200 |
| 11 | POST `/api/checkout` | Buat pesanan | 201, 409, 422 |
| 12 | GET `/api/pesanan` | Riwayat pesanan | 200 |
| 13 | GET `/api/pesanan/{id}` | Rincian pesanan | 200, 404 |
| 14 | PATCH `/api/pesanan/{id}/status` | Ubah status | 200, 404, 409, 422 |
| 15 | GET `/api/metode-pembayaran` | Daftar metode bayar | 200 |

Endpoint #15 adalah **tambahan** di luar 14 endpoint wajib dosen. Wajib dicantumkan di dokumentasi PDF dan koleksi Postman. Seluruh endpoint selain #1–#5 dan #15 bekerja atas nama pelanggan dari token.

Kode 401 dapat muncul di semua endpoint bila token salah dan tidak diulang di tabel.

---

## 4. Rincian Endpoint

### 4.1 `GET /api/produk`

Query (semua opsional):

| Parameter | Aturan | Default |
|-----------|--------|---------|
| `kategori` | salah satu dari lima kategori; nilai tak dikenal → hasil kosong (200) | semua |
| `cari` | pencarian bagian dari `nama` atau `merek`, tidak peka huruf besar-kecil | — |
| `halaman` | int ≥ 1 | 1 |
| `per_halaman` | int 1–50 | 10 |

- Urutan tetap: `id` naik (stabil untuk lazy load).
- Produk yang di-soft-delete tidak pernah muncul. Produk `tersedia = false` atau stok 0 **tetap muncul** (untuk penanda habis).
- **Selalu 200**, termasuk bila hasil kosong (`data: []`). Alasan: daftar kosong bukan kegagalan; 404 berarti sumber daya tunggal tidak ada.
- 422 bila `halaman` atau `per_halaman` bukan bilangan bulat di rentangnya.
- **Lazy load:** Flutter meminta `halaman=1`, lalu `halaman+1` saat pengguna mendekati ujung daftar. Daftar dianggap habis ketika jumlah item yang kembali **kurang dari** `per_halaman`. Bila jumlah total tepat kelipatan `per_halaman`, permintaan berikutnya mengembalikan `data: []` dan Flutter berhenti **tanpa** menampilkan keadaan kosong (keadaan kosong hanya untuk halaman 1). Ganti kategori atau kata cari mereset ke halaman 1 dan mengirim ulang permintaan ke server.

Contoh (RANCANGAN) `GET /api/produk?kategori=tablet&halaman=1&per_halaman=10`:

```json
{
  "status": "sukses",
  "code": "200",
  "message": "Daftar produk berhasil diambil",
  "data": [
    {
      "id": 13, "nama": "Samsung Galaxy Tab A9+", "merek": "Samsung",
      "harga": 3199000, "kategori": "tablet", "stok": 5, "tersedia": true,
      "deskripsi": "Tablet 11 inci layar 90Hz.", "berat_gram": 510, "garansi_bulan": 12
    },
    {
      "id": 14, "nama": "Xiaomi Pad 6", "merek": "Xiaomi",
      "harga": 4999000, "kategori": "tablet", "stok": 4, "tersedia": true,
      "deskripsi": "Tablet 11 inci 144Hz.", "berat_gram": 490, "garansi_bulan": 12
    },
    {
      "id": 15, "nama": "Apple iPad 10th Gen", "merek": "Apple",
      "harga": 7999000, "kategori": "tablet", "stok": 3, "tersedia": true,
      "deskripsi": "Tablet 10,9 inci.", "berat_gram": 477, "garansi_bulan": 12
    }
  ]
}
```

(Seeder memuat tiga tablet, jadi respons rancangan memuat ketiganya. Karena 3 < `per_halaman` (10), Flutter menganggap daftar sudah habis.)

### 4.2 `GET /api/produk/{id}`

- 200: objek produk (2.1).
- 404: produk tidak ada atau sudah di-soft-delete. Pesan: "Produk tidak ditemukan".

### 4.3 `POST /api/produk`

Body JSON:

| Kolom | Aturan |
|-------|--------|
| nama | wajib, string, maks 150 |
| merek | wajib, string, maks 60 |
| harga | wajib, int ≥ 0 |
| kategori | wajib, salah satu dari lima kategori |
| stok | wajib, int ≥ 0 (jumlah unit awal) |
| tersedia | opsional, bool (default `true`) |
| deskripsi | opsional, string atau `null` |
| berat_gram | wajib, int ≥ 1 |
| garansi_bulan | wajib, int ≥ 0 |

- 201 dengan objek produk. Dalam satu transaksi server membuat sebanyak `stok` baris `unit_produk` bernomor seri otomatis dan mengisi `produk.stok` sama dengan itu.
- 422 dengan `errors` per kolom. Pesan berbahasa Indonesia, mis. `"nama": ["Nama produk wajib diisi"]`.

### 4.4 `PUT /api/produk/{id}`

Body sama dengan 4.3 (semua kolom wajib, kecuali `tersedia` dan `deskripsi`).

- `stok` bertindak sebagai **target jumlah unit tersedia**: bila lebih besar dari unit tersedia saat ini, server menambah unit; bila lebih kecil, server menghapus unit `tersedia` (unit `terjual` tidak pernah disentuh). `produk.stok` diubah dalam transaksi yang sama.
- Perubahan `harga`, `berat_gram`, dan `garansi_bulan` **tidak** memengaruhi pesanan lama (disalin di `detail_pesanan`).
- 200 dengan objek produk terbaru; 404 bila tidak ada; 422 bila validasi gagal.

### 4.5 `DELETE /api/produk/{id}`

- 200 dengan `data: null` dan pesan "Produk berhasil dihapus". Server melakukan soft delete dan menghapus baris `keranjang` yang memuat produk itu, dalam satu transaksi.
- 404 bila tidak ada.
- 409 bila produk terdapat pada pesanan berstatus selain `selesai` dan `dibatalkan`. Pesan: "Produk tidak dapat dihapus karena masih ada pada pesanan yang berjalan". Flutter menampilkan pesan ini dan tetap di daftar.

### 4.6 `GET /api/keranjang`

Selalu 200. `data` berupa **objek**:

```json
{
  "item": [ /* daftar item keranjang (2.2) */ ],
  "total_jumlah": 2,
  "subtotal": 11698000
}
```

- `total_jumlah` = jumlah seluruh unit (untuk lencana ikon keranjang); `subtotal` = Σ `subtotal_item`. Keduanya dari server.
- Keranjang kosong: `item: []`, `total_jumlah: 0`, `subtotal: 0`. Flutter menampilkan keadaan kosong yang ramah dengan saran kembali ke katalog.

Contoh (RANCANGAN):

```json
{
  "status": "sukses",
  "code": "200",
  "message": "Keranjang berhasil diambil",
  "data": {
    "item": [
      { "id": 12, "produk_id": 4, "nama": "ASUS Vivobook 14", "merek": "ASUS",
        "harga_satuan": 8499000, "jumlah": 1, "berat_gram_satuan": 1400,
        "subtotal_item": 8499000, "stok": 3, "tersedia": true },
      { "id": 13, "produk_id": 13, "nama": "Samsung Galaxy Tab A9+", "merek": "Samsung",
        "harga_satuan": 3199000, "jumlah": 1, "berat_gram_satuan": 510,
        "subtotal_item": 3199000, "stok": 5, "tersedia": true }
    ],
    "total_jumlah": 2,
    "subtotal": 11698000
  }
}
```

### 4.7 `POST /api/keranjang`

Body: `{ "produk_id": 4, "jumlah": 1 }`

| Kolom | Aturan |
|-------|--------|
| produk_id | wajib, int, harus ada dan belum di-soft-delete (bila tidak → 422 `"produk_id": ["Produk tidak ditemukan"]`) |
| jumlah | wajib, int ≥ 1 |

Perilaku:
- Produk belum ada di keranjang → buat baris baru, **201**.
- Produk sudah ada → naikkan `jumlah` pada baris yang sama (bukan baris kedua), **200**.
- **409** bila `tersedia = false`, atau jumlah total di keranjang (lama + baru) melebihi `stok`. Pesan dari server, mis. "Stok ASUS Vivobook 14 tidak mencukupi (tersisa 3)". Keranjang tidak berubah.
- **422** bila validasi gagal.
- Keranjang **tidak mereservasi stok**; pemeriksaan final terjadi pada checkout.
- Implementasi: jalankan di dalam transaksi dan andalkan batasan unik `(pelanggan_id, produk_id)`; bila dua permintaan menambah produk yang sama bersamaan, yang kedua menaikkan baris yang sudah ada, bukan membuat baris ganda.

Data respons: item keranjang (2.2) setelah perubahan. Contoh (RANCANGAN) 201:

```json
{
  "status": "sukses",
  "code": "201",
  "message": "Produk ditambahkan ke keranjang",
  "data": { "id": 12, "produk_id": 4, "nama": "ASUS Vivobook 14", "merek": "ASUS",
            "harga_satuan": 8499000, "jumlah": 1, "berat_gram_satuan": 1400,
            "subtotal_item": 8499000, "stok": 3, "tersedia": true }
}
```

### 4.8 `PUT /api/keranjang/{id}`

Body: `{ "jumlah": 2 }`

- `jumlah` wajib, int. **Nol atau negatif → 422** (`"jumlah": ["Jumlah harus lebih besar dari nol"]`). Untuk membuang item, pakai DELETE.
- 404 bila baris tidak ada atau bukan milik pelanggan.
- 409 bila `jumlah` melebihi `stok` atau produk `tersedia = false`.
- 200 dengan item keranjang yang diperbarui.

### 4.9 `DELETE /api/keranjang/{id}`

- 200 dengan `data: null`, pesan "Item dihapus dari keranjang".
- 404 bila baris tidak ada atau bukan milik pelanggan.

### 4.10 `GET /api/kurir`

Selalu 200; hanya kurir `aktif`. `data` berupa array objek kurir (2.3), diurutkan menurut `id`. Seluruh `ongkir` dan `total_estimasi` dihitung dari keranjang pelanggan saat ini dengan rumus di Bagian 5.1. Flutter memanggil ulang endpoint ini setiap kali halaman checkout dibuka agar angka sesuai isi keranjang, dan **menampilkan** `ongkir` serta `total_estimasi` kurir yang dipilih tanpa menghitung apa pun.

Nilai final yang tersimpan pada pesanan tetap dihitung ulang server saat checkout.

Contoh (RANCANGAN), keranjang = Vivobook + Tab A9+ (1.910 g):

```json
{
  "status": "sukses",
  "code": "200",
  "message": "Daftar kurir berhasil diambil",
  "data": [
    { "id": 1, "nama": "Zenvora Kota", "wilayah": "Sidoarjo dan Surabaya", "tarif_per_kg": 4000,
      "berat_kg_tertagih": 2, "ongkir": 8000, "total_estimasi": 11706000 },
    { "id": 2, "nama": "Zenvora Jawa", "wilayah": "Jawa Timur lainnya", "tarif_per_kg": 7500,
      "berat_kg_tertagih": 2, "ongkir": 15000, "total_estimasi": 11713000 },
    { "id": 3, "nama": "Zenvora Nusantara", "wilayah": "Luar Jawa Timur", "tarif_per_kg": 15000,
      "berat_kg_tertagih": 2, "ongkir": 30000, "total_estimasi": 11728000 }
  ]
}
```

### 4.11 `POST /api/checkout`

Header wajib: `X-Kunci-Idempoten` (string 8–100 karakter; Flutter membuat satu nilai acak, mis. UUID v4, **sekali per percobaan checkout** dan memakainya ulang saat pengguna menekan Coba lagi; nilai baru hanya dibuat untuk percobaan baru setelah pengguna mengubah isi atau berpindah halaman).

Body JSON:

| Kolom | Aturan |
|-------|--------|
| kurir_id | wajib, int, kurir aktif |
| metode_pembayaran_id | wajib, int, metode aktif |
| nama_penerima | wajib, string, maks 100 |
| alamat_penerima | wajib, string, 10–500 karakter |

Urutan pemrosesan di server:

1. Header `X-Kunci-Idempoten` ada, bila tidak → 422 (`errors.kunci_idempoten`).
2. **Pemeriksaan replay (sebelum validasi lain):** cari pesanan dengan `(pelanggan_id, kunci_idempoten)` yang sama. Bila ada → kembalikan pesanan itu (respons sama dengan 201 sukses), **tanpa** validasi ulang dan tanpa membuat pesanan baru. Urutan ini wajib: setelah checkout pertama berhasil, keranjang sudah kosong, sehingga bila validasi keranjang dilakukan lebih dulu, percobaan ulang dengan kunci sama akan salah dibalas 422.
3. Validasi body dan keranjang tidak kosong, bila gagal → 422 (keranjang kosong: `errors.keranjang`). Tidak ada perubahan data.
4. Mulai transaksi. Kunci baris `produk` yang terlibat dengan `lockForUpdate()` berurutan menurut `id` naik. Baca isi keranjang **di dalam** transaksi.
5. **Periksa replay sekali lagi** di dalam transaksi (setelah kunci didapat): bila permintaan lain dengan kunci sama sudah commit selagi permintaan ini menunggu kunci, kembalikan pesanan itu dan akhiri tanpa mengubah apa pun.
6. Periksa tiap item: `tersedia = true` dan jumlah unit tersedia ≥ jumlah. Bila ada yang gagal → rollback penuh dan **409** (stok tidak berubah sama sekali).
7. Pilih `N` unit `tersedia` per item (urut `id` naik, dengan `lockForUpdate`), ubah ke `terjual`, kurangi `produk.stok`.
8. Hitung subtotal, berat, ongkir, total (Bagian 5.1). Simpan `pesanan` (status awal `menunggu_pembayaran`, salinan `tarif_per_kg_saat_pesan`, `kunci_idempoten`) dan `detail_pesanan` (salinan nama, harga, berat, garansi). Isi `nomor_pesanan` dan `unit_produk.detail_pesanan_id`.
9. Kosongkan `keranjang` pelanggan, commit.

Dua permintaan dengan kunci sama yang tiba hampir bersamaan: pemeriksaan ulang di langkah 5 membuat yang kalah membalas pesanan yang menang; batasan unik `(pelanggan_id, kunci_idempoten)` menjadi jaring pengaman terakhir (bila terjadi pelanggaran unik, tangkap, rollback, lalu ambil pesanan yang sudah ada dan balas sama). Kunci sama dengan isi permintaan yang berbeda: pesanan lama tetap dikembalikan (isi baru diabaikan).

Respons:
- **201**: rincian pesanan (2.6). Flutter berpindah ke halaman rincian pesanan.
- **409**: stok kurang atau produk tidak tersedia. Contoh (RANCANGAN):

```json
{
  "status": "gagal",
  "code": "409",
  "message": "Stok beberapa barang tidak mencukupi",
  "data": {
    "item_kurang": [
      { "produk_id": 4, "nama": "ASUS Vivobook 14", "diminta": 2, "tersedia": 1 }
    ]
  }
}
```

Flutter menampilkan `message` (dan bila ingin, daftar `item_kurang`) di halaman checkout, **tanpa** berpindah halaman.
- **422**: validasi gagal; pesan per kolom di bawah kolom form.

Contoh sukses (RANCANGAN):

```http
POST /api/checkout
Authorization: Bearer zenvora-dev-token-2026
X-Kunci-Idempoten: 6f1c2d3e-9b7a-4c55-8e21-0a1b2c3d4e5f
Content-Type: application/json

{ "kurir_id": 2, "metode_pembayaran_id": 2,
  "nama_penerima": "Budi Santoso", "alamat_penerima": "Jl. Pahlawan No. 10, Sidoarjo" }
```

```json
{
  "status": "sukses",
  "code": "201",
  "message": "Pesanan berhasil dibuat",
  "data": {
    "id": 4,
    "nomor_pesanan": "ZNV-20261107-00004",
    "status": "menunggu_pembayaran",
    "status_berikutnya": ["menunggu_konfirmasi", "dibatalkan"],
    "nama_penerima": "Budi Santoso",
    "alamat_penerima": "Jl. Pahlawan No. 10, Sidoarjo",
    "kurir": { "nama": "Zenvora Jawa", "wilayah": "Jawa Timur lainnya", "tarif_per_kg": 7500 },
    "metode_pembayaran": { "kode": "transfer_manual", "nama": "Transfer Manual" },
    "subtotal": 11698000,
    "total_berat_gram": 1910,
    "berat_kg_tertagih": 2,
    "ongkir": 15000,
    "total": 11713000,
    "item": [
      { "id": 7, "produk_id": 4, "nama_produk": "ASUS Vivobook 14", "harga_satuan": 8499000,
        "jumlah": 1, "subtotal_item": 8499000, "berat_gram_satuan": 1400, "garansi_bulan": 24,
        "nomor_seri": ["ZNV-P04-0002"] },
      { "id": 8, "produk_id": 13, "nama_produk": "Samsung Galaxy Tab A9+", "harga_satuan": 3199000,
        "jumlah": 1, "subtotal_item": 3199000, "berat_gram_satuan": 510, "garansi_bulan": 12,
        "nomor_seri": ["ZNV-P13-0002"] }
    ],
    "dibuat_pada": "2026-11-07T10:15:00+07:00"
  }
}
```

### 4.12 `GET /api/pesanan`

Selalu 200. `data` = array ringkasan pesanan (2.5) milik pelanggan, **terbaru ke terlama** (`dibuat_pada` turun, lalu `id` turun). Tanpa pesanan: `data: []`; Flutter menampilkan keadaan kosong. Tidak berpaginasi.

### 4.13 `GET /api/pesanan/{id}`

- 200: rincian pesanan (2.6).
- 404: pesanan tidak ada atau bukan milik pelanggan. Flutter menampilkan keadaan kosong/tidak ditemukan.

Contoh (RANCANGAN) memakai pesanan yang sama dengan 4.11, dengan perbedaan `message`: "Rincian pesanan berhasil diambil" dan kode `200`.

### 4.14 `PATCH /api/pesanan/{id}/status`

Body: `{ "status": "menunggu_konfirmasi" }`

- `status` wajib dan harus salah satu dari tujuh nilai status; selain itu → **422**.
- Pesanan tidak ada → **404**.
- Perpindahan tidak termasuk tabel di Bagian 5.4, termasuk dari status ke dirinya sendiri → **409**, pesan: "Pesanan berstatus {sekarang} tidak dapat dipindah ke {tujuan}". Status tidak berubah.
- Berhasil → **200** dengan rincian pesanan (2.6) berstatus baru. Perpindahan ke `dibatalkan` mengembalikan unit ke `tersedia` (`detail_pesanan_id` = null) dan menambah `produk.stok` dalam transaksi yang sama.

Pemakaian dalam aplikasi: **semua aksi status berada di halaman Rincian pesanan** (tidak ada tujuh halaman lain yang menampung aksi admin). Halaman itu menampilkan satu tombol untuk setiap nilai di `status_berikutnya`: tombol **Bayar** mengirim `menunggu_konfirmasi`, tombol **Konfirmasi pembayaran (admin)** mengirim `dibayar`, **Batalkan** mengirim `dibatalkan`, dan seterusnya. Teks tombol hanyalah label tampilan per nilai status; aturan perpindahan tetap di server. Tidak ada pembedaan peran (belum ada login); yang dijaga server hanya keabsahan perpindahan.

### 4.15 `GET /api/metode-pembayaran`

Selalu 200; hanya metode `aktif`; array objek (2.4) menurut `id`. Dipakai halaman checkout untuk pemilih metode bayar.

---

## 5. Aturan Perhitungan dan Status

### 5.1 Perhitungan (semua di server)

```
subtotal_item     = harga_satuan × jumlah
subtotal          = Σ subtotal_item
total_berat_gram  = Σ (berat_gram_satuan × jumlah)
berat_kg_tertagih = ceil(total_berat_gram / 1000)      // dibulatkan ke atas per kg
ongkir            = berat_kg_tertagih × tarif_per_kg   // kurir terpilih, tanpa batas berat
total             = subtotal + ongkir
```

Contoh: Vivobook 1.400 g + Tab A9+ 510 g = 1.910 g → 2 kg; Zenvora Jawa 7.500/kg → ongkir 15.000; subtotal 11.698.000 → total 11.713.000. Contoh angka kecil: 1 unit 1.000 g → 1 kg; 1 unit 1.001 g → 2 kg.

### 5.2 Aturan bisnis khas domain (penolakan oleh server)

Ongkir **tidak boleh** bernilai tetap: dihitung dari total berat keranjang. Server menolak checkout bila kurir tidak valid atau keranjang kosong (422). Penegakan hanya di server; Flutter menampilkan angka dari `GET /api/kurir` dan dari respons checkout.

### 5.3 Nomor seri dan garansi

Saat checkout, tiap unit fisik yang dikirim terikat ke baris `detail_pesanan`, dan nomornya muncul di `item[].nomor_seri`. Garansi (`garansi_bulan`) disalin dari produk saat pembelian dan ditampilkan di rincian pesanan.

### 5.4 Perpindahan status yang sah

| Dari | Boleh ke |
|------|----------|
| `menunggu_pembayaran` | `menunggu_konfirmasi`, `dibatalkan` |
| `menunggu_konfirmasi` | `dibayar`, `dibatalkan` |
| `dibayar` | `diproses` |
| `diproses` | `dikirim` |
| `dikirim` | `selesai` |
| `selesai`, `dibatalkan` | — (status akhir) |

Perpindahan lain → 409. Daftar ini sama persis dengan `StatusPesanan::bolehPindahKe()` di Laravel dan dengan isi `status_berikutnya` pada rincian pesanan.

---

## 6. Pemetaan Halaman Flutter ke Endpoint

| Halaman | Endpoint yang dipanggil |
|---------|-------------------------|
| Katalog | #1 (filter/cari/lazy load), #6 (hanya untuk lencana) |
| Rincian produk | #2, #7 |
| Keranjang | #6, #8, #9 |
| Checkout | #6 (subtotal), #10 (kurir + ongkir), #15 (metode bayar), #11 |
| Rincian pesanan | #13, #14 |
| Riwayat pesanan | #12 |
| Kelola produk | #1, #3, #4, #5 |

Semua panggilan melalui satu kelas `LayananApi` dengan `.timeout(const Duration(seconds: 10))` dan pemetaan galat di 1.4.

---

## 7. Daftar Periksa Kesesuaian (diisi saat uji)

- [ ] Ke-15 endpoint dipanggil sekali dari Postman dan hasilnya cocok dengan dokumen ini.
- [ ] Setiap respons (sukses dan gagal, termasuk 401/404/405/500) memakai pembungkus seragam.
- [ ] `GET /api/produk` kosong tetap 200 dengan `data: []`.
- [ ] 409 pada keranjang, checkout, hapus produk, dan status tidak sah mengembalikan pesan yang bisa ditampilkan.
- [ ] Respons 500 tidak memuat jejak galat atau SQL.
- [ ] Contoh pada PDF diganti hasil pemanggilan nyata, dan `message` serta kunci yang tertulis sama dengan respons sebenarnya.

---

## 8. Keputusan Rancangan yang Perlu Disepakati (jika ingin diubah)

1. `GET /api/kurir` memuat `berat_kg_tertagih`, `ongkir`, `total_estimasi` agar Flutter tidak menghitung. Alternatif: endpoint pratinjau terpisah (menambah endpoint ke-16).
2. `status_berikutnya` pada rincian pesanan (aturan status tidak diulang di Dart).
3. Replay idempotensi membalas **201** dengan isi sama (bukan 200).
4. Kode **401** untuk token salah (di luar daftar kode pada dokumen tugas).
5. Respons 409 checkout membawa `data.item_kurang` (satu-satunya respons gagal yang memuat `data`).
6. Nilai token statis dan IP server dicantumkan di README.
