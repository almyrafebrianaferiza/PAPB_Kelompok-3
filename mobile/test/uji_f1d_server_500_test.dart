// F1d — Galat 500: ZENVORA_PAKSA_GALAT=true di .env membuat MiddlewareDemo
// melempar galat server. Aplikasi menampilkan pesan umum tanpa jejak galat.
// Dijalankan setelah flag diisi, lalu flag dikembalikan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('F1d 500 paksa galat -> pesan umum', (tester) async {
    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Gangguan Server (500)'));
    expect(find.text('Terjadi kesalahan pada server'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Coba Lagi'), findsOneWidget);

    // Tanpa jejak: tidak ada nama berkas, penanda stack trace, atau exception.
    expect(find.textContaining('.php'), findsNothing);
    expect(find.textContaining('Trace'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    catat(tester, '500 tampil umum tanpa jejak');
  });
}
