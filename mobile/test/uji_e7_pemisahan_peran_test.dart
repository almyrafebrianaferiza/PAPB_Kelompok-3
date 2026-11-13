// E7 — Pemisahan peran: mobile hanya untuk pembeli. Tidak ada pintasan
// dashboard admin/kelola produk, dan rincian pesanan bersifat read-only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E7 pemisahan peran buyer dan seller', (tester) async {
    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.byIcon(Icons.shopping_cart_outlined));

    // 1. Katalog pembeli tidak menampilkan akses admin.
    expect(find.byIcon(Icons.dashboard_outlined), findsNothing);
    expect(find.byIcon(Icons.admin_panel_settings_outlined), findsNothing);
    catat(tester, 'katalog tanpa ikon admin');

    // 2. Buka riwayat dan rincian pesanan yang sudah ada.
    await ketukIkon(tester, Icons.history_rounded);
    await tungguMuncul(tester, find.text('Riwayat Pesanan'));
    await gulirKe(tester, find.text('ZNV-20261106-00001'));
    await tester.tap(find.text('ZNV-20261106-00001'));
    await tungguMuncul(tester, find.text('Rincian Pesanan'));
    await tungguMuncul(tester, find.text('Total Akhir'));

    // 3. Tidak ada tombol transisi status milik admin.
    expect(find.textContaining('Ubah:'), findsNothing);
    expect(find.text('Batalkan Pesanan'), findsNothing);
    expect(
      find.textContaining('Status pesanan diperbarui oleh penjual'),
      findsOneWidget,
    );
    catat(tester, 'rincian pesanan read-only');

    // 4. Kembali ke katalog.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tungguMuncul(tester, find.byIcon(Icons.shopping_cart_outlined));
    expect(find.byIcon(Icons.dashboard_outlined), findsNothing);
    expect(find.byIcon(Icons.admin_panel_settings_outlined), findsNothing);
    catat(tester, 'kembali ke katalog pembeli');
  });
}
