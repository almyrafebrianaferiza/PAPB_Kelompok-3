// Hierarki pengecualian bertipe untuk pemetaan 5 jenis galat di aplikasi Flutter
abstract class GalatApi implements Exception {
  final String pesan;
  GalatApi(this.pesan);

  @override
  String toString() => pesan;
}

// 1. Tidak ada sambungan (Server mati / mode pesawat)
class SambunganGagalException extends GalatApi {
  SambunganGagalException([super.pesan = 'Tidak dapat terhubung ke server']);
}

// 2. Batas waktu terlampaui (.timeout 10 detik terpicu)
class BatasWaktuException extends GalatApi {
  BatasWaktuException([super.pesan = 'Server tidak membalas']);
}

// 3. Validasi gagal (HTTP 422 - membawa pesan per kolom)
class ValidasiException extends GalatApi {
  final Map<String, List<String>> errors;
  ValidasiException(super.pesan, this.errors);
}

// 4. Bentrok keadaan server (HTTP 409 - stok kurang, status tidak sah)
class BentrokException extends GalatApi {
  final dynamic data;
  BentrokException(super.pesan, [this.data]);
}

// 5. Sumber daya tidak ditemukan (HTTP 404)
class TidakDitemukanException extends GalatApi {
  TidakDitemukanException([super.pesan = 'Data tidak ditemukan']);
}

// 6. Galat di sisi server (HTTP 500 / format HTML tidak sah)
class ServerException extends GalatApi {
  ServerException([super.pesan = 'Terjadi kesalahan pada server']);
}
