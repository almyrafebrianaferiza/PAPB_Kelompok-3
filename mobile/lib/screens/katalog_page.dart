import 'dart:async';
import 'package:flutter/material.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../services/layanan_api.dart';
import '../widgets/kartu_produk.dart';
import '../widgets/tampilan_galat.dart';
import '../widgets/tampilan_kosong.dart';
import 'rincian_produk_page.dart';
import 'keranjang_page.dart';
import 'riwayat_pesanan_page.dart';
import 'kelola_produk_page.dart';

class KatalogPage extends StatefulWidget {
  final LayananApi layananApi;

  const KatalogPage({super.key, required this.layananApi});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;
  List<Produk> _daftarProduk = [];
  int _halaman = 1;
  bool _apakahMemuatLagi = false;
  bool _adaHalamanBerikutnya = true;

  String _pencarian = '';
  String? _kategoriDipilih;
  Timer? _penundaPencarian;
  final TextEditingController _pengontrolCari = TextEditingController();
  final ScrollController _pengontrolGulir = ScrollController();

  int _jumlahItemKeranjang = 0;

  final List<String> _daftarKategori = [
    'Semua',
    'gadget',
    'laptop',
    'tv',
    'monitor',
    'tablet',
  ];

  @override
  void initState() {
    super.initState();
    _muatData(ulang: true);
    _muatJumlahKeranjang();
    _pengontrolGulir.addListener(_padaGulir);
  }

  @override
  void dispose() {
    _penundaPencarian?.cancel();
    _pengontrolCari.dispose();
    _pengontrolGulir.dispose();
    super.dispose();
  }

  void _padaGulir() {
    if (_pengontrolGulir.position.pixels >= _pengontrolGulir.position.maxScrollExtent - 200 &&
        !_apakahMemuatLagi &&
        _adaHalamanBerikutnya &&
        _keadaan == KeadaanMuat.berhasil) {
      _muatHalamanBerikutnya();
    }
  }

  Future<void> _muatJumlahKeranjang() async {
    try {
      final keranjang = await widget.layananApi.ambilKeranjang();
      if (mounted) {
        setState(() {
          _jumlahItemKeranjang = keranjang.totalJumlah;
        });
      }
    } on GalatApi catch (_) {
      // Galat memuat lencana tidak menggagalkan katalog; nilai terakhir dipakai.
    }
  }

  Future<void> _muatData({bool ulang = false}) async {
    if (ulang) {
      setState(() {
        _keadaan = KeadaanMuat.memuat;
        _halaman = 1;
        _daftarProduk.clear();
        _galat = null;
      });
    }

    try {
      final respon = await widget.layananApi.daftarProduk(
        kategori: _kategoriDipilih,
        cari: _pencarian.isEmpty ? null : _pencarian,
        halaman: _halaman,
        perHalaman: 10,
      );

      if (mounted) {
        setState(() {
          _daftarProduk = respon;
          _adaHalamanBerikutnya = respon.length >= 10;
          _keadaan = respon.isEmpty ? KeadaanMuat.kosong : KeadaanMuat.berhasil;
        });
      }
    } on GalatApi catch (e) {
      if (mounted) {
        setState(() {
          _galat = e;
          _keadaan = KeadaanMuat.galat;
        });
      }
    }
  }

  Future<void> _muatHalamanBerikutnya() async {
    if (_apakahMemuatLagi || !_adaHalamanBerikutnya) return;

    setState(() {
      _apakahMemuatLagi = true;
    });

    final halamanBaru = _halaman + 1;
    try {
      final respon = await widget.layananApi.daftarProduk(
        kategori: _kategoriDipilih,
        cari: _pencarian.isEmpty ? null : _pencarian,
        halaman: halamanBaru,
        perHalaman: 10,
      );

      if (mounted) {
        setState(() {
          _halaman = halamanBaru;
          _daftarProduk.addAll(respon);
          _adaHalamanBerikutnya = respon.length >= 10;
          _apakahMemuatLagi = false;
        });
      }
    } on GalatApi catch (_) {
      // Galat saat lazy load: hentikan pemuatan lanjutan tanpa menghapus data yang sudah tampil.
      if (mounted) {
        setState(() {
          _apakahMemuatLagi = false;
        });
      }
    }
  }

