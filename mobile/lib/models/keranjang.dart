import 'item_keranjang.dart';

class Keranjang {
  final List<ItemKeranjang> item;
  final int totalJumlah;
  final int subtotal;

  Keranjang({
    required this.item,
    required this.totalJumlah,
    required this.subtotal,
  });

  factory Keranjang.fromJson(Map<String, dynamic> json) {
    final rawItem = json['item'] as List<dynamic>? ?? [];
    return Keranjang(
      item: rawItem.map((i) => ItemKeranjang.fromJson(i as Map<String, dynamic>)).toList(),
      totalJumlah: json['total_jumlah'] as int? ?? 0,
      subtotal: json['subtotal'] as int? ?? 0,
    );
  }
}
