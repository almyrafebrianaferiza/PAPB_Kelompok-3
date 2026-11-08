import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/keranjang.dart';
import '../services/layanan_api.dart';
import '../theme/zenvora_warna.dart';
import '../widgets/tampilan_galat.dart';
import '../widgets/tampilan_kosong.dart';
import 'checkout_page.dart';

class KeranjangPage extends StatefulWidget {
  final LayananApi layananApi;

  const KeranjangPage({super.key, required this.layananApi});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;
  Keranjang? _keranjang;
  bool _sedangMengubah = false;

  @override
  void initState() {
    super.initState();
    _muatKeranjang();
  }

  Future<void> _muatKeranjang() async {
    setState(() {
      _keadaan = KeadaanMuat.memuat;
      _galat = null;
    });

    try {
      final k = await widget.layananApi.ambilKeranjang();
      if (mounted) {
        setState(() {
          _keranjang = k;
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

  Future<void> _ubahKuantitas(int idItem, int kuantitasBaru) async {
    if (kuantitasBaru <= 0) {
      _hapusItem(idItem);
      return;
    }

    setState(() {
      _sedangMengubah = true;
    });

    try {
      await widget.layananApi.ubahJumlahKeranjang(idItem, kuantitasBaru);
      final k = await widget.layananApi.ambilKeranjang();
      if (mounted) {
        setState(() {
          _keranjang = k;
        });
      }
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.pesan), backgroundColor: ZWarna.galat),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangMengubah = false;
        });
      }
    }
  }

  Future<void> _hapusItem(int idItem) async {
    setState(() {
      _sedangMengubah = true;
    });

    try {
      await widget.layananApi.hapusItemKeranjang(idItem);
      final k = await widget.layananApi.ambilKeranjang();
      if (mounted) {
        setState(() {
          _keranjang = k;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil dihapus dari keranjang.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.pesan), backgroundColor: ZWarna.galat),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangMengubah = false;
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
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunBarCheckout(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_keadaan == KeadaanMuat.galat) {
      return TampilanGalat(
        galat: _galat ?? ServerException('Gagal memuat keranjang belanja'),
        saatCobaLagi: _muatKeranjang,
      );
    }

    if (_keranjang == null || _keranjang!.item.isEmpty) {
      return TampilanKosong(
        ikon: Icons.remove_shopping_cart_outlined,
        judul: 'Keranjang Masih Kosong',
        pesan: 'Belum ada produk gadget atau aksesori dalam keranjang belanja Anda.',
        teksTombolAksi: 'Mulai Belanja',
        saatTombolDitekan: () => Navigator.pop(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _muatKeranjang,
      color: ZWarna.oranye,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _keranjang!.item.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final item = _keranjang!.item[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
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
                          item.nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ZWarna.putih,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(item.hargaSatuan),
                          style: const TextStyle(
                            fontSize: 13,
                            color: ZWarna.oranye,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Subtotal: ${_formatRupiah(item.subtotalItem)} (${item.beratGramSatuan}g)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: ZWarna.teksSekunder,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: ZWarna.batas),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: _sedangMengubah
                                        ? null
                                        : () => _ubahKuantitas(item.id, item.jumlah - 1),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '${item.jumlah}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _sedangMengubah
                                        ? null
                                        : () => _ubahKuantitas(item.id, item.jumlah + 1),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.add, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: ZWarna.galat),
                              onPressed: _sedangMengubah ? null : () => _hapusItem(item.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget? _bangunBarCheckout() {
    if (_keadaan != KeadaanMuat.berhasil || _keranjang == null || _keranjang!.item.isEmpty) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: ZWarna.permukaan,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
                ),
                Text(
                  _formatRupiah(_keranjang!.subtotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ZWarna.putih,
                  ),
                ),
                Text(
                  '${_keranjang!.totalJumlah} item',
                  style: const TextStyle(fontSize: 11, color: ZWarna.teksSamar),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final hasil = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => CheckoutPage(layananApi: widget.layananApi),
                  ),
                );
                if (hasil == true) {
                  _muatKeranjang();
                }
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
