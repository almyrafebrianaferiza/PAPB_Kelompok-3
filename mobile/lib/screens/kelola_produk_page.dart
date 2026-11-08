import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../services/layanan_api.dart';
import '../widgets/tampilan_galat.dart';
import '../widgets/tampilan_kosong.dart';
import '../theme/zenvora_warna.dart';
import 'form_produk_page.dart';

class KelolaProdukPage extends StatefulWidget {
  final LayananApi layananApi;

  const KelolaProdukPage({super.key, required this.layananApi});

  @override
  State<KelolaProdukPage> createState() => _KelolaProdukPageState();
}

class _KelolaProdukPageState extends State<KelolaProdukPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;
  List<Produk> _daftar = [];

  @override
  void initState() {
    super.initState();
    _muatDaftar();
  }

  Future<void> _muatDaftar() async {
    setState(() {
      _keadaan = KeadaanMuat.memuat;
      _galat = null;
    });

    try {
      final respon = await widget.layananApi.daftarProduk(halaman: 1, perHalaman: 50);
      if (mounted) {
        setState(() {
          _daftar = respon;
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

  Future<void> _konfirmasiHapus(Produk p) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Apakah Anda yakin ingin menghapus produk "${p.nama}" (Merek: ${p.merek})? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: ZWarna.galat),
            child: const Text('Ya, Hapus', style: TextStyle(color: ZWarna.putih)),
          ),
        ],
      ),
    );

    if (setuju == true) {
      try {
        await widget.layananApi.hapusProduk(p.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produk "${p.nama}" berhasil dihapus.'),
              backgroundColor: ZWarna.sukses,
            ),
          );
          _muatDaftar();
        }
      } on GalatApi catch (e) {
        if (mounted) {
          if (e is BentrokException) {
            showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Gagal Menghapus (409)'),
                content: Text(e.pesan),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.pesan), backgroundColor: ZWarna.galat),
            );
          }
        }
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
      backgroundColor: ZWarna.hitam,
      appBar: AppBar(
        title: const Text('Kelola Produk (CRUD)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final berhasil = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => FormProdukPage(layananApi: widget.layananApi),
            ),
          );
          if (berhasil == true) _muatDaftar();
        },
        backgroundColor: ZWarna.oranye,
        icon: const Icon(Icons.add, color: ZWarna.putih),
        label: const Text('Tambah Produk', style: TextStyle(color: ZWarna.putih, fontWeight: FontWeight.bold)),
      ),
      body: _bangunBadan(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator(color: ZWarna.oranye));
    }

    if (_keadaan == KeadaanMuat.galat) {
      return TampilanGalat(
        galat: _galat ?? ServerException('Gagal memuat katalog produk'),
        saatCobaLagi: _muatDaftar,
      );
    }

    if (_daftar.isEmpty) {
      return TampilanKosong(
        ikon: Icons.inventory_2_outlined,
        judul: 'Katalog Kosong',
        pesan: 'Belum ada produk dalam basis data Zenvorā.',
        teksTombolAksi: 'Tambah Produk Sekarang',
        saatTombolDitekan: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => FormProdukPage(layananApi: widget.layananApi)),
          );
          if (res == true) _muatDaftar();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _muatDaftar,
      color: ZWarna.oranye,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        itemCount: _daftar.length,
        separatorBuilder: (c, i) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final p = _daftar[i];
          final bool habis = p.isHabis;

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ZWarna.permukaanTinggi,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.devices_other, color: ZWarna.teksSamar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${p.merek} • ${p.kategori}',
                          style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatRupiah(p.harga),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ZWarna.oranye,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: habis ? ZWarna.galat.withValues(alpha: 0.12) : ZWarna.sukses.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                habis ? 'Habis' : 'Stok: ${p.stok}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: habis ? ZWarna.galat : ZWarna.sukses,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: ZWarna.oranye),
                    onPressed: () async {
                      final berhasil = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => FormProdukPage(
                            produk: p,
                            layananApi: widget.layananApi,
                          ),
                        ),
                      );
                      if (berhasil == true) _muatDaftar();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: ZWarna.galat),
                    onPressed: () => _konfirmasiHapus(p),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
