// F1a — Galat "tanpa sambungan": server tidak ada di alamat yang dituju.
// Dijalankan dengan ALAMAT_SERVER ke port yang tidak mendengarkan (8099).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('F1a sambungan putus di tiga halaman daftar', (tester) async {
    await pumpAplikasi(tester);
    await gulirKe(tester, find.text('Koneksi Terputus'));
    expect(find.text('Tidak dapat terhubung ke server'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Coba Lagi'), findsOneWidget);
    catat(tester, 'katalog: koneksi terputus');

    // Coba lagi mencoba ulang (server tetap mati -> galat tampil lagi).
    await tester.tap(find.widgetWithText(ElevatedButton, 'Coba Lagi'));
    await tester.pump(const Duration(seconds: 2));
    await tungguMuncul(tester, find.text('Koneksi Terputus'));
    expect(find.widgetWithText(ElevatedButton, 'Coba Lagi'), findsOneWidget);
    catat(tester, 'coba lagi katalog');

    // Halaman daftar 1: Riwayat pesanan.
    await ketukIkon(tester, Icons.history_rounded);
    await tungguMuncul(tester, find.text('Riwayat Pesanan'));
    await tungguMuncul(tester, find.text('Koneksi Terputus'));
    expect(find.widgetWithText(ElevatedButton, 'Coba Lagi'), findsOneWidget);
    catat(tester, 'riwayat: koneksi terputus');
    await tester.pageBack();
    await tungguMuncul(tester, find.text('Koneksi Terputus'));

    // Halaman daftar 2: Keranjang belanja.
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Keranjang Belanja'));
    await tungguMuncul(tester, find.text('Koneksi Terputus'));
    expect(find.widgetWithText(ElevatedButton, 'Coba Lagi'), findsOneWidget);
    catat(tester, 'keranjang: koneksi terputus');
  });
}
