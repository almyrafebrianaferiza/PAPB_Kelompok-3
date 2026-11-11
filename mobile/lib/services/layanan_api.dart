import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/konfigurasi.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../models/keranjang.dart';
import '../models/item_keranjang.dart';
import '../models/kurir.dart';
import '../models/metode_pembayaran.dart';
import '../models/rincian_pesanan.dart';
import '../models/ringkasan_pesanan.dart';

class LayananApi {
  // Satu-satunya tempat header dibentuk dan token dikirim
  Map<String, String> _header({String? kunciIdempoten}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokenStatis',
        if (kunciIdempoten != null) 'X-Kunci-Idempoten': kunciIdempoten,
      };

  Uri _uri(String jalur, [Map<String, dynamic>? query]) {
    final baseUrlClean = alamatServer.endsWith('/')
        ? alamatServer.substring(0, alamatServer.length - 1)
        : alamatServer;
    return Uri.parse('$baseUrlClean$jalur').replace(queryParameters: query);
  }

  // Fungsi pengiriman tunggal yang membungkus seluruh pemanggilan jaringan,
  // batas waktu (timeout), serta pemetaan 5 jenis galat
  Future<dynamic> _kirim(Future<http.Response> Function() permintaan) async {
    http.Response respons;
    try {
      respons = await permintaan().timeout(batasWaktu);
    } on TimeoutException {
      throw BatasWaktuException();
    } on SocketException {
      throw SambunganGagalException();
    } on http.ClientException {
      throw SambunganGagalException();
    }

    Map<String, dynamic> badan;
    try {
      badan = jsonDecode(utf8.decode(respons.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw ServerException();
    }

    final kode = int.tryParse('${badan['code']}') ?? respons.statusCode;
    if (badan['status'] == 'sukses') return badan['data'];

    final pesan = badan['message'] as String? ?? 'Terjadi kesalahan';
    switch (kode) {
      case 422:
        throw ValidasiException(pesan, _kePetaKolom(badan['errors']));
      case 409:
        throw BentrokException(pesan, badan['data']);
      case 404:
        throw TidakDitemukanException(pesan);
      default:
        throw ServerException();
    }
  }

  Map<String, List<String>> _kePetaKolom(dynamic errors) {
    if (errors is! Map<String, dynamic>) return {};
    return errors.map((k, v) => MapEntry(k, (v as List).cast<String>()));
  }

  // 1. GET /api/produk (Paginasi Lazy Load, Filter, Cari)
  Future<List<Produk>> daftarProduk({
    String? kategori,
    String? cari,
    int halaman = 1,
    int perHalaman = 10,
  }) =>
      _kirim(() => http.get(
            _uri('/produk', {
              if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
              if (cari != null && cari.isNotEmpty) 'cari': cari,
              'halaman': '$halaman',
              'per_halaman': '$perHalaman',
            }),
            headers: _header(),
          )).then((d) => (d as List).map((j) => Produk.fromJson(j as Map<String, dynamic>)).toList());

  // 2. GET /api/produk/{id}
  Future<Produk> rincianProduk(int id) =>
      _kirim(() => http.get(_uri('/produk/$id'), headers: _header()))
          .then((d) => Produk.fromJson(d as Map<String, dynamic>));

  // 3. POST /api/produk
  Future<Produk> tambahProduk(Map<String, dynamic> body) =>
      _kirim(() => http.post(
            _uri('/produk'),
            headers: _header(),
            body: jsonEncode(body),
          )).then((d) => Produk.fromJson(d as Map<String, dynamic>));

  // 4. PUT /api/produk/{id}
  Future<Produk> ubahProduk(int id, Map<String, dynamic> body) =>
      _kirim(() => http.put(
            _uri('/produk/$id'),
            headers: _header(),
            body: jsonEncode(body),
          )).then((d) => Produk.fromJson(d as Map<String, dynamic>));

  // 5. DELETE /api/produk/{id}
  Future<void> hapusProduk(int id) =>
      _kirim(() => http.delete(_uri('/produk/$id'), headers: _header()));

  // 6. GET /api/keranjang
  Future<Keranjang> ambilKeranjang() =>
      _kirim(() => http.get(_uri('/keranjang'), headers: _header()))
          .then((d) => Keranjang.fromJson(d as Map<String, dynamic>));

  // 7. POST /api/keranjang
  Future<ItemKeranjang> tambahKeranjang(int produkId, int jumlah) =>
      _kirim(() => http.post(
            _uri('/keranjang'),
            headers: _header(),
            body: jsonEncode({'produk_id': produkId, 'jumlah': jumlah}),
          )).then((d) => ItemKeranjang.fromJson(d as Map<String, dynamic>));

  // 8. PUT /api/keranjang/{id}
  Future<ItemKeranjang> ubahJumlahKeranjang(int id, int jumlah) =>
      _kirim(() => http.put(
            _uri('/keranjang/$id'),
            headers: _header(),
            body: jsonEncode({'jumlah': jumlah}),
          )).then((d) => ItemKeranjang.fromJson(d as Map<String, dynamic>));

  // 9. DELETE /api/keranjang/{id}
  Future<void> hapusItemKeranjang(int id) =>
      _kirim(() => http.delete(_uri('/keranjang/$id'), headers: _header()));

  // 10. GET /api/kurir (Memuat estimasi ongkir dinamis dari berat keranjang & RajaOngkir)
  Future<List<Kurir>> ambilKurir({int? kotaId}) =>
      _kirim(() => http.get(
            _uri('/kurir', {
              if (kotaId != null) 'kota_id': '$kotaId',
            }),
            headers: _header(),
          )).then((d) => (d as List).map((j) => Kurir.fromJson(j as Map<String, dynamic>)).toList());

  // 10b. GET /api/kurir?opsi=kota (Daftar kota tujuan RajaOngkir)
  Future<List<Map<String, dynamic>>> ambilDaftarKota() =>
      _kirim(() => http.get(_uri('/kurir', {'opsi': 'kota'}), headers: _header()))
          .then((d) => (d as List).cast<Map<String, dynamic>>());

  // 11. POST /api/checkout (Menerima header X-Kunci-Idempoten)
  Future<RincianPesanan> checkout({
    required String kunciIdempoten,
    required int kurirId,
    required int metodePembayaranId,
    required String namaPenerima,
    required String alamatPenerima,
  }) =>
      _kirim(() => http.post(
            _uri('/checkout'),
            headers: _header(kunciIdempoten: kunciIdempoten),
            body: jsonEncode({
              'kurir_id': kurirId,
              'metode_pembayaran_id': metodePembayaranId,
              'nama_penerima': namaPenerima,
              'alamat_penerima': alamatPenerima,
            }),
          )).then((d) => RincianPesanan.fromJson(d as Map<String, dynamic>));

  // 12. GET /api/pesanan (Terbaru ke terlama)
  Future<List<RingkasanPesanan>> riwayatPesanan() =>
      _kirim(() => http.get(_uri('/pesanan'), headers: _header()))
          .then((d) => (d as List).map((j) => RingkasanPesanan.fromJson(j as Map<String, dynamic>)).toList());

  // 13. GET /api/pesanan/{id}
  Future<RincianPesanan> rincianPesanan(int id) =>
      _kirim(() => http.get(_uri('/pesanan/$id'), headers: _header()))
          .then((d) => RincianPesanan.fromJson(d as Map<String, dynamic>));

  // 14. PATCH /api/pesanan/{id}/status
  Future<RincianPesanan> ubahStatusPesanan(int id, String status) =>
      _kirim(() => http.patch(
            _uri('/pesanan/$id/status'),
            headers: _header(),
            body: jsonEncode({'status': status}),
          )).then((d) => RincianPesanan.fromJson(d as Map<String, dynamic>));

  // 15. GET /api/metode-pembayaran
  Future<List<MetodePembayaran>> ambilMetodePembayaran() =>
      _kirim(() => http.get(_uri('/metode-pembayaran'), headers: _header()))
          .then((d) => (d as List).map((j) => MetodePembayaran.fromJson(j as Map<String, dynamic>)).toList());

  // 16. Reverse Geocoding via OpenStreetMap Nominatim (Deteksi Lokasi Otomatis)
  Future<String> geocodingBalik(double lat, double lon) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
    );
    try {
      final respons = await http.get(
        uri,
        headers: {
          'User-Agent': 'ZenvoraMobileApp/1.0 (academic-project)',
          'Accept-Language': 'id',
        },
      ).timeout(const Duration(seconds: 8));

      if (respons.statusCode != 200) {
        return 'Lat: $lat, Lon: $lon';
      }

      final data = jsonDecode(utf8.decode(respons.bodyBytes)) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final jalan = address['road'] ?? address['neighbourhood'] ?? address['suburb'];
      final kelurahan = address['village'] ?? address['suburb'] ?? address['quarter'];
      final kecamatan = address['city_district'] ?? address['municipality'] ?? address['district'];
      final kota = address['city'] ?? address['town'] ?? address['regency'] ?? address['county'];
      final provinsi = address['state'];
      final kodePos = address['postcode'];

      final bagian = [
        if (jalan != null) jalan,
        if (kelurahan != null) kelurahan,
        if (kecamatan != null) 'Kec. $kecamatan',
        if (kota != null) kota,
        if (provinsi != null) provinsi,
        if (kodePos != null) kodePos,
      ];

      if (bagian.isEmpty) {
        return data['display_name'] as String? ?? 'Koordinat: $lat, $lon';
      }

      return bagian.join(', ');
    } catch (_) {
      return 'Koordinat: $lat, $lon';
    }
  }
}
