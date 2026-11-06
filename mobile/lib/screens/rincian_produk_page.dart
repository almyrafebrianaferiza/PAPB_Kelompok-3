import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../services/layanan_api.dart';
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
  int _kuantitas = 1;
  bool _sedangMenambahkan = false;

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
            backgroundColor: const Color(0xFF059669),
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
            backgroundColor: const Color(0xFFDC2626),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunNavigasiBawah(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
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
          // Area visual produk (kontrak tanpa field gambar)
          Container(
            height: 260,
            width: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.devices_other,
                    size: 80,
                    color: Color(0xFFCBD5E1),
                  ),
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

          // Kartu Informasi Utama
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p.kategori,
                        style: const TextStyle(
                          color: Color(0xFF0369A1),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      p.merek,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
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
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatRupiah(p.harga),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),

                // Grid Spesifikasi Teknis
                Row(
                  children: [
                    _itemSpesifikasi(
                      Icons.inventory_2_outlined,
                      'Sisa Stok',
                      apakahHabis ? 'HABIS' : '${p.stok} unit',
                      apakahHabis ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    ),
                    _itemSpesifikasi(
                      Icons.scale_outlined,
                      'Berat Fisik',
                      '${p.beratGram} gram',
                      const Color(0xFF0F172A),
                    ),
                    _itemSpesifikasi(
                      Icons.verified_user_outlined,
                      'Garansi Resmi',
                      '${p.garansiBulan} Bulan',
                      const Color(0xFF0284C7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kartu Deskripsi (Handling null aman)
          Container(
            color: Colors.white,
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
                    color: Color(0xFF0F172A),
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
                        ? const Color(0xFF334155)
                        : const Color(0xFF94A3B8),
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
              Icon(ikon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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

    final p = _produk!;
    final bool apakahHabis = p.isHabis;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Kontrol Kuantitas
            if (!apakahHabis) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1)),
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
                      onPressed: _kuantitas < p.stok
                          ? () => setState(() => _kuantitas++)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Tombol Tambah ke Keranjang
            Expanded(
              child: ElevatedButton.icon(
                onPressed: apakahHabis || _sedangMenambahkan
                    ? null
                    : _tambahKeKeranjang,
                icon: _sedangMenambahkan
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  apakahHabis ? 'Stok Tidak Tersedia' : 'Tambah ke Keranjang',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  disabledForegroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
