class Produk {
  final int id;
  final String nama;
  final String merek;
  final int harga;
  final String kategori;
  final int stok;
  final bool tersedia;
  final String?
      deskripsi; // Wajib nullable dan ditangani dengan aman di Flutter
  final String? gambarUrl;
  final int beratGram;
  final int garansiBulan;
  final List<ProdukVarian> varian;

  Produk({
    required this.id,
    required this.nama,
    required this.merek,
    required this.harga,
    required this.kategori,
    required this.stok,
    required this.tersedia,
    this.deskripsi,
    this.gambarUrl,
    required this.beratGram,
    required this.garansiBulan,
    this.varian = const [],
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as int,
      nama: json['nama'] as String,
      merek: json['merek'] as String? ?? '',
      harga: json['harga'] as int,
      kategori: json['kategori'] as String,
      stok: json['stok'] as int,
      tersedia: json['tersedia'] as bool? ?? true,
      deskripsi: json['deskripsi'] as String?,
      gambarUrl: json['gambar_url'] as String?,
      beratGram: json['berat_gram'] as int? ?? 0,
      garansiBulan: json['garansi_bulan'] as int? ?? 0,
      varian: (json['varian'] as List<dynamic>?)
              ?.map((v) => ProdukVarian.fromJson(v as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  bool get isHabis => stok <= 0 || !tersedia;
}

class ProdukVarian {
  final int id;
  final int produkId;
  final String namaVarian;
  final int harga;
  final int stok;
  final int beratGram;
  final String? sku;

  ProdukVarian({
    required this.id,
    required this.produkId,
    required this.namaVarian,
    required this.harga,
    required this.stok,
    required this.beratGram,
    this.sku,
  });

  factory ProdukVarian.fromJson(Map<String, dynamic> json) {
    return ProdukVarian(
      id: json['id'] as int,
      produkId: json['produk_id'] as int? ?? 0,
      namaVarian: json['nama_varian'] as String? ?? '',
      harga: json['harga'] as int? ?? 0,
      stok: json['stok'] as int? ?? 0,
      beratGram: json['berat_gram'] as int? ?? 0,
      sku: json['sku'] as String?,
    );
  }

  bool get isHabis => stok <= 0;
}
