// E2 — Rincian produk: berat/garansi/deskripsi null, tombol mati saat habis
// (stok 0 dan tersedia=false), tambah berhasil, dan 409 di layar yang sama.
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/exceptions/galat_api.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2 rincian produk', (tester) async {
    final api = LayananApi();
    await kosongkanKeranjang(api);

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'katalog');

    // 1. Produk #9 (stok 0, deskripsi NULL): tanpa crash, tombol mati.
    await gantiCari(tester, 'TCL 32');
    await tungguMuncul(tester, find.text('TCL 32" HD Android TV'));
    catat(tester, 'cari TCL');
    await tester.tap(find.text('TCL 32" HD Android TV'));
    await tungguMuncul(tester, find.text('Detail Produk'));
    await tungguMuncul(tester, find.text('Deskripsi belum tersedia untuk produk ini.'));
    catat(tester, 'detail TCL');
    expect(find.text('STOK HABIS'), findsOneWidget);
    expect(find.text('Sisa Stok'), findsOneWidget);
    expect(find.text('4200 gram'), findsOneWidget);
    expect(find.text('12 Bulan'), findsOneWidget);
    expect(find.text('Stok Tidak Tersedia'), findsOneWidget);
    // Tombol mati: mengetuknya tidak mengirim apa pun dan keranjang tetap kosong.
    await tester.tap(find.text('Stok Tidak Tersedia'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.textContaining('tidak mencukupi'), findsNothing);
    expect((await api.ambilKeranjang()).totalJumlah, 0,
        reason: 'tombol mati tidak boleh menambah keranjang');
    catat(tester, 'tombol habis mati');
    await tester.pageBack();
    await tungguMuncul(tester, find.text('TCL 32" HD Android TV'));
    catat(tester, 'kembali dari TCL');

    // 2. Produk #12 (deskripsi NULL, tersedia=false -> tetap bertanda habis).
    await gantiCari(tester, 'Samsung 27');
    await tungguMuncul(tester, find.text('Samsung 27" Curved 144Hz'));
    catat(tester, 'cari Samsung 27');
    await tester.tap(find.text('Samsung 27" Curved 144Hz'));
    await tungguMuncul(tester, find.text('Detail Produk'));
    await tungguMuncul(tester, find.text('Deskripsi belum tersedia untuk produk ini.'));
    catat(tester, 'detail Samsung 27');
    expect(find.text('5500 gram'), findsOneWidget);
    expect(find.text('24 Bulan'), findsOneWidget);
    expect(find.text('HABIS'), findsOneWidget,
        reason: 'nilai stok diganti HABIS karena tersedia=false');
    expect(find.text('Stok Tidak Tersedia'), findsOneWidget,
        reason: 'tersedia=false tetap tidak bisa dibeli');
    await tester.pageBack();
    await tungguMuncul(tester, find.text('Samsung 27" Curved 144Hz'));
    catat(tester, 'kembali dari Samsung 27');

    // 3. Stok usang: server jadi 0 saat layar masih menampilkan stok 5 -> 409 di layar sama.
    await gantiCari(tester, '');
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    await tester.tap(find.text('Samsung Galaxy A55 5G 8/256'));
    await tungguMuncul(tester, find.text('Detail Produk'));
    await tungguMuncul(tester, find.text('Tambah ke Keranjang'));
    catat(tester, 'detail Samsung A55');

    final produk1 = await api.rincianProduk(1);
    var pesan409 = '';
    try {
      await api.ubahProduk(1, dataProduk(produk1, stok: 0));
      try {
        await api.tambahKeranjang(1, 1);
      } on BentrokException catch (e) {
        pesan409 = e.pesan;
      }
      expect(pesan409, isNotEmpty, reason: 'server harus menolak dengan 409');
      await tester.tap(find.text('Tambah ke Keranjang'));
      await tungguMuncul(tester, find.text(pesan409));
      catat(tester, 'snackbar 409');
      expect(find.text('Detail Produk'), findsOneWidget,
          reason: '409 tampil di layar yang sama, tanpa pindah halaman');
    } finally {
      await api.ubahProduk(1, dataProduk(produk1));
    }
    catat(tester, 'pulihkan stok 1');

    // 4. Tambah berhasil -> snackbar sukses lalu kembali ke katalog.
    // Tunggu snackbar 409 hilang agar tidak menutupi tombol bawah.
    await tungguHilang(tester, find.text(pesan409),
        batas: const Duration(seconds: 8));
    catat(tester, 'snackbar 409 hilang');
    await tester.tap(find.text('Tambah ke Keranjang'));
    await tungguMuncul(
      tester,
      find.text('1x Samsung Galaxy A55 5G 8/256 berhasil ditambahkan ke keranjang.'),
    );
    catat(tester, 'snackbar sukses');
    final k = await api.ambilKeranjang();
    expect(k.totalJumlah, 1,
        reason: 'tambah ke keranjang harus tersimpan di server');

    await kosongkanKeranjang(api);
  });
}
