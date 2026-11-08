// E6 — Riwayat pesanan: urut terbaru -> terlama, ketuk baris ke Rincian.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E6 riwayat pesanan', (tester) async {
    final api = LayananApi();

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    await ketukIkon(tester, Icons.history_rounded);
    await tungguMuncul(tester, find.text('Riwayat Pesanan'));

    final daftar = await api.riwayatPesanan();
    expect(daftar, isNotEmpty, reason: 'seed menyediakan tiga pesanan');

    // 1. Urutan tampil sama dengan urutan server (id terbaru lebih dulu).
    await tungguMuncul(tester, find.text(daftar.first.nomorPesanan));
    catat(tester, 'riwayat termuat');
    final nomorDiUi = tester
        .widgetList<Text>(find.textContaining('ZNV-'))
        .map((t) => t.data)
        .toList();
    expect(nomorDiUi.take(3).toList(),
        daftar.take(3).map((p) => p.nomorPesanan).toList(),
        reason: 'urutan riwayat harus terbaru -> terlama');

    // 2. Label status ringkas tampil (contoh: pesanan selesai & dibayar).
    final label = <String, String>{
      'selesai': 'Selesai',
      'dibayar': 'Dibayar',
      'menunggu_pembayaran': 'Menunggu Pembayaran',
      'menunggu_konfirmasi': 'Menunggu Konfirmasi',
    };
    for (final p in daftar.take(3)) {
      if (label.containsKey(p.status)) {
        expect(find.text(label[p.status]!), findsWidgets);
      }
    }
    catat(tester, 'label status');

    // 3. Ketuk baris -> Rincian pesanan; kembali -> daftar dimuat ulang.
    await tester.tap(find.text(daftar.first.nomorPesanan));
    await tungguMuncul(tester, find.text('Rincian Pesanan'));
    await tungguMuncul(tester, find.text('Total Akhir'));
    catat(tester, 'rincian');
    expect(find.text(daftar.first.nomorPesanan), findsOneWidget);
    await tester.pageBack();
    await tungguMuncul(tester, find.text('Riwayat Pesanan'));
    await tungguMuncul(tester, find.text(daftar.first.nomorPesanan));
    catat(tester, 'kembali ke riwayat');
  });
}
