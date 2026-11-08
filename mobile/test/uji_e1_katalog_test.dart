// E1 — Katalog: GridView, kategori & pencarian mengirim ulang permintaan,
// penanda stok habis, keadaan kosong, lencana keranjang.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E1 katalog', (tester) async {
    final api = LayananApi();
    await kosongkanKeranjang(api);

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'muat katalog');

    // 1. Daftar memakai GridView.builder.
    expect(find.byType(GridView), findsWidgets);

    // 2. Produk stok nol bertanda STOK HABIS (iPhone 15 ada di baris kedua).
    await gulirKe(tester, find.text('Apple iPhone 15 128GB'));
    catat(tester, 'gulir ke iPhone');
    expect(find.text('STOK HABIS'), findsWidgets);
    catat(tester, 'cek STOK HABIS');
    await gulirKe(tester, find.text('Samsung Galaxy A55 5G 8/256'), delta: -300);
    catat(tester, 'gulir balik');

    // 3. Keranjang kosong -> tanpa lencana angka.
    expect(find.byTooltip('Keranjang Belanja'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 4. Kategori mengirim ulang permintaan: Laptop -> hanya laptop.
    await tester.tap(find.text('Laptop'));
    await tungguMuncul(tester, find.text('ASUS Vivobook 14'));
    catat(tester, 'filter laptop');
    expect(find.text('Samsung Galaxy A55 5G 8/256'), findsNothing);

    // 5. Kembali ke Semua.
    await tester.tap(find.text('Semua'));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'filter semua');

    // 6. Pencarian tanpa hasil -> keadaan KOSONG, bukan galat.
    await gantiCari(tester, 'zzz-tidak-ada');
    await tungguMuncul(tester, find.text('Tidak Ada Produk Ditemukan'));
    catat(tester, 'cari kosong');
    expect(find.text('Terjadi kesalahan pada server'), findsNothing);
    expect(find.text('Coba lagi'), findsNothing);

    // 7. Reset Filter memulihkan daftar penuh.
    await tester.tap(find.text('Reset Filter'));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'reset filter');

    // 8. Pencarian berhasil (server) untuk kata kunci nyata.
    await gantiCari(tester, 'Samsung');
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'cari samsung');
    await gantiCari(tester, '');
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'hapus kata kunci');

    // 9. Lencana keranjang muncul setelah ada isi (muat ulang saat kembali).
    await isiKeranjang(api, 1, 1);
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Keranjang Belanja'));
    catat(tester, 'buka keranjang');
    await tester.pageBack();
    await tungguMuncul(tester, find.text('1'));
    catat(tester, 'lencana 1');

    await kosongkanKeranjang(api);
  });
}
