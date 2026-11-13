import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../services/layanan_api.dart';
import '../theme/zenvora_warna.dart';
import '../widgets/penanda_habis.dart';
import '../widgets/tampilan_galat.dart';

class RincianProdukPage extends StatefulWidget {
  final int idProduk;
  final LayananApi layananApi;

  const RincianProdukPage({super.key,
    required this.idProduk,
    required this.layananApi,
  });

  @override
  State<RincianProdukPage> createState() => _RincianProdukPageState();
}

class _RincianProdukPageState extends State<RincianProdukPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;
  Produk? _produk;
  ProdukVarian? _varianTerpilih;
  int _kuantitas = 1;
  bool _sedangMenambahkan = false;

  int get _hargaAktif => _varianTerpilih?.harga ?? _produk?.harga ?? 0;
  int get _stokAktif => _varianTerpilih?.stok ?? _produk?.stok ?? 0;
  bool get _apakahHabisAktif {
    if (_produk == null) return true;
    if (_varianTerpilih != null) return _varianTerpilih!.isHabis || !_produk!.tersedia;
    return _produk!.isHabis;
  }

  @override
  void initState() {
    super.initState();
    _muatRincian();
  }

  Future<void> _muatRincian() async {
    setState(() {
      _keadaan = KeadaanMuat.memuat;
      _galat = null;
    });

    try {
      final p = await widget.layananApi.rincianProduk(widget.idProduk);
      if (mounted) {
        setState(() {
          _produk = p;
          if (p.varian.isNotEmpty) {
            _varianTerpilih = p.varian.first;
          }
          _keadaan = KeadaanMuat.berhasil;
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

  Future<void> _tambahKeKeranjang() async {
    if (_produk == null || _produk!.isHabis) return;

    setState(() {
      _sedangMenambahkan = true;
    });

    try {
      await widget.layananApi.tambahKeranjang(_produk!.id, _kuantitas);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_kuantitas}x ${_produk!.nama} berhasil ditambahkan ke keranjang.'),
            backgroundColor: ZWarna.sukses,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.pesan),
            backgroundColor: ZWarna.galat,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangMenambahkan = false;
        });
      }
    }
  }

  String _formatRupiah(num nominal) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunNavigasiBawah(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_keadaan == KeadaanMuat.galat) {
      return TampilanGalat(
        galat: _galat ?? ServerException('Gagal memuat rincian produk'),
        saatCobaLagi: _muatRincian,
      );
    }

    final p = _produk!;
    final bool apakahHabis = p.isHabis;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 260,
            width: double.infinity,
            color: ZWarna.permukaanTinggi,
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.devices_other, size: 80, color: ZWarna.teksSamar),
                ),
                if (apakahHabis)
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: PenandaHabis(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: ZWarna.permukaan,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ZWarna.oranye.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p.kategori,
                        style: const TextStyle(
                          color: ZWarna.oranyeTerang,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      p.merek,
                      style: const TextStyle(
                        color: ZWarna.teksSekunder,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  p.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ZWarna.putih,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatRupiah(_hargaAktif),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: ZWarna.oranye,
                  ),
                ),
                if (p.varian.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Pilihan Varian / Spesifikasi:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ZWarna.teksSekunder,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.varian.map((v) {
                      final bool terpilih = _varianTerpilih?.id == v.id;
                      final bool habis = v.isHabis;
                      return ChoiceChip(
                        selected: terpilih,
                        selectedColor: ZWarna.oranye,
                        backgroundColor: ZWarna.permukaanTinggi,
                        side: BorderSide(color: terpilih ? ZWarna.oranye : ZWarna.batas),
                        label: Text(
                          '${v.namaVarian}${habis ? ' (Habis)' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: terpilih ? FontWeight.bold : FontWeight.w500,
                            color: terpilih ? ZWarna.hitam : (habis ? ZWarna.teksSamar : ZWarna.putih),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _varianTerpilih = v;
                              if (_kuantitas > v.stok && v.stok > 0) {
                                _kuantitas = v.stok;
                              }
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: ZWarna.batas),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _itemSpesifikasi(
                      Icons.inventory_2_outlined,
                      'Sisa Stok',
                      _apakahHabisAktif ? 'HABIS' : '$_stokAktif unit',
                      _apakahHabisAktif ? ZWarna.galat : ZWarna.sukses,
                    ),
                    _itemSpesifikasi(
                      Icons.scale_outlined,
                      'Berat Fisik',
                      '${_varianTerpilih?.beratGram ?? p.beratGram} gram',
                      ZWarna.putih,
                    ),
                    _itemSpesifikasi(
                      Icons.verified_user_outlined,
                      'Garansi Resmi',
                      '${p.garansiBulan} Bulan',
                      ZWarna.oranye,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: ZWarna.permukaan,
            padding: const EdgeInsets.all(18),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ZWarna.putih,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  p.deskripsi != null && p.deskripsi!.trim().isNotEmpty
                      ? p.deskripsi!
                      : 'Deskripsi belum tersedia untuk produk ini.',
                  style: TextStyle(
                    fontSize: 14,
                    color: p.deskripsi != null && p.deskripsi!.trim().isNotEmpty
                        ? ZWarna.teksSekunder
                        : ZWarna.teksSamar,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _itemSpesifikasi(IconData ikon, String label, String nilai, Color warnaNilai) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 14, color: ZWarna.teksSekunder),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: warnaNilai,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _bangunNavigasiBawah() {
    if (_keadaan != KeadaanMuat.berhasil || _produk == null) return null;

    final bool apakahHabis = _apakahHabisAktif;
    final int stokTersedia = _stokAktif;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ZWarna.permukaan,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!apakahHabis) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ZWarna.batas),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _kuantitas > 1
                          ? () => setState(() => _kuantitas--)
                          : null,
                    ),
                    Text(
                      '$_kuantitas',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _kuantitas < stokTersedia
                          ? () => setState(() => _kuantitas++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: apakahHabis || _sedangMenambahkan
                    ? null
                    : _tambahKeKeranjang,
                icon: _sedangMenambahkan
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: ZWarna.putih),
                      )
                    : const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  apakahHabis ? 'Stok Tidak Tersedia' : 'Tambah ke Keranjang',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZWarna.oranye,
                  foregroundColor: ZWarna.hitam,
                  disabledBackgroundColor: ZWarna.permukaanTinggi,
                  disabledForegroundColor: ZWarna.teksSamar,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ZRadius.sedang),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
