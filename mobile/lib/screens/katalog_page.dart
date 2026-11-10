import 'dart:async';

import 'package:flutter/material.dart';

import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../services/layanan_api.dart';
import '../theme/zenvora_warna.dart';
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
  // Nomor urut permintaan. Dipakai agar respons lama yang datang terlambat
  // tidak menimpa hasil filter/pencarian yang lebih baru.
  int _idPermintaan = 0;

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

  // Brand pilihan ditampilkan sebagai pintasan pencarian.
  final List<Map<String, dynamic>> _daftarBrand = [
    {'nama': 'Samsung', 'ikon': Icons.phone_android_rounded},
    {'nama': 'Apple', 'ikon': Icons.phone_iphone_rounded},
    {'nama': 'ASUS', 'ikon': Icons.laptop_mac_rounded},
    {'nama': 'Xiaomi', 'ikon': Icons.devices_other_rounded},
    {'nama': 'Lenovo', 'ikon': Icons.computer_rounded},
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
    if (!_pengontrolGulir.hasClients) return;

    if (_pengontrolGulir.position.pixels >=
            _pengontrolGulir.position.maxScrollExtent - 200 &&
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
      // Lencana keranjang bersifat pelengkap. Bila gagal dimuat, angka lama
      // dikosongkan agar tidak menampilkan jumlah yang sudah tidak akurat.
      if (mounted) {
        setState(() {
          _jumlahItemKeranjang = 0;
        });
      }
    }
  }

  Future<void> _muatData({bool ulang = false}) async {
    final idPermintaan = ++_idPermintaan;

    if (ulang) {
      setState(() {
        _keadaan = KeadaanMuat.memuat;
        _halaman = 1;
        _apakahMemuatLagi = false;
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

      if (!mounted || idPermintaan != _idPermintaan) return;
      setState(() {
        _daftarProduk = respon;
        _adaHalamanBerikutnya = respon.length >= 10;
        _keadaan = respon.isEmpty ? KeadaanMuat.kosong : KeadaanMuat.berhasil;
      });
    } on GalatApi catch (e) {
      if (!mounted || idPermintaan != _idPermintaan) return;
      setState(() {
        _galat = e;
        _keadaan = KeadaanMuat.galat;
      });
    }
  }

  Future<void> _muatHalamanBerikutnya() async {
    if (_apakahMemuatLagi || !_adaHalamanBerikutnya) return;

    final idPermintaan = _idPermintaan;
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

      // Filter/pencarian bisa berubah saat halaman ini masih dimuat. Respons
      // lama diabaikan agar daftar tidak tercampur hasil permintaan sebelumnya.
      if (!mounted || idPermintaan != _idPermintaan) return;
      setState(() {
        _halaman = halamanBaru;
        _daftarProduk.addAll(respon);
        _adaHalamanBerikutnya = respon.length >= 10;
        _apakahMemuatLagi = false;
      });
    } on GalatApi catch (_) {
      if (!mounted || idPermintaan != _idPermintaan) return;
      // Galat halaman lanjutan tidak boleh menghapus daftar yang sudah tampil.
      setState(() {
        _apakahMemuatLagi = false;
      });
    }
  }

  void _padaPencarianDiubah(String nilai) {
    _penundaPencarian?.cancel();
    _penundaPencarian = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _pencarian = nilai.trim();
      });
      _muatData(ulang: true);
    });
  }

  void _cariBrand(String brand) {
    _pengontrolCari.text = brand;
    _padaPencarianDiubah(brand);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo-zenvora.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) =>
                      RiwayatPesananPage(layananApi: widget.layananApi),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Kelola Produk',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) =>
                      KelolaProdukPage(layananApi: widget.layananApi),
                ),
              );
              _muatData(ulang: true);
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Keranjang Belanja',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) =>
                          KeranjangPage(layananApi: widget.layananApi),
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
                      color: ZWarna.galat,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_jumlahItemKeranjang',
                      style: const TextStyle(
                        color: ZWarna.putih,
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
          Container(
            color: ZWarna.permukaan,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _pengontrolCari,
              onChanged: _padaPencarianDiubah,
              style: const TextStyle(color: ZWarna.putih, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari gadget, spesifikasi, merk...',
                prefixIcon: const Icon(Icons.search, color: ZWarna.teksSamar),
                suffixIcon: _pengontrolCari.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: ZWarna.teksSekunder),
                        onPressed: () {
                          _pengontrolCari.clear();
                          _padaPencarianDiubah('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: ZWarna.permukaanTinggi,
                hintStyle:
                    const TextStyle(color: ZWarna.teksSamar, fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZRadius.sedang),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            color: ZWarna.permukaan,
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _daftarKategori.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final kat = _daftarKategori[i];
                final bool terpilih =
                    (_kategoriDipilih == null && kat == 'Semua') ||
                        _kategoriDipilih == kat;

                return ChoiceChip(
                  label: Text(
                    kat == 'Semua'
                        ? kat
                        : '${kat[0].toUpperCase()}${kat.substring(1)}',
                  ),
                  selected: terpilih,
                  selectedColor: ZWarna.oranye,
                  backgroundColor: ZWarna.permukaanTinggi,
                  labelStyle: TextStyle(
                    color: terpilih ? ZWarna.hitam : ZWarna.teksSekunder,
                    fontSize: 12,
                    fontWeight: terpilih ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: terpilih ? ZWarna.oranye : ZWarna.batas,
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
          const Divider(height: 1, thickness: 0.5, color: ZWarna.batas),
          Expanded(child: _bangunKonten()),
        ],
      ),
    );
  }

  Widget _bangunBannerPromo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lebar = constraints.maxWidth;

        // Tinggi banner menyesuaikan lebar layar
        final tinggi = lebar > 900
            ? 400.0
            : lebar > 600
                ? 260.0
                : 220.0;

        return Container(
          height: tinggi,
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            image: const DecorationImage(
              image: AssetImage('assets/images/banner_produk.png'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ZWarna.oranye.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: lebar > 600 ? lebar * 0.45 : lebar * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'WELCOME TO ZENVORĀ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upgrade Your\nDigital Lifestyle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Temukan teknologi yang mendukung aktivitasmu.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bangunBrandPilihan() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _judulBagian('Jelajahi Brand', 'Temukan perangkat favoritmu'),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _daftarBrand.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final brand = _daftarBrand[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _cariBrand(brand['nama'] as String),
                  child: Container(
                    width: 88,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: ZWarna.permukaanTinggi,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ZWarna.batas),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          brand['ikon'] as IconData,
                          color: ZWarna.oranye,
                          size: 23,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          brand['nama'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ZWarna.putih,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _judulBagian(String judul, String subjudul) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: const TextStyle(
            color: ZWarna.putih,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subjudul,
          style: const TextStyle(
            color: ZWarna.teksSekunder,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Banner dan brand tetap ditampilkan walaupun API sedang loading,
  // gagal merespons, atau belum memiliki produk.
  Widget _bangunKonten() {
    final bool tampilkanBeranda =
        _pencarian.isEmpty && _kategoriDipilih == null;

    return RefreshIndicator(
      onRefresh: () async {
        await _muatData(ulang: true);
        await _muatJumlahKeranjang();
      },
      color: ZWarna.oranye,
      child: CustomScrollView(
        controller: _pengontrolGulir,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (tampilkanBeranda) ...[
            SliverToBoxAdapter(child: _bangunBannerPromo()),
            SliverToBoxAdapter(child: _bangunBrandPilihan()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: _judulBagian(
                  'Produk Pilihan',
                  'Pilihan perangkat untuk kebutuhan digitalmu',
                ),
              ),
            ),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: _judulBagian(
                  'Hasil Produk',
                  '${_daftarProduk.length} produk ditampilkan',
                ),
              ),
            ),

          // Kondisi loading, error, dan kosong ditampilkan di bawah banner.
          if (_keadaan == KeadaanMuat.memuat && _daftarProduk.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: ZWarna.oranye),
              ),
            )
          else if (_keadaan == KeadaanMuat.galat && _daftarProduk.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: TampilanGalat(
                  galat: _galat ?? ServerException('Terjadi kesalahan sistem'),
                  saatCobaLagi: () => _muatData(ulang: true),
                ),
              ),
            )
          else if (_daftarProduk.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: TampilanKosong(
                  ikon: Icons.devices_outlined,
                  judul: 'Tidak Ada Produk Ditemukan',
                  pesan:
                      'Coba ubah kata kunci pencarian atau pilih kategori lain.',
                  teksTombolAksi: 'Reset Filter',
                  saatTombolDitekan: () {
                    _pengontrolCari.clear();
                    setState(() {
                      _pencarian = '';
                      _kategoriDipilih = null;
                    });
                    _muatData(ulang: true);
                  },
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i >= _daftarProduk.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: ZWarna.oranye,
                            strokeWidth: 2,
                          ),
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
                  childCount:
                      _daftarProduk.length + (_apakahMemuatLagi ? 2 : 0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
