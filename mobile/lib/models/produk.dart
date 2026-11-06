class Produk {
  final int id;
  final String nama;
  final String merek;
  final int harga;
  final String kategori;
  final int stok;
  final bool tersedia;
  final String? deskripsi; // Wajib nullable dan ditangani dengan aman di Flutter
  final int beratGram;
  final int garansiBulan;

  Produk({
    required this.id,
    required this.nama,
    required this.merek,
    required this.harga,
    required this.kategori,
    required this.stok,
    required this.tersedia,
    this.deskripsi,
    required this.beratGram,
    required this.garansiBulan,
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
      beratGram: json['berat_gram'] as int? ?? 0,
      garansiBulan: json['garansi_bulan'] as int? ?? 0,
    );
  }

  bool get isHabis => stok <= 0 || !tersedia;
}
