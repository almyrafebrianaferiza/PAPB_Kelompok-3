class RingkasanPesanan {
  final int id;
  final String nomorPesanan;
  final String status;
  final int total;
  final int jumlahBarang;
  final String dibuatPada;

  RingkasanPesanan({
    required this.id,
    required this.nomorPesanan,
    required this.status,
    required this.total,
    required this.jumlahBarang,
    required this.dibuatPada,
  });

  factory RingkasanPesanan.fromJson(Map<String, dynamic> json) {
    return RingkasanPesanan(
      id: json['id'] as int,
      nomorPesanan: json['nomor_pesanan'] as String? ?? '-',
      status: json['status'] as String,
      total: json['total'] as int,
      jumlahBarang: json['jumlah_barang'] as int? ?? 0,
      dibuatPada: json['dibuat_pada'] as String,
    );
  }
}
