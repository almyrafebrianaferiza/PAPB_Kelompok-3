import 'package:flutter/material.dart';
import '../theme/zenvora_warna.dart';

class TampilanKosong extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String pesan;
  final String? teksTombolAksi;
  final VoidCallback? saatTombolDitekan;

  const TampilanKosong({super.key,
    this.ikon = Icons.inbox_outlined,
    required this.judul,
    required this.pesan,
    this.teksTombolAksi,
    this.saatTombolDitekan,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: ZWarna.permukaanTinggi,
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, size: 54, color: ZWarna.teksSamar),
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
              pesan,
              style: const TextStyle(
                fontSize: 14,
                color: ZWarna.teksSekunder,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (teksTombolAksi != null && saatTombolDitekan != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: saatTombolDitekan,
                child: Text(teksTombolAksi!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
