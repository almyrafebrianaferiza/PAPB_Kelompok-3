import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/rincian_pesanan.dart';
import '../services/layanan_api.dart';
import '../widgets/tampilan_galat.dart';

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
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.pesan),
            backgroundColor: const Color(0xFFDC2626),
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
        return Colors.amber.shade800;
      case 'menunggu_konfirmasi':
        return Colors.amber.shade700;
      case 'dibayar':
        return Colors.blue.shade700;
      case 'diproses':
        return Colors.indigo.shade700;
      case 'dikirim':
        return Colors.cyan.shade800;
      case 'selesai':
        return Colors.green.shade700;
      case 'dibatalkan':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Rincian Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
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
      color: const Color(0xFF0284C7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Status Pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.dibuatPada,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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

            // Informasi Penerima & Pengiriman
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF0284C7)),
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

            // Daftar Item Produk & Nomor Seri Fisik
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.jumlah}x @ ${_formatRupiah(item.hargaSatuan)} • Garansi ${item.garansiBulan} bln • ${item.beratGramSatuan}g',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),

                          // Fitur Unggulan Elektronik: Serial Numbers Per Unit
                          const Text(
                            'Nomor Seri Fisik (IMEI / S/N Unit):',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0369A1),
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFBAE6FD)),
                                      ),
                                      child: Text(
                                        seri,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Text(
                                      'Unit dialokasikan otomatis saat pesanan dibuat.',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
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

            // Rincian Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rincian Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _baris('Subtotal Produk', _formatRupiah(p.subtotal)),
                  const SizedBox(height: 4),
                  _baris('Ongkos Kirim', _formatRupiah(p.ongkir)),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _baris('Total Akhir', _formatRupiah(p.total), tebal: true, warna: const Color(0xFF0284C7)),
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
        Text(label, style: TextStyle(fontSize: 13, color: const Color(0xFF64748B), fontWeight: tebal ? FontWeight.bold : FontWeight.normal)),
        Text(nilai, style: TextStyle(fontSize: 13, fontWeight: tebal ? FontWeight.bold : FontWeight.w600, color: warna ?? const Color(0xFF0F172A))),
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
        color: Colors.white,
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
                    backgroundColor: isBatal ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
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