  void _padaPencarianDiubah(String nilai) {
    _penundaPencarian?.cancel();
    _penundaPencarian = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _pencarian = nilai.trim();
      });
      _muatData(ulang: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Zenvorā',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF475569)),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => RiwayatPesananPage(layananApi: widget.layananApi),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF475569)),
            tooltip: 'Kelola Produk',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => KelolaProdukPage(layananApi: widget.layananApi),
                ),
              );
              _muatData(ulang: true);
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0F172A)),
                tooltip: 'Keranjang Belanja',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => KeranjangPage(layananApi: widget.layananApi),
                    ),
                  );
                  _muatJumlahKeranjang();
                },
              ),
              if (_jumlahItemKeranjang > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_jumlahItemKeranjang',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Bar Pencarian
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _pengontrolCari,
              onChanged: _padaPencarianDiubah,
              decoration: InputDecoration(
                hintText: 'Cari gadget, spesifikasi, merk...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                suffixIcon: _pencarian.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _pengontrolCari.clear();
                          _padaPencarianDiubah('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Bar Kategori Chips
          Container(
            color: Colors.white,
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _daftarKategori.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final kat = _daftarKategori[i];
                final bool terpilih = (_kategoriDipilih == null && kat == 'Semua') ||
                    _kategoriDipilih == kat;

                return ChoiceChip(
                  label: Text(
                    kat == 'Semua' ? kat : '${kat[0].toUpperCase()}${kat.substring(1)}',
                  ),
                  selected: terpilih,
                  selectedColor: const Color(0xFF0284C7),
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: terpilih ? Colors.white : const Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: terpilih ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (val) {
                    setState(() {
                      _kategoriDipilih = kat == 'Semua' ? null : kat;
                    });
                    _muatData(ulang: true);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Area Konten
          Expanded(
            child: _bangunKonten(),
          ),
        ],
      ),
    );
  }

  Widget _bangunKonten() {
    if (_keadaan == KeadaanMuat.memuat && _daftarProduk.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0284C7)),
      );
    }

    if (_keadaan == KeadaanMuat.galat && _daftarProduk.isEmpty) {
      return TampilanGalat(
        galat: _galat ?? ServerException('Terjadi kesalahan sistem'),
        saatCobaLagi: () => _muatData(ulang: true),
      );
    }

    if (_daftarProduk.isEmpty) {
      return TampilanKosong(
        ikon: Icons.devices_outlined,
        judul: 'Tidak Ada Produk Ditemukan',
        pesan: 'Coba ubah kata kunci pencarian atau pilih kategori lain.',
        teksTombolAksi: 'Reset Filter',
        saatTombolDitekan: () {
          _pengontrolCari.clear();
          setState(() {
            _pencarian = '';
            _kategoriDipilih = null;
          });
          _muatData(ulang: true);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _muatData(ulang: true);
        await _muatJumlahKeranjang();
      },
      color: const Color(0xFF0284C7),
      child: GridView.builder(
        controller: _pengontrolGulir,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _daftarProduk.length + (_apakahMemuatLagi ? 2 : 0),
        itemBuilder: (ctx, i) {
          if (i >= _daftarProduk.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final prod = _daftarProduk[i];
          return KartuProduk(
            produk: prod,
            saatDiketuk: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => RincianProdukPage(
                    idProduk: prod.id,
                    layananApi: widget.layananApi,
                  ),
                ),
              );
              _muatJumlahKeranjang();
            },
          );
        },
      ),
    );
  }
}
