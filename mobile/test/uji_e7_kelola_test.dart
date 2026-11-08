// E7 — Kelola produk: validator form, tambah/ubah/hapus nyata, dan 409 saat
// produk masih dipakai pesanan berjalan.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E7 kelola produk', (tester) async {
    final api = LayananApi();
    final namaAwal = 'Zenvora Uji E7 ${DateTime.now().millisecondsSinceEpoch}';
    final namaBaru = '$namaAwal (diubah)';
    int? idBaru;

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    await ketukIkon(tester, Icons.admin_panel_settings_outlined);
    await tungguMuncul(tester, find.text('Kelola Produk (CRUD)'));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'kelola termuat');

    // 1. Validator wajib isi pada form tambah.
    await tester.tap(find.text('Tambah Produk'));
    await tungguMuncul(tester, find.text('Tambah Produk Baru'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah Produk'));
    await tungguMuncul(tester, find.text('Nama Produk * wajib diisi'));
    expect(find.text('Harga (Rp) * wajib diisi'), findsOneWidget);
    catat(tester, 'validator');

    // 2. Tambah produk baru (harga Rp1.234.000, stok bawaan 10).
    await tester.enterText(kolom('Nama Produk *'), namaAwal);
    await tester.enterText(kolom('Harga (Rp) *'), '1234000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah Produk'));
    await tungguMuncul(tester, find.text('Produk berhasil ditambahkan.'));
    await tungguMuncul(tester, find.text('Kelola Produk (CRUD)'));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'tambah produk');

    var daftar = await api.daftarProduk(halaman: 1, perHalaman: 50);
    final baru = daftar.where((p) => p.nama == namaAwal).toList();
    expect(baru, hasLength(1), reason: 'produk baru tersimpan di server');
    expect(baru.single.harga, 1234000);
    expect(baru.single.stok, 10);
    idBaru = baru.single.id;
    await gulirKe(tester, find.text(namaAwal), delta: 300);
    expect(find.text(namaAwal), findsOneWidget);
    await tungguHilang(tester, find.text('Produk berhasil ditambahkan.'));
    catat(tester, 'produk baru tampil');

    // 3. Ubah nama produk.
    await tester.tap(barisProduk(namaAwal, Icons.edit_outlined));
    await tungguMuncul(tester, find.text('Ubah Produk'));
    await tester.enterText(kolom('Nama Produk *'), namaBaru);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan Perubahan'));
    await tungguMuncul(tester, find.text('Produk berhasil diperbarui.'));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'ubah produk');

    daftar = await api.daftarProduk(halaman: 1, perHalaman: 50);
    expect(daftar.where((p) => p.nama == namaBaru), hasLength(1));
    await gulirKe(tester, find.text(namaBaru), delta: 300);
    expect(find.text(namaBaru), findsOneWidget);
    await tungguHilang(tester, find.text('Produk berhasil diperbarui.'));

    // 4. Hapus produk baru lewat dialog konfirmasi.
    await tester.tap(barisProduk(namaBaru, Icons.delete_outline));
    await tungguMuncul(tester, find.text('Hapus Produk?'));
    await tester.tap(find.text('Ya, Hapus'));
    await tungguMuncul(tester, find.text('Produk "$namaBaru" berhasil dihapus.'));
    await tungguHilang(tester, find.text(namaBaru));
    catat(tester, 'hapus produk');

    daftar = await api.daftarProduk(halaman: 1, perHalaman: 50);
    expect(daftar.where((p) => p.id == idBaru), isEmpty);
    idBaru = null;

    // 5. 409: hapus produk yang masih dipakai pesanan berjalan (Xiaomi #2).
    await tungguMuncul(tester, find.byIcon(Icons.edit_outlined));
    await gulirKe(tester, find.text('Xiaomi Redmi Note 13 Pro'), delta: -300);
    await tester
        .tap(barisProduk('Xiaomi Redmi Note 13 Pro', Icons.delete_outline));
    await tungguMuncul(tester, find.text('Hapus Produk?'));
    await tester.tap(find.text('Ya, Hapus'));
    await tungguMuncul(tester, find.text('Gagal Menghapus (409)'));
    expect(find.textContaining('masih ada pada pesanan yang berjalan'),
        findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tungguHilang(tester, find.text('Gagal Menghapus (409)'));
    catat(tester, '409 hapus');

    daftar = await api.daftarProduk(halaman: 1, perHalaman: 50);
    expect(daftar.where((p) => p.nama == 'Xiaomi Redmi Note 13 Pro'),
        hasLength(1));

    // 6. Kembali ke katalog.
    await tester.pageBack();
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Kelola Produk (CRUD)'), findsNothing);

    if (idBaru != null) {
      await api.hapusProduk(idBaru);
    }
  });
}
