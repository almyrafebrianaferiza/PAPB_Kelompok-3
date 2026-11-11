// Helper bersama untuk seluruh integration test E1-E7 ( Chrome / emulator ).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:zenvora_mobile/exceptions/galat_api.dart';
import 'package:zenvora_mobile/main.dart';
import 'package:zenvora_mobile/models/keranjang.dart';
import 'package:zenvora_mobile/models/produk.dart';
import 'package:zenvora_mobile/services/layanan_api.dart';

/// Gagalkan tes bila ada exception tertunda, dengan keterangan tahapnya.
void catat(WidgetTester tester, String tahap) {
  final e = tester.takeException();
  // ignore: avoid_print
  print('OK: $tahap');
  if (e != null) {
    // ignore: avoid_print
    print('EXCEPTION saat $tahap: $e');
    fail('EXCEPTION saat $tahap: $e');
  }
}

/// Ketuk ikon pada bilah atas. Lencana keranjang menutupi sebagian ikon, jadi
/// titik ketuk digeser ke kiri-bawah agar tetap mengenai IconButton.
Future<void> ketukIkon(
  WidgetTester tester,
  IconData ikon, {
  Offset geser = const Offset(-10, 10),
}) async {
  final finder = find.byIcon(ikon);
  await tester.tapAt(tester.getCenter(finder) + geser);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Pastikan stok sebuah produk bernilai tertentu (menyesuaikan unit fisik).
Future<void> aturStok(LayananApi api, int produkId, int stok) async {
  final p = await api.rincianProduk(produkId);
  if (p.stok != stok) {
    await api.ubahProduk(produkId, dataProduk(p, stok: stok));
  }
}

/// Bangun aplikasi dari main() (jalur produksi).
Future<void> pumpAplikasi(WidgetTester tester) async {
  await tester.pumpWidget(AplikasiZenvora(layananApi: LayananApi()));
  await tester.pump();
}

/// Tunggu finder tampil sambil tetap memompa frame (timeout aman).
Future<void> tungguMuncul(
  WidgetTester tester,
  Finder finder, {
  Duration batas = const Duration(seconds: 12),
}) async {
  final akhir = DateTime.now().add(batas);
  while (DateTime.now().isBefore(akhir)) {
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
  throw StateError('Tidak muncul dalam ${batas.inSeconds} dtk: $finder');
}

/// Tunggu finder hilang (mis. menutup dialog/menyudahi loading).
Future<void> tungguHilang(
  WidgetTester tester,
  Finder finder, {
  Duration batas = const Duration(seconds: 12),
}) async {
  final akhir = DateTime.now().add(batas);
  while (DateTime.now().isBefore(akhir)) {
    if (finder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
  throw StateError('Tidak hilang dalam ${batas.inSeconds} dtk: $finder');
}

/// Kosongkan keranjang via API (tanpa UI) agar tiap tes punya titik awal bersih.
Future<void> kosongkanKeranjang(LayananApi api) async {
  Keranjang k;
  try {
    k = await api.ambilKeranjang();
  } on GalatApi {
    return;
  }
  for (final item in k.item) {
    await api.hapusItemKeranjang(item.id);
  }
}

/// Tambah item ke keranjang via API.
Future<void> isiKeranjang(LayananApi api, int produkId, int jumlah) async {
  await api.tambahKeranjang(produkId, jumlah);
}

/// Ambil teks nilai di baris ringkasan berlabel tertentu (mis. 'Ongkos Kirim (...').
String? nilaiBaris(WidgetTester tester, String awalanLabel) {
  final label = find.byWidgetPredicate(
    (w) => w is Text && (w.data?.startsWith(awalanLabel) ?? false),
  );
  if (label.evaluate().isEmpty) return null;
  final rows = find.ancestor(of: label, matching: find.byType(Row));
  for (final r in rows.evaluate()) {
    final row = r.widget as Row;
    if (row.children.length >= 2 && row.children.last is Text) {
      return (row.children.last as Text).data;
    }
  }
  return null;
}

/// Cari tombol ElevatedButton berdasarkan teks labelnya.
Finder tombol(String teks) => find.widgetWithText(ElevatedButton, teks);

/// Kartu produk pada katalog dikenali lewat teks namanya; naik ke Card lalu
/// cari ikon di dalamnya (untuk baris kelola produk).
Finder barisProduk(String nama, IconData ikon) => find.descendant(
      of: find.ancestor(of: find.text(nama), matching: find.byType(Card)),
      matching: find.byIcon(ikon),
    );

/// Ringkas model produk untuk pesan galat.
String ringkasProduk(Produk p) => '#${p.id} ${p.nama}';

/// Format rupiah sama persis dengan aplikasi.
String formatRupiah(num nominal) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(nominal);

/// Kolom isian TextFormField berdasarkan teks labelnya.
Finder kolom(String label) => find
    .ancestor(of: find.text(label), matching: find.byType(TextFormField))
    .first;

/// Ganti kata kunci pencarian katalog (debounce 400 ms + muat ulang server).
Future<void> gantiCari(WidgetTester tester, String teks) async {
  await tester.enterText(find.byType(TextField).first, teks);
  await tester.pump(const Duration(milliseconds: 500));
}

/// Payload utuh untuk tambah/ubah produk (kontrak api-contract 2.x).
Map<String, dynamic> dataProduk(Produk p, {int? stok}) => {
      'nama': p.nama,
      'merek': p.merek,
      'harga': p.harga,
      'stok': stok ?? p.stok,
      'berat_gram': p.beratGram,
      'garansi_bulan': p.garansiBulan,
      'kategori': p.kategori,
      'deskripsi': p.deskripsi,
    };

/// Kunci idempoten acak 32 karakter heksadesimal.
String kunciIdempoten() {
  final rand = Random.secure();
  return List<int>.generate(16, (_) => rand.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}

/// Gulir daftar utama sampai finder terlihat (delta positif = ke bawah).
Future<void> gulirKe(
  WidgetTester tester,
  Finder finder, {
  double delta = 250,
  int maksGulir = 40,
}) async {
  final daftar = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);
  final akhir = DateTime.now().add(const Duration(seconds: 10));
  while (daftar.evaluate().isEmpty && DateTime.now().isBefore(akhir)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: daftar.last,
    maxScrolls: maksGulir,
  );
  await tester.pump(const Duration(milliseconds: 100));
}
