import 'package:flutter/material.dart';
import '../exceptions/galat_api.dart';

/// Widget penanganan 5 ragam galat sesuai spesifikasi PAPB UTS
class TampilanGalat extends StatelessWidget {
  final GalatApi galat;
  final VoidCallback saatCobaLagi;

  const TampilanGalat({super.key,
    required this.galat,
    required this.saatCobaLagi,
  });

  @override
  Widget build(BuildContext context) {
    // Variabel lokal agar type promotion bekerja pada cek `is` di bawah ini.
    final GalatApi g = galat;

    IconData ikon = Icons.error_outline;
    Color warna = Colors.red;
    String judul = 'Terjadi Kesalahan';

    if (g is SambunganGagalException) {
      ikon = Icons.wifi_off_rounded;
      warna = Colors.orange.shade800;
      judul = 'Koneksi Terputus';
    } else if (g is BatasWaktuException) {
      ikon = Icons.timer_off_outlined;
      warna = Colors.amber.shade800;
      judul = 'Waktu Permintaan Habis';
    } else if (g is ValidasiException) {
      ikon = Icons.rule_folder_outlined;
      warna = Colors.red.shade700;
      judul = 'Data Tidak Valid (422)';
    } else if (g is BentrokException) {
      ikon = Icons.inventory_2_outlined;
      warna = Colors.deepOrange;
      judul = 'Stok Tidak Mencukupi (409)';
    } else if (g is TidakDitemukanException) {
      ikon = Icons.search_off_rounded;
      warna = Colors.grey.shade700;
      judul = 'Data Tidak Ditemukan (404)';
    } else if (g is ServerException) {
      ikon = Icons.cloud_off_rounded;
      warna = Colors.red.shade900;
      judul = 'Gangguan Server (500)';
    } else {
      ikon = Icons.warning_amber_rounded;
      warna = Colors.grey.shade800;
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
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              galat.pesan,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (g is ValidasiException && g.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: g.errors.entries.map((entry) {
                    return Text(
                      '• ${entry.key}: ${entry.value.join(", ")}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
