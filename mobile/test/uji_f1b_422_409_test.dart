// F1b — Galat 422 (validasi server per kolom) dan 409 (stok) di aplikasi.
// Dijalankan terhadap server normal di :8000.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('F1b 422 per kolom dan 409 stok', (tester) async {
    final api = LayananApi();
    await kosongkanKeranjang(api);
    await aturStok(api, 1, 5);
    await isiKeranjang(api, 1, 1);

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.byIcon(Icons.shopping_cart_outlined));
    await tester.pump(const Duration(milliseconds: 800));
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Total Harga'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Checkout'));
    await tungguMuncul(tester, find.text('Pengiriman & Checkout'));
    await tungguMuncul(tester, find.text('Total Tagihan'));
    catat(tester, 'halaman checkout');

    // 1. Nama & alamat kosong -> 422 dari server, pesan tampil per kolom,
    //    pengguna tetap di halaman checkout (tanpa pindah halaman).
    await tester.enterText(kolom('Nama Lengkap Penerima *'), '');
    await tester.enterText(kolom('Alamat Lengkap Pengiriman *'), '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'));
    await tungguMuncul(tester, find.text('Nama penerima wajib diisi'));
    await tungguMuncul(tester, find.text('Alamat penerima wajib diisi'));
    expect(find.text('Pengiriman & Checkout'), findsOneWidget);
    catat(tester, '422 per kolom (server)');

    // 2. Isi kembali -> pesan 422 hilang (dibersihkan saat mengetik).
    await tester.enterText(kolom('Nama Lengkap Penerima *'), 'Ahmad Fauzi');
    await tester.enterText(kolom('Alamat Lengkap Pengiriman *'),
        'Jl. Ijen No. 45, Klojen, Kota Malang');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Nama penerima wajib diisi'), findsNothing);
    expect(find.text('Alamat penerima wajib diisi'), findsNothing);
    catat(tester, '422 hilang setelah diisi');

    // 3. Produk stok nol -> 409 dari server, dialog di layar yang sama.
    final produk1 = await api.rincianProduk(1);
    try {
      await ubahProdukAdmin(1, dataProduk(produk1, stok: 0));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'));
      await tungguMuncul(tester, find.text('Stok Tidak Mencukupi'));
      expect(find.textContaining('tidak mencukupi'), findsWidgets);
      expect(find.text('Pengiriman & Checkout'), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await tungguHilang(tester, find.text('Stok Tidak Mencukupi'));
      catat(tester, '409 stok di layar sama');
    } finally {
      await ubahProdukAdmin(1, dataProduk(produk1, stok: 5));
    }

    await kosongkanKeranjang(api);
    expect((await api.ambilKeranjang()).item, isEmpty);
    catat(tester, 'bersih-bersih');
  });
}
