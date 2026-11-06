class ItemKeranjang {
  final int id;
  final int produkId;
  final String nama;
  final String merek;
  final int hargaSatuan;
  final int jumlah;
  final int beratGramSatuan;
  final int subtotalItem;
  final int stok;
  final bool tersedia;

  ItemKeranjang({
    required this.id,
    required this.produkId,
    required this.nama,
    required this.merek,
    required this.hargaSatuan,
    required this.jumlah,
    required this.beratGramSatuan,
    required this.subtotalItem,
    required this.stok,
    required this.tersedia,
  });

  factory ItemKeranjang.fromJson(Map<String, dynamic> json) {
    return ItemKeranjang(
      id: json['id'] as int,
      produkId: json['produk_id'] as int,
      nama: json['nama'] as String,
      merek: json['merek'] as String? ?? '',
      hargaSatuan: json['harga_satuan'] as int,
      jumlah: json['jumlah'] as int,
      beratGramSatuan: json['berat_gram_satuan'] as int? ?? 0,
      subtotalItem: json['subtotal_item'] as int,
      stok: json['stok'] as int? ?? 0,
      tersedia: json['tersedia'] as bool? ?? true,
    );
  }
}
