import 'package:flutter/material.dart';

/// Widget tampilan kosong yang ramah bagi pengguna
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
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, size: 54, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 18),
            Text(
              judul,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              pesan,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (teksTombolAksi != null && saatTombolDitekan != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: saatTombolDitekan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(teksTombolAksi!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
