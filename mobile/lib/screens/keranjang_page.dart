import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/keranjang.dart';
import '../services/layanan_api.dart';
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
      // Respons PUT adalah item yang diubah; isi keranjang dimuat ulang agar subtotal ikut segar.
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
          SnackBar(content: Text(e.pesan), backgroundColor: const Color(0xFFDC2626)),
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
      // DELETE mengembalikan data: null, jadi isi keranjang dimuat ulang setelah hapus.
      await widget.layananApi.hapusItemKeranjang(idItem);
      final k = await widget.layananApi.ambilKeranjang();
      if (mounted) {
        setState(() {
          _keranjang = k;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil dihapus dari keranjang.'),
            backgroundColor: Color(0xFF475569),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.pesan), backgroundColor: const Color(0xFFDC2626)),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunBarCheckout(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
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
      color: const Color(0xFF0284C7),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _keranjang!.item.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final item = _keranjang!.item[i];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon Produk (kontrak tanpa field gambar)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.devices_other, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(width: 12),

                  // Info Produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(item.hargaSatuan),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Subtotal: ${_formatRupiah(item.subtotalItem)} (${item.beratGramSatuan}g)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Stepper Kuantitas & Tombol Hapus
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  _formatRupiah(_keranjang!.subtotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${_keranjang!.totalJumlah} item',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
