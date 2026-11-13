class DetailItemPesanan {
  final int id;
  final int produkId;
  final String namaProduk;
  final int hargaSatuan;
  final int jumlah;
  final int subtotalItem;
  final int beratGramSatuan;
  final int garansiBulan;
  final List<String> nomorSeri;

  DetailItemPesanan({
    required this.id,
    required this.produkId,
    required this.namaProduk,
    required this.hargaSatuan,
    required this.jumlah,
    required this.subtotalItem,
    required this.beratGramSatuan,
    required this.garansiBulan,
    required this.nomorSeri,
  });

  factory DetailItemPesanan.fromJson(Map<String, dynamic> json) {
    final rawSeri = json['nomor_seri'] as List<dynamic>? ?? [];
    return DetailItemPesanan(
      id: json['id'] as int,
      produkId: json['produk_id'] as int,
      namaProduk: json['nama_produk'] as String,
      hargaSatuan: json['harga_satuan'] as int,
      jumlah: json['jumlah'] as int,
      subtotalItem: json['subtotal_item'] as int,
      beratGramSatuan: json['berat_gram_satuan'] as int? ?? 0,
      garansiBulan: json['garansi_bulan'] as int? ?? 0,
      nomorSeri: rawSeri.map((s) => s.toString()).toList(),
    );
  }
}

class RincianPesanan {
  final int id;
  final String nomorPesanan;
  final String status;
  final String? nomorResi;
  final List<String> statusBerikutnya;
  final String namaPenerima;
  final String alamatPenerima;
  final Map<String, dynamic>? kurir;
  final Map<String, dynamic>? metodePembayaran;
  final int subtotal;
  final int totalBeratGram;
  final int beratKgTertagih;
  final int ongkir;
  final int total;
  final List<DetailItemPesanan> item;
  final String dibuatPada;

  RincianPesanan({
    required this.id,
    required this.nomorPesanan,
    required this.status,
    this.nomorResi,
    required this.statusBerikutnya,
    required this.namaPenerima,
    required this.alamatPenerima,
    this.kurir,
    this.metodePembayaran,
    required this.subtotal,
    required this.totalBeratGram,
    required this.beratKgTertagih,
    required this.ongkir,
    required this.total,
    required this.item,
    required this.dibuatPada,
  });

  factory RincianPesanan.fromJson(Map<String, dynamic> json) {
    final rawItems = json['item'] as List<dynamic>? ?? [];
    final rawStatusNext = json['status_berikutnya'] as List<dynamic>? ?? [];

    return RincianPesanan(
      id: json['id'] as int,
      nomorPesanan: json['nomor_pesanan'] as String? ?? '-',
      status: json['status'] as String,
      nomorResi: json['nomor_resi'] as String?,
      statusBerikutnya: rawStatusNext.map((s) => s.toString()).toList(),
      namaPenerima: json['nama_penerima'] as String? ?? '',
      alamatPenerima: json['alamat_penerima'] as String? ?? '',
      kurir: json['kurir'] as Map<String, dynamic>?,
      metodePembayaran: json['metode_pembayaran'] as Map<String, dynamic>?,
      subtotal: json['subtotal'] as int? ?? 0,
      totalBeratGram: json['total_berat_gram'] as int? ?? 0,
      beratKgTertagih: json['berat_kg_tertagih'] as int? ?? 0,
      ongkir: json['ongkir'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      item: rawItems
          .map((i) => DetailItemPesanan.fromJson(i as Map<String, dynamic>))
          .toList(),
      dibuatPada: json['dibuat_pada'] as String? ?? '',
    );
  }
}
