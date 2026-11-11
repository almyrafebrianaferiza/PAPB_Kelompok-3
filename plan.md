# ZENVORĀ — Plan Revisi & Fitur Lanjutan

> Dokumen perencanaan teknis untuk 4 poin revisi dari dosen:
> 1. Deteksi Lokasi Otomatis saat Checkout (GPS + Reverse Geocoding)
> 2. API RajaOngkir / Ongkos Kirim Dinamis
> 3. Variasi Produk (RAM, Storage, Warna dengan Harga & Stok Berbeda)
> 4. Dashboard Admin Terpadu

---

## FASE 1: Deteksi Lokasi Otomatis saat Checkout
- **Teknologi**:
  - Koordinat GPS / Web: `geolocator` package di Flutter.
  - Reverse Geocoding: OpenStreetMap Nominatim (`https://nominatim.openstreetmap.org/reverse`) — gratis, tanpa API key.
- **Implementasi**:
  - Tombol *"Gunakan Lokasi Saya"* (`Icons.my_location`) pada input Alamat di `checkout_page.dart`.
  - Format alamat: `[Jalan], [Kelurahan], [Kecamatan], [Kota/Kabupaten], [Provinsi] [Kode Pos]`.
  - Mengisi `_pengontrolAlamat.text` secara otomatis.

---

## FASE 2: API RajaOngkir & Ongkos Kirim Dinamis
- **Arsitektur**:
  - Laravel bertindak sebagai Gateway / Proxy API. Flutter tidak memegang API Key RajaOngkir (menjaga keamanan & aturan H1).
- **Backend (Laravel)**:
  - `ServisRajaOngkir.php`: Memanggil endpoint RajaOngkir Starter (`POST /cost`).
  - Cache wilayah kota/provinsi dengan `Cache::rememberForever`.
  - Mekanisme Fallback ke kurir internal zona jika koneksi internet/kuota API habis.
  - Endpoint: `GET /api/wilayah/kota` dan perluasan `GET /api/kurir?kota_id=...`.
- **Mobile (Flutter)**:
  - Dropdown/pencarian kota tujuan pengiriman.
  - Ongkir dan total tagihan diperbarui otomatis dari server.

---

## FASE 3: Variasi Produk (RAM, SSD, Warna)
- **Database (Laravel)**:
  - Tabel baru `produk_varian`: `id`, `produk_id`, `nama_varian`, `harga`, `stok`, `berat_gram`, `sku`.
  - Relasi `Produk` `hasMany(ProdukVarian)`.
  - Penyesuaian foreign key di `unit_produk`, `keranjang`, dan `detail_pesanan`.
- **Backend Logic**:
  - `ServisStok.php` & `ServisCheckout.php` memotong dan mengunci stok pada tingkat varian.
- **Mobile (Flutter)**:
  - Layar `rincian_produk_page.dart`: Selector chips untuk memilih varian.
  - Harga dan stok berubah dinamis sesuai varian yang dipilih.
  - Indikator bila varian tertentu habis (`stok == 0`).

---

## FASE 4: Dashboard Admin Terpadu
- **Platform**: Aplikasi Mobile Flutter (`screens/admin_dashboard_page.dart`), dapat diakses via ikon Admin di AppBar Katalog.
- **Fitur Utama**:
  - **KPI Cards**: Total omzet (Rp), jumlah pesanan aktif, total produk terdaftar, produk dengan stok kritis (< 3 unit).
  - **Manajemen Pesanan**: Melihat seluruh pesanan masuk dari semua pelanggan dan tombol pembaruan status:
    - Konfirmasi Pembayaran (`menunggu_konfirmasi` → `dibayar`)
    - Kirim Barang (`dibayar` → `dikirim`)
    - Selesaikan Pesanan (`dikirim` → `selesai`)
    - Batalkan Pesanan (restorasi stok & unit fisik otomatis)
  - **Monitoring Unit Fisik**: Pelacakan serial number unit (`ZNV-P...`) per produk.
