import 'package:flutter/material.dart';
import '../exceptions/galat_api.dart';
import '../theme/zenvora_warna.dart';

class TampilanGalat extends StatelessWidget {
  final GalatApi galat;
  final VoidCallback saatCobaLagi;

  const TampilanGalat({super.key,
    required this.galat,
    required this.saatCobaLagi,
  });

  @override
  Widget build(BuildContext context) {
    final GalatApi g = galat;

    IconData ikon = Icons.error_outline;
    Color warna = ZWarna.galat;
    String judul = 'Terjadi Kesalahan';

    if (g is SambunganGagalException) {
      ikon = Icons.wifi_off_rounded;
      warna = ZWarna.oranye;
      judul = 'Koneksi Terputus';
    } else if (g is BatasWaktuException) {
      ikon = Icons.timer_off_outlined;
      warna = ZWarna.peringatan;
      judul = 'Waktu Permintaan Habis';
    } else if (g is ValidasiException) {
      ikon = Icons.rule_folder_outlined;
      warna = ZWarna.galat;
      judul = 'Data Tidak Valid (422)';
    } else if (g is BentrokException) {
      ikon = Icons.inventory_2_outlined;
      warna = ZWarna.oranyeGelap;
      judul = 'Stok Tidak Mencukupi (409)';
    } else if (g is TidakDitemukanException) {
      ikon = Icons.search_off_rounded;
      warna = ZWarna.teksSekunder;
      judul = 'Data Tidak Ditemukan (404)';
    } else if (g is ServerException) {
      ikon = Icons.cloud_off_rounded;
      warna = ZWarna.galat;
      judul = 'Gangguan Server (500)';
    } else {
      ikon = Icons.warning_amber_rounded;
      warna = ZWarna.teksSekunder;
      judul = 'Kesalahan Tak Terduga';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, size: 54, color: warna),
            ),
            const SizedBox(height: 18),
            Text(
              judul,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ZWarna.putih,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              galat.pesan,
              style: const TextStyle(
                fontSize: 14,
                color: ZWarna.teksSekunder,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (g is ValidasiException && g.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ZWarna.permukaanTinggi,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: g.errors.entries.map((entry) {
                    return Text(
                      '• ${entry.key}: ${entry.value.join(", ")}',
                      style: const TextStyle(fontSize: 12, color: ZWarna.teksSekunder),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: saatCobaLagi,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
