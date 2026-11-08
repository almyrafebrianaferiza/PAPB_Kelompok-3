import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/produk.dart';
import '../theme/zenvora_warna.dart';
import 'penanda_habis.dart';

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
      child: InkWell(
        borderRadius: BorderRadius.circular(ZRadius.besar),
        onTap: saatDiketuk,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: ZWarna.permukaanTinggi,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(ZRadius.besar)),
                  ),
                  child: const Center(
                    child: Icon(Icons.devices_other, size: 48, color: ZWarna.teksSamar),
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
                        color: ZWarna.hitam.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Sisa ${produk.stok}',
                        style: const TextStyle(
                          color: ZWarna.putih,
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
                      color: ZWarna.oranye.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${produk.garansiBulan} bln',
                      style: const TextStyle(
                        color: ZWarna.oranyeTerang,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                      color: ZWarna.oranye,
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
                      color: ZWarna.putih,
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
                      color: ZWarna.putih,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.scale_outlined, size: 12, color: ZWarna.teksSekunder),
                      const SizedBox(width: 3),
                      Text(
                        '${produk.beratGram}g',
                        style: const TextStyle(
                          fontSize: 11,
                          color: ZWarna.teksSekunder,
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
