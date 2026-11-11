// F2 — Lazy load Katalog: 10 lalu 5 item, berhenti di halaman terakhir,
// respons usang diabaikan, dan galat halaman lanjutan tidak menghapus daftar.
//
// Tes ini memakai LayananApi palsu sehingga tidak membutuhkan server/backend.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvora_mobile/exceptions/galat_api.dart';
import 'package:zenvora_mobile/models/keranjang.dart';
import 'package:zenvora_mobile/models/produk.dart';
import 'package:zenvora_mobile/screens/katalog_page.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

class _ApiPalsu extends LayananApi {
  final List<Map<String, dynamic>> panggilan = [];
  final Map<String, List<Produk>> dataHalaman = {};
  final Map<String, Completer<List<Produk>>> tundaKategori = {};
  GalatApi? galatHalamanDua;

  @override
  Future<List<Produk>> daftarProduk({
    String? kategori,
    String? cari,
    int halaman = 1,
    int perHalaman = 10,
  }) async {
    panggilan.add({'kategori': kategori, 'halaman': halaman});
    final tunda = tundaKategori[kategori];
    if (tunda != null) return tunda.future;
    if (halaman == 2 && galatHalamanDua != null) throw galatHalamanDua!;
    // Salin daftar agar `_daftarProduk.clear()` di layar tidak ikut
    // mengosongkan data sumber milik fake.
    return List<Produk>.of(dataHalaman['$kategori-$halaman'] ?? const []);
  }

  @override
  Future<Keranjang> ambilKeranjang() async =>
      Keranjang(item: const [], totalJumlah: 0, subtotal: 0);
}

Produk _produk(int id, String nama, {String kategori = 'gadget'}) => Produk(
      id: id,
      nama: nama,
      merek: 'Merek',
      harga: 1000000,
      kategori: kategori,
      stok: 1,
      tersedia: true,
      beratGram: 100,
      garansiBulan: 12,
    );

Future<void> _bukaKatalog(WidgetTester tester, LayananApi api) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: KatalogPage(layananApi: api)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

int _jumlahKartu(WidgetTester tester) {
  final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
  final delegate = grid.delegate as SliverChildBuilderDelegate;
  return delegate.childCount ?? 0;
}

void main() {
  testWidgets('F2 memuat 10 lalu 5 item dan berhenti di halaman terakhir',
      (tester) async {
    final api = _ApiPalsu();
    api.dataHalaman['null-1'] =
        List.generate(10, (i) => _produk(i + 1, 'Halaman 1 - ${i + 1}'));
    api.dataHalaman['null-2'] =
        List.generate(5, (i) => _produk(i + 11, 'Halaman 2 - ${i + 1}'));

    await _bukaKatalog(tester, api);
    expect(_jumlahKartu(tester), 10);
    expect(api.panggilan.where((p) => p['halaman'] == 1), hasLength(1));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(api.panggilan.where((p) => p['halaman'] == 2), hasLength(1));
    expect(_jumlahKartu(tester), 15);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(api.panggilan.where((p) => p['halaman'] == 3), isEmpty);
    expect(find.text('Tidak Ada Produk Ditemukan'), findsNothing);
  });

  testWidgets('F2 respons lama tidak menimpa hasil filter terbaru',
      (tester) async {
    final api = _ApiPalsu();
    api.dataHalaman['null-1'] = [_produk(1, 'Produk Umum')];
    api.dataHalaman['laptop-1'] = [
      _produk(2, 'Produk Laptop', kategori: 'laptop'),
    ];
    final tundaLaptop = Completer<List<Produk>>();
    api.tundaKategori['laptop'] = tundaLaptop;

    await _bukaKatalog(tester, api);
    expect(find.text('Produk Umum'), findsOneWidget);

    await tester.tap(find.text('Laptop'));
    await tester.pump();

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Produk Umum'), findsOneWidget);

    tundaLaptop.complete([_produk(2, 'Produk Laptop', kategori: 'laptop')]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Produk Umum'), findsOneWidget);
    expect(find.text('Produk Laptop'), findsNothing);
  });

  testWidgets('F2 galat halaman lanjutan tidak menghapus daftar',
      (tester) async {
    final api = _ApiPalsu();
    api.dataHalaman['null-1'] =
        List.generate(10, (i) => _produk(i + 1, 'Halaman 1 - ${i + 1}'));
    api.galatHalamanDua = SambunganGagalException();

    await _bukaKatalog(tester, api);
    expect(_jumlahKartu(tester), 10);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(api.panggilan.where((p) => p['halaman'] == 2), hasLength(1));
    expect(_jumlahKartu(tester), 10);
    expect(find.text('Koneksi Terputus'), findsNothing);
    expect(find.text('Tidak Ada Produk Ditemukan'), findsNothing);
  });
}
