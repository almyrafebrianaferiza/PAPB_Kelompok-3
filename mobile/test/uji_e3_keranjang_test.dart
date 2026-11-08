// E3 — Keranjang: ubah jumlah & hapus memanggil server (subtotal server),
// keadaan kosong ramah, isi tetap setelah aplikasi dibuka ulang.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E3 keranjang', (tester) async {
    final api = LayananApi();
    await kosongkanKeranjang(api);

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'katalog');

    // 1. Keranjang kosong -> keadaan kosong ramah + tombol kembali ke katalog.
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Keranjang Masih Kosong'));
    catat(tester, 'keadaan kosong');
    expect(find.text('Mulai Belanja'), findsOneWidget);
    await tester.tap(find.text('Mulai Belanja'));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'mulai belanja');

    // 2. Isi keranjang lewat API (seperti setelah tambah dari rincian produk).
    await isiKeranjang(api, 1, 2);
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Keranjang Belanja'));
    await tungguMuncul(tester, find.text('2 item'));
    catat(tester, 'keranjang terisi');

    var k = await api.ambilKeranjang();
    expect(k.totalJumlah, 2);
    expect(find.text(formatRupiah(k.subtotal)), findsOneWidget,
        reason: 'Total Harga memakai nilai subtotal dari server');

    // 3. Tambah jumlah -> server memperbarui, subtotal ikut berubah.
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump(const Duration(milliseconds: 300));
    final akhir = DateTime.now().add(const Duration(seconds: 10));
    while (DateTime.now().isBefore(akhir)) {
      k = await api.ambilKeranjang();
      if (k.totalJumlah == 3) break;
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(k.totalJumlah, 3, reason: 'ubah jumlah harus tersimpan di server');
    await tungguMuncul(tester, find.text(formatRupiah(k.subtotal)));
    await tungguMuncul(tester, find.text('3 item'));
    await tester.pump(const Duration(milliseconds: 300));
    catat(tester, 'tambah jumlah');

    // 4. Kurangi jumlah -> kembali 2.
    await tester.tap(find.byIcon(Icons.remove).last);
    await tester.pump(const Duration(milliseconds: 300));
    final akhir2 = DateTime.now().add(const Duration(seconds: 10));
    while (DateTime.now().isBefore(akhir2)) {
      k = await api.ambilKeranjang();
      if (k.totalJumlah == 2) break;
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(k.totalJumlah, 2);
    await tungguMuncul(tester, find.text('2 item'));
    await tester.pump(const Duration(milliseconds: 300));
    catat(tester, 'kurangi jumlah');

    // 5. Hapus item -> snackbar + keadaan kosong.
    await tester.tap(find.byIcon(Icons.delete_outline).last);
    await tungguMuncul(tester, find.text('Item berhasil dihapus dari keranjang.'));
    await tungguMuncul(tester, find.text('Keranjang Masih Kosong'));
    catat(tester, 'hapus item');
    expect((await api.ambilKeranjang()).item, isEmpty);

    // 6. Tutup-buka aplikasi -> isi tetap (tersimpan di server).
    await tester.pageBack();
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'kembali ke katalog');
    await isiKeranjang(api, 2, 1);
    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'buka ulang aplikasi');
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Keranjang Belanja'));
    await tungguMuncul(tester, find.text('Total Harga'));
    catat(tester, 'keranjang setelah buka ulang');
    expect(find.text('Xiaomi Redmi Note 13 Pro'), findsOneWidget);
    expect(find.text('1 item'), findsOneWidget);

    await kosongkanKeranjang(api);
  });
}
