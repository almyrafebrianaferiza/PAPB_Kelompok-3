import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/produk.dart';
import 'penanda_habis.dart';

/// Kartu tampilan produk dalam grid katalog
class KartuProduk extends StatelessWidget {
  final Produk produk;
  final VoidCallback saatDiketuk;

  const KartuProduk({super.key,
    required this.produk,
    required this.saatDiketuk,
  });

  String _formatRupiah(num nominal) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    final bool apakahHabis = produk.isHabis;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatDiketuk,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area visual produk & badge (kontrak tanpa field gambar)
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  child: const Center(
                    child: Icon(Icons.devices_other, size: 48, color: Color(0xFFCBD5E1)),
                  ),
                ),
                if (apakahHabis)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: PenandaHabis(),
                  )
                else
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Sisa ${produk.stok}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${produk.garansiBulan} bln',
                      style: const TextStyle(
                        color: Color(0xFF0369A1),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Informasi Produk
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${produk.merek} • ${produk.kategori}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0284C7),
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    produk.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatRupiah(produk.harga),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.scale_outlined, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Text(
                        '${produk.beratGram}g',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
