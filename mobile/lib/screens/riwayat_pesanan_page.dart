import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/ringkasan_pesanan.dart';
import '../services/layanan_api.dart';
import '../widgets/tampilan_galat.dart';
import '../widgets/tampilan_kosong.dart';
import '../theme/zenvora_warna.dart';
import 'rincian_pesanan_page.dart';

class RiwayatPesananPage extends StatefulWidget {
  final LayananApi layananApi;

  const RiwayatPesananPage({super.key, required this.layananApi});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;
  List<RingkasanPesanan> _daftarPesanan = [];

  @override
  void initState() {
    super.initState();
    _muatRiwayat();
  }

  Future<void> _muatRiwayat() async {
    setState(() {
      _keadaan = KeadaanMuat.memuat;
      _galat = null;
    });

    try {
      final daftar = await widget.layananApi.riwayatPesanan();
      if (mounted) {
        setState(() {
          _daftarPesanan = daftar;
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
        title: const Text('Riwayat Pesanan'),
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
        galat: _galat ?? ServerException('Gagal memuat riwayat pesanan'),
        saatCobaLagi: _muatRiwayat,
      );
    }

    if (_daftarPesanan.isEmpty) {
      return TampilanKosong(
        ikon: Icons.receipt_long_outlined,
        judul: 'Belum Ada Pesanan',
        pesan: 'Anda belum pernah melakukan pemesanan perangkat elektronik di Zenvorā.',
        teksTombolAksi: 'Jelajahi Produk',
        saatTombolDitekan: () => Navigator.pop(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _muatRiwayat,
      color: ZWarna.oranye,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _daftarPesanan.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final p = _daftarPesanan[i];
          final warna = _warnaStatus(p.status);

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => RincianPesananPage(
                      idPesanan: p.id,
                      layananApi: widget.layananApi,
                    ),
                  ),
                );
                _muatRiwayat();
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.nomorPesanan,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: warna.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _labelStatus(p.status),
                            style: TextStyle(
                              color: warna,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.dibuatPada,
                      style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
                    ),
                    const Divider(height: 16, color: ZWarna.batas),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${p.jumlahBarang} item',
                          style: const TextStyle(fontSize: 12, color: ZWarna.teksSamar),
                        ),
                        Text(
                          _formatRupiah(p.total),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ZWarna.putih,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
