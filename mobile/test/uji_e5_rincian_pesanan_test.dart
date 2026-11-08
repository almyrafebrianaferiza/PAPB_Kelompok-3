// E5 — Rincian pesanan: kelengkapan data, tombol transisi status (PATCH nyata),
// 409 saat transisi usang, dan "Kembali ke Katalog".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E5 rincian pesanan', (tester) async {
    final api = LayananApi();
    await kosongkanKeranjang(api);
    await aturStok(api, 1, 5);
    await isiKeranjang(api, 1, 1);

    // Pesanan baru lewat API agar statusnya pasti menunggu_pembayaran.
    final kurir = (await api.ambilKurir()).last;
    final metode = (await api.ambilMetodePembayaran()).first;
    final dibuat = await api.checkout(
      kunciIdempoten: kunciIdempoten(),
      kurirId: kurir.id,
      metodePembayaranId: metode.id,
      namaPenerima: 'Budi Santoso',
      alamatPenerima: 'Jl. Raya No. 1, Sidoarjo',
    );
    final rincianApi = await api.rincianPesanan(dibuat.id);

    await pumpAplikasi(tester);
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    await ketukIkon(tester, Icons.history_rounded);
    await tungguMuncul(tester, find.text('Riwayat Pesanan'));
    await tungguMuncul(tester, find.text(dibuat.nomorPesanan));
    catat(tester, 'riwayat');
    await tester.tap(find.text(dibuat.nomorPesanan));
    await tungguMuncul(tester, find.text('Rincian Pesanan'));
    await tungguMuncul(tester, find.text('Total Akhir'));
    catat(tester, 'rincian termuat');

    // 1. Kelengkapan data pesanan.
    expect(find.text(dibuat.nomorPesanan), findsOneWidget);
    expect(find.text('Menunggu Pembayaran'), findsOneWidget);
    expect(find.text('Informasi Pengiriman'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Jl. Raya No. 1, Sidoarjo'), findsOneWidget);
    expect(find.textContaining('Kurir: ${kurir.nama}'), findsOneWidget);
    expect(find.text('Produk Dipesan & Nomor Seri Unit'), findsOneWidget);
    expect(find.text('Nomor Seri Fisik (IMEI / S/N Unit):'), findsOneWidget);
    expect(find.text('Rincian Pembayaran'), findsOneWidget);
    expect(find.text('Subtotal Produk'), findsOneWidget);
    expect(find.text('Ongkos Kirim'), findsOneWidget);
    expect(find.text('Total Akhir'), findsOneWidget);
    expect(find.text(formatRupiah(rincianApi.total)), findsOneWidget);
    final seri = rincianApi.item.first.nomorSeri;
    expect(seri, isNotEmpty, reason: 'unit fisik harus punya nomor seri');
    expect(find.text(seri.first), findsOneWidget);
    catat(tester, 'verifikasi kelengkapan');

    // 2. Satu tombol per nilai status berikutnya; transisi mengirim PATCH nyata.
    expect(find.text('Ubah: menunggu_konfirmasi'), findsOneWidget);
    await tester.tap(find.text('Ubah: menunggu_konfirmasi'));
    await tungguMuncul(tester,
        find.text('Status pesanan berhasil diubah menjadi: menunggu_konfirmasi'));
    await tungguMuncul(tester, find.text('Menunggu Konfirmasi'));
    catat(tester, 'transisi menunggu_konfirmasi');
    expect((await api.rincianPesanan(dibuat.id)).status, 'menunggu_konfirmasi');

    // 3. 409 saat tombol usang (status diubah di luar aplikasi).
    await tungguHilang(
      tester,
      find.text('Status pesanan berhasil diubah menjadi: menunggu_konfirmasi'),
      batas: const Duration(seconds: 8),
    );
    expect(find.text('Ubah: dibayar'), findsOneWidget);
    await api.ubahStatusPesanan(dibuat.id, 'dibayar');
    await tester.tap(find.text('Ubah: dibayar'));
    await tungguMuncul(tester, find.textContaining('tidak dapat dipindah'));
    catat(tester, '409 transisi usang');

    // 4. Kembali ke katalog memakai popUntil root.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tungguMuncul(tester, find.text('Samsung Galaxy A55 5G 8/256'));
    catat(tester, 'kembali ke katalog');
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Rincian Pesanan'), findsNothing);
    await aturStok(api, 1, 5);
  });
}
