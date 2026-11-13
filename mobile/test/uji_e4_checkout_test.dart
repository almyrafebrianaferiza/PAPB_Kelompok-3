// E4 — Checkout: validasi server 422 per kolom, ganti kurir (ongkir server),
// tombol mati saat proses, kunci idempoten dipakai ulang, 409, 201 -> Rincian,
// ketuk dua kali -> satu pesanan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E4 checkout', (tester) async {
    final penanganSebelumnya = FlutterError.onError;
    FlutterError.onError = (d) {
      // ignore: avoid_print
      print('GALAT FRAMEWORK: ${d.exceptionAsString()}');
      penanganSebelumnya?.call(d);
    };
    addTearDown(() => FlutterError.onError = penanganSebelumnya);
    final api = LayananApi();
    await kosongkanKeranjang(api);
    await aturStok(api, 1, 5);
    await isiKeranjang(api, 1, 2);

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.byIcon(Icons.shopping_cart_outlined));
    await tester.pump(const Duration(milliseconds: 800));
    await ketukIkon(tester, Icons.shopping_cart_outlined);
    await tungguMuncul(tester, find.text('Total Harga'));
    catat(tester, 'keranjang');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Checkout'));
    await tungguMuncul(tester, find.text('Pengiriman & Checkout'));
    await tungguMuncul(tester, find.text('Total Tagihan'));
    catat(tester, 'halaman checkout');

    // 1. Validasi 422 per kolom dari server (CheckoutRequest).
    await tester.enterText(kolom('Nama Lengkap Penerima *'), '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'));
    await tungguMuncul(tester, find.text('Nama penerima wajib diisi'));
    catat(tester, '422 nama');
    await tester.enterText(kolom('Nama Lengkap Penerima *'), 'Ahmad Fauzi');
    await tester.enterText(kolom('Alamat Lengkap Pengiriman *'), 'pendek');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'));
    await tungguMuncul(
        tester, find.text('Alamat penerima minimal 10 karakter'));
    expect(find.text('Pengiriman & Checkout'), findsOneWidget);
    catat(tester, '422 alamat');
    await tester.enterText(kolom('Alamat Lengkap Pengiriman *'),
        'Jl. Ijen No. 45, Klojen, Kota Malang');
    await tester.pump(const Duration(milliseconds: 200));

    // 2. Ganti kurir -> ongkir & total estimasi berubah, dari server.
    final daftarKurir = await api.ambilKurir();
    expect(daftarKurir.length, greaterThanOrEqualTo(2));
    final ongkirAwal = nilaiBaris(tester, 'Ongkos Kirim (');
    expect(ongkirAwal, formatRupiah(daftarKurir[0].ongkir));
    await tester.ensureVisible(find.text(daftarKurir[1].nama));
    await tester.tap(find.text(daftarKurir[1].nama));
    await tester.pump(const Duration(milliseconds: 300));
    final ongkirBaru = nilaiBaris(tester, 'Ongkos Kirim (');
    expect(ongkirBaru, formatRupiah(daftarKurir[1].ongkir));
    expect(ongkirBaru, isNot(equals(ongkirAwal)));
    expect(find.text(formatRupiah(daftarKurir[1].totalEstimasi)), findsWidgets);
    catat(tester, 'ganti kurir');

    // 3. 409 stok (stok produk 1 jadi 0 saat form terbuka) -> dialog di layar sama.
    final produk1 = await api.rincianProduk(1);
    final jumlahPesananAwal = (await api.riwayatPesanan()).length;
    try {
      await ubahProdukAdmin(1, dataProduk(produk1, stok: 0));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'));
      await tungguMuncul(tester, find.text('Stok Tidak Mencukupi'));
      expect(find.text('Pengiriman & Checkout'), findsOneWidget);
      await tester.tap(find.text('Tutup'));
      await tungguHilang(tester, find.text('Stok Tidak Mencukupi'));
      catat(tester, 'dialog 409');
    } finally {
      await ubahProdukAdmin(1, dataProduk(produk1, stok: 5));
    }

    // 4. Ketuk dua kali cepat -> tepat satu pesanan (kunci idempoten + tombol mati).
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Pesanan'),
        warnIfMissed: false);
    catat(tester, 'dua ketukan');
    await tungguMuncul(tester, find.text('Rincian Pesanan'));
    await tungguMuncul(tester, find.textContaining('Pesanan berhasil dibuat:'));
    catat(tester, 'rincian pesanan');
    await tungguMuncul(tester, find.text('Total Akhir'));
    catat(tester, 'rincian termuat');
    expect(find.text('Menunggu Pembayaran'), findsOneWidget);

    final tombolBayar = find.widgetWithText(ElevatedButton, 'Saya Sudah Bayar');
    await tester.ensureVisible(tombolBayar);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(tombolBayar);
    await tungguMuncul(tester, find.text('Menunggu Konfirmasi'));
    catat(tester, 'konfirmasi pembayaran');

    final jumlahPesananAkhir = (await api.riwayatPesanan()).length;
    expect(jumlahPesananAkhir, jumlahPesananAwal + 1,
        reason: 'dua ketukan cepat tetap menghasilkan satu pesanan');
    expect((await api.ambilKeranjang()).item, isEmpty,
        reason: 'keranjang dikosongkan server setelah checkout');
    catat(tester, 'verifikasi akhir');
  });
}
