# 02 — Alur Pemrosesan Pesanan (Order Fulfillment SOP)

> Prosedur Operasional Standar (SOP) pengelolaan dan pemrosesan pesanan pada Web Admin Backend Zenvorā.

---

## 1. Pemisahan Hak Akses: Pembeli vs Penjual (Admin)

Untuk menjamin kepatuhan sistem keamanan e-commerce dan integritas data keuangan:

| Status Pesanan | Siapa yang Berhak Mengubah? | Media / Kanal | Aksi / Pemicu |
|---|---|---|---|
| `menunggu_pembayaran` | Sistem | Mobile | Pembeli menyelesaikan checkout |
| `menunggu_konfirmasi` | Pembeli | Mobile | Pembeli menekan **Saya Sudah Bayar** (tanpa unggah bukti) |
| `dibayar` | **Admin Toko** | **Web Dashboard** | Admin memvalidasi mutasi rekening / gateway |
| `diproses` | **Admin Toko** | **Web Dashboard** | Gudang menyiapkan unit fisik & verifikasi serial number |
| `dikirim` | **Admin Toko** | **Web Dashboard** | Kurir menjemput barang + input nomor resi pengiriman |
| `selesai` | Pembeli / Sistem | Mobile / Web | Barang diterima pembeli / auto-confirm ekspedisi |
| `dibatalkan` | Pembeli / Admin | Mobile / Web | Pembatalan sebelum pesanan diproses gudang |

---

## 2. Diagram State Machine Pesanan

Setiap perpindahan status dikunci secara ketat oleh `App\Enums\StatusPesanan::bolehPindahKe()`:

```
                  ┌──────────────────────┐
                  │ Menunggu Pembayaran  │
                  └──────────┬───────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
┌──────────────────────┐            ┌──────────────────┐
│ Menunggu Konfirmasi  │            │    DIBATALKAN    │ (Terminal - Unit Fisik Kembali)
└──────────┬───────────┘            └──────────────────┘
           │                                  ▲
           ├──────────────────────────────────┘
           ▼ (Hanya Admin di Web)
┌──────────────────────┐
│       Dibayar        │
└──────────┬───────────┘
           ▼ (Hanya Admin di Web)
┌──────────────────────┐
│       Diproses       │ (Pengecekan Serial Number di Gudang)
└──────────┬───────────┘
           ▼ (Hanya Admin di Web + Input Resi)
┌──────────────────────┐
│       Dikirim        │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│       SELESAI        │ (Terminal - Transaksi Tuntas)
└──────────────────────┘
```

---

## 3. Alur Kerja Harian Admin (Fulfillment Workflow)

### Langkah 1: Pengecekan Pesanan Masuk
- Buka menu **Pesanan** (`/admin/pesanan`).
- Gunakan tab filter:
  - **Perlu Dikonfirmasi** (`menunggu_konfirmasi`): Pesanan yang sudah ditransfer oleh pembeli tetapi belum diverifikasi.
  - **Siap Dikemas** (`dibayar`): Pesanan lunas yang menunggu disiapkan oleh staf gudang.
  - **Sedang Dikirim** (`dikirim`): Pesanan dalam perjalanan kurir.

### Langkah 2: Verifikasi Pembayaran
1. Klik tombol **Lihat Rincian** pada pesanan berstatus `menunggu_konfirmasi`.
2. Sistem menampilkan:
   - Nomor pesanan (misal `ZNV-20261112-00001`).
   - Nama & alamat penerima.
   - Metode pembayaran (misal `BCA Virtual Account` atau `QRIS`).
   - Total nominal yang harus dibayar.
3. Admin menekan tombol hijau **"Konfirmasi Pembayaran"**.
4. Status pesanan berpindah menjadi `dibayar`. Pembeli melihat perubahan setelah halaman rincian dimuat ulang; tidak ada pembaruan real-time.

### Langkah 3: Penyiapan Barang & Verifikasi Nomor Seri Fisik
1. Pada pesanan berstatus `dibayar`, admin/gudang menekan tombol **"Kemas & Siapkan"**.
2. Status berubah menjadi `diproses`.
3. Pada halaman rincian pesanan web, sistem mencantumkan **Nomor Seri Fisik (IMEI / SN)** yang telah dialokasikan oleh database (misal `ZNV-P01-0001`).
4. Staf gudang mencocokkan stiker barcode pada dus fisik perangkat sebelum dibungkus.

### Langkah 4: Pengiriman & Penyerahan ke Kurir
1. Staf kurir (JNE / SiCepat / POS) mengambil paket dari toko/gudang.
2. Admin menekan tombol **"Input Resi & Kirim"**.
3. Muncul pop-up modal:
   - Pilihan kurir aktif.
   - Input nomor resi pengiriman (misal `JNE-CGK-8921938210`).
4. Klik **"Simpan & Kirim"**.
5. Status pesanan berpindah ke `dikirim`. Nomor resi langsung tersimpan dan dapat dilacak oleh pembeli di aplikasi mobile.

---

## 4. Mekanisme Keamanan Pembatalan (Stock & Unit Rollback)

Bila pesanan dibatalkan (baik oleh pembeli saat belum lunas atau oleh admin karena stok rusak/masalah alamat):
1. Transaksi database `DB::transaction` dieksekusi secara atomik di `ServisPesanan::ubahStatus()`.
2. Status pesanan diubah menjadi `dibatalkan`.
3. Seluruh unit fisik di tabel `unit_produk` yang sebelumnya terikat pada `detail_pesanan_id` dilepaskan:
   - `status` unit produk kembali menjadi `'tersedia'`.
   - `detail_pesanan_id` di-set menjadi `NULL`.
4. Kolom `stok` pada tabel `produk` dan `produk_varian` otomatis disinkronkan kembali (+1 sesuai unit yang kembali) via `ServisStok::kembalikanUnit()`.
5. Tidak ada unit fisik yang menggantung atau data stok yang bocor (*Zero Invariant Leak*).
