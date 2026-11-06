class Kurir {
  final int id;
  final String nama;
  final String wilayah;
  final int tarifPerKg;
  final int beratKgTertagih;
  final int ongkir;
  final int totalEstimasi;

  Kurir({
    required this.id,
    required this.nama,
    required this.wilayah,
    required this.tarifPerKg,
    required this.beratKgTertagih,
    required this.ongkir,
    required this.totalEstimasi,
  });

  factory Kurir.fromJson(Map<String, dynamic> json) {
    return Kurir(
      id: json['id'] as int,
      nama: json['nama'] as String,
      wilayah: json['wilayah'] as String,
      tarifPerKg: json['tarif_per_kg'] as int,
      beratKgTertagih: json['berat_kg_tertagih'] as int? ?? 0,
      ongkir: json['ongkir'] as int? ?? 0,
      totalEstimasi: json['total_estimasi'] as int? ?? 0,
    );
  }
}
