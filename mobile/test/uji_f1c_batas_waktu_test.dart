// F1c — Galat "batas waktu": ZENVORA_LAMBAT_DETIK=15 di .env (lewat timeout
// 10 dtk aplikasi). Dijalankan setelah flag diisi, lalu flag dikembalikan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('F1c server lambat -> batas waktu', (tester) async {
    await pumpAplikasi(tester);
    await tungguMuncul(
      tester,
      find.text('Waktu Permintaan Habis'),
      batas: const Duration(seconds: 30),
    );
    expect(find.text('Server tidak membalas'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Coba Lagi'), findsOneWidget);
    catat(tester, 'batas waktu 10 dtk terpicu');
  });
}
