import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/rincian_pesanan.dart';
import '../services/layanan_api.dart';
import '../widgets/tampilan_galat.dart';
import '../theme/zenvora_warna.dart';

class RincianPesananPage extends StatefulWidget {
  final int idPesanan;
  final LayananApi layananApi;

  const RincianPesananPage({
    super.key,
    required this.idPesanan,
    required this.layananApi,
  });

  @override
  State<RincianPesananPage> createState() => _RincianPesananPageState();
}

class _RincianPesananPageState extends State<RincianPesananPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;
  RincianPesanan? _pesanan;
  bool _sedangUbahStatus = false;

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
      final p = await widget.layananApi.rincianPesanan(widget.idPesanan);
      if (mounted) {
        setState(() {
          _pesanan = p;
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

  Future<void> _ubahStatus(String statusBaru) async {
    setState(() {
      _sedangUbahStatus = true;
    });

    try {
      final p = await widget.layananApi.ubahStatusPesanan(
        widget.idPesanan,
        statusBaru,
      );
      if (mounted) {
        setState(() {
          _pesanan = p;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan berhasil diubah menjadi: $statusBaru'),
            backgroundColor: ZWarna.sukses,
          ),
        );
      }
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.pesan),
            backgroundColor: ZWarna.galat,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangUbahStatus = false;
        });
      }
    }
  }

  String _formatRupiah(num nominal) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(nominal);
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'dibayar':
        return 'Dibayar';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'menunggu_pembayaran':
        return ZWarna.peringatan;
      case 'menunggu_konfirmasi':
        return ZWarna.peringatan;
      case 'dibayar':
        return ZWarna.info;
      case 'diproses':
        return ZWarna.info;
      case 'dikirim':
        return ZWarna.info;
      case 'selesai':
        return ZWarna.sukses;
      case 'dibatalkan':
        return ZWarna.galat;
      default:
        return ZWarna.teksSekunder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZWarna.hitam,
      appBar: AppBar(
        title: const Text('Rincian Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Kembali ke Katalog',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunAksiStatus(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator(color: ZWarna.oranye));
    }

    if (_keadaan == KeadaanMuat.galat) {
      return TampilanGalat(
        galat: _galat ?? ServerException('Gagal memuat rincian pesanan'),
        saatCobaLagi: _muatRincian,
      );
    }

    final p = _pesanan!;

    return RefreshIndicator(
      onRefresh: _muatRincian,
      color: ZWarna.oranye,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZWarna.permukaan,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ZWarna.batas),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nomorPesanan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ZWarna.putih,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.dibuatPada,
                        style: const TextStyle(fontSize: 12, color: ZWarna.teksSekunder),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _warnaStatus(p.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _labelStatus(p.status),
                      style: TextStyle(
                        color: _warnaStatus(p.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZWarna.permukaan,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ZWarna.batas),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pengiriman',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(p.namaPenerima,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(p.alamatPenerima,
                      style: const TextStyle(fontSize: 13, color: ZWarna.teksSamar)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 16, color: ZWarna.oranye),
                      const SizedBox(width: 6),
                      Text(
                        'Kurir: ${p.kurir?['nama'] ?? '-'} (${p.totalBeratGram} gram)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZWarna.permukaan,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ZWarna.batas),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produk Dipesan & Nomor Seri Unit',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...p.item.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ZWarna.permukaanTinggi,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ZWarna.batas),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.namaProduk,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              Text(
                                _formatRupiah(item.subtotalItem),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ZWarna.oranye,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.jumlah}x @ ${_formatRupiah(item.hargaSatuan)} • Garansi ${item.garansiBulan} bln • ${item.beratGramSatuan}g',
                            style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'Nomor Seri Fisik (IMEI / S/N Unit):',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ZWarna.info,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: item.nomorSeri.isNotEmpty
                                ? item.nomorSeri.map((seri) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ZWarna.permukaan,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: ZWarna.batas),
                                      ),
                                      child: Text(
                                        seri,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: ZWarna.oranye,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Text(
                                      'Unit dialokasikan otomatis saat pesanan dibuat.',
                                      style: TextStyle(fontSize: 11, color: ZWarna.teksSamar),
                                    ),
                                  ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZWarna.permukaan,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ZWarna.batas),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rincian Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _baris('Subtotal Produk', _formatRupiah(p.subtotal)),
                  const SizedBox(height: 4),
                  _baris('Ongkos Kirim', _formatRupiah(p.ongkir)),
                  const Divider(height: 16, color: ZWarna.batas),
                  _baris('Total Akhir', _formatRupiah(p.total), tebal: true, warna: ZWarna.oranye),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _baris(String label, String nilai, {bool tebal = false, Color? warna}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: ZWarna.teksSekunder, fontWeight: tebal ? FontWeight.bold : FontWeight.normal)),
        Text(nilai, style: TextStyle(fontSize: 13, fontWeight: tebal ? FontWeight.bold : FontWeight.w600, color: warna ?? ZWarna.putih)),
      ],
    );
  }

  Widget? _bangunAksiStatus() {
    if (_keadaan != KeadaanMuat.berhasil || _pesanan == null) return null;

    final p = _pesanan!;
    final transisiTersedia = p.statusBerikutnya;

    if (transisiTersedia.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ZWarna.permukaan,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: transisiTersedia.map((target) {
            final bool isBatal = target == 'dibatalkan';
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: _sedangUbahStatus ? null : () => _ubahStatus(target),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBatal ? ZWarna.galat : ZWarna.oranye,
                    foregroundColor: ZWarna.putih,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isBatal ? 'Batalkan Pesanan' : 'Ubah: $target',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
