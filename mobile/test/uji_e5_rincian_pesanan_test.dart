// E5 — Rincian pesanan untuk pembeli: kelengkapan data, nomor seri, dan
// tampilan read-only (tanpa tombol ubah status; status dikelola penjual di web).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

import 'uji_e_util.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E5 rincian pesanan read-only', (tester) async {
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
    await tungguMuncul(tester, find.byIcon(Icons.history_rounded));
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

    // 2. Pembeli tidak memiliki wewenang mengubah status pesanan.
    expect(find.textContaining('Ubah:'), findsNothing);
    expect(find.text('Batalkan Pesanan'), findsNothing);
    expect(
      find.textContaining('Status pesanan diperbarui oleh penjual'),
      findsOneWidget,
    );
    expect((await api.rincianPesanan(dibuat.id)).status, 'menunggu_pembayaran');
    catat(tester, 'read-only tanpa tombol status');

    // 3. Kembali ke katalog memakai popUntil root.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tungguMuncul(tester, find.byType(AppBar));
    catat(tester, 'kembali ke katalog');
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Rincian Pesanan'), findsNothing);
    final sisaGalat = tester.takeException();
    if (sisaGalat != null) fail('Galat tak tertangani: $sisaGalat');
    await aturStok(api, 1, 5);
  });
}
