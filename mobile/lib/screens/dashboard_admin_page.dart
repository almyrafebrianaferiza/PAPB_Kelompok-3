import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../models/ringkasan_pesanan.dart';
import '../services/layanan_api.dart';
import '../theme/zenvora_warna.dart';
import '../widgets/tampilan_galat.dart';
import 'form_produk_page.dart';
import 'kelola_produk_page.dart';
import 'rincian_pesanan_page.dart';

class DashboardAdminPage extends StatefulWidget {
  final LayananApi layananApi;

  const DashboardAdminPage({super.key, required this.layananApi});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;

  List<Produk> _semuaProduk = [];
  List<RingkasanPesanan> _semuaPesanan = [];
  bool _sedangMemproses = false;

  @override
  void initState() {
    super.initState();
    _muatDataDashboard();
  }

  Future<void> _muatDataDashboard() async {
    setState(() {
      _keadaan = KeadaanMuat.memuat;
      _galat = null;
    });

    try {
      final produk = await widget.layananApi.daftarProduk(halaman: 1, perHalaman: 50);
      final pesanan = await widget.layananApi.riwayatPesanan();

      if (mounted) {
        setState(() {
          _semuaProduk = produk;
          _semuaPesanan = pesanan;
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

  Future<void> _ubahStatusPesanan(int pesananId, String statusBaru) async {
    setState(() => _sedangMemproses = true);
    try {
      await widget.layananApi.ubahStatusPesanan(pesananId, statusBaru);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan berhasil diperbarui: $statusBaru'),
            backgroundColor: ZWarna.sukses,
          ),
        );
      }
      await _muatDataDashboard();
    } on GalatApi catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.pesan), backgroundColor: ZWarna.galat),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sedangMemproses = false);
      }
    }
  }

  String _formatRupiah(num nominal) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(nominal);
  }

  int get _totalOmzet {
    return _semuaPesanan
        .where((p) => p.status != 'dibatalkan')
        .fold(0, (sum, item) => sum + item.total);
  }

  int get _pesananPerluProses {
    return _semuaPesanan
        .where((p) => p.status == 'menunggu_pembayaran' || p.status == 'menunggu_konfirmasi')
        .length;
  }

  List<Produk> get _stokKritis {
    return _semuaProduk.where((p) => p.stok < 3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZWarna.hitam,
      appBar: AppBar(
        title: const Text('Dashboard Pengelola Toko'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _muatDataDashboard,
          ),
        ],
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
        galat: _galat ?? ServerException('Gagal memuat data dashboard'),
        saatCobaLagi: _muatDataDashboard,
      );
    }

    return RefreshIndicator(
      onRefresh: _muatDataDashboard,
      color: ZWarna.oranye,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Grid Kartu KPI / Metrik Bisnis
            _bangunMetrikBisnis(),
            const SizedBox(height: 20),

            // 2. Bar Aksi Cepat
            _bangunAksiCepat(),
            const SizedBox(height: 24),

            // 3. Peringatan Stok Kritis
            _bangunPeringatanStok(),
            const SizedBox(height: 24),

            // 4. Antrean Pemrosesan Pesanan
            _bangunAntreanPesanan(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _bangunMetrikBisnis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Kinerja Toko',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ZWarna.putih),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _kartuKpi(
                judul: 'Total Omzet Masuk',
                nilai: _formatRupiah(_totalOmzet),
                ikon: Icons.payments_outlined,
                warnaAksen: ZWarna.sukses,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kartuKpi(
                judul: 'Pesanan Aktif',
                nilai: '$_pesananPerluProses pesanan',
                ikon: Icons.shopping_bag_outlined,
                warnaAksen: ZWarna.oranye,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _kartuKpi(
                judul: 'Katalog Produk',
                nilai: '${_semuaProduk.length} item',
                ikon: Icons.inventory_2_outlined,
                warnaAksen: ZWarna.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _kartuKpi(
                judul: 'Perlu Re-stock',
                nilai: '${_stokKritis.length} produk',
                ikon: Icons.warning_amber_rounded,
                warnaAksen: ZWarna.galat,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kartuKpi({
    required String judul,
    required String nilai,
    required IconData ikon,
    required Color warnaAksen,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZWarna.permukaan,
        borderRadius: BorderRadius.circular(ZRadius.sedang),
        border: Border.all(color: ZWarna.batas),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                judul,
                style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
              ),
              Icon(ikon, size: 18, color: warnaAksen),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: warnaAksen,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _bangunAksiCepat() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => KelolaProdukPage(layananApi: widget.layananApi),
                ),
              );
              _muatDataDashboard();
            },
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Kelola Produk (CRUD)', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZWarna.oranye,
              foregroundColor: ZWarna.hitam,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final hasil = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => FormProdukPage(layananApi: widget.layananApi),
                ),
              );
              if (hasil == true) _muatDataDashboard();
            },
            icon: const Icon(Icons.add_box_outlined, size: 18, color: ZWarna.oranye),
            label: const Text('+ Tambah Baru', style: TextStyle(fontSize: 12, color: ZWarna.putih)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ZWarna.batas),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bangunPeringatanStok() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Peringatan Stok Menipis (< 3 unit)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ZWarna.putih),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ZWarna.galat.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_stokKritis.length} item',
                style: const TextStyle(fontSize: 11, color: ZWarna.galat, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_stokKritis.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ZWarna.permukaan,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ZWarna.batas),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: ZWarna.sukses, size: 18),
                SizedBox(width: 8),
                Text('Semua stok produk dalam batas aman.', style: TextStyle(color: ZWarna.teksSekunder, fontSize: 13)),
              ],
            ),
          )
        else
          ..._stokKritis.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ZWarna.permukaan,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ZWarna.batas),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nama,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ZWarna.putih),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${p.merek} • ${p.kategori}',
                          style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.stok == 0
                          ? ZWarna.galat.withValues(alpha: 0.2)
                          : ZWarna.peringatan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      p.stok == 0 ? 'HABIS' : 'Sisa ${p.stok}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: p.stok == 0 ? ZWarna.galat : ZWarna.peringatan,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _bangunAntreanPesanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Antrean Pemrosesan Pesanan Toko',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ZWarna.putih),
        ),
        const SizedBox(height: 10),
        if (_semuaPesanan.isEmpty)
          const Text('Belum ada pesanan masuk.', style: TextStyle(color: ZWarna.teksSekunder, fontSize: 13))
        else
          ..._semuaPesanan.take(5).map((p) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
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
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ZWarna.putih),
                        ),
                        Text(
                          _formatRupiah(p.total),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ZWarna.oranye),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Status saat ini: ${p.status}',
                      style: const TextStyle(fontSize: 11, color: ZWarna.teksSekunder),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (p.status == 'menunggu_pembayaran')
                          ElevatedButton(
                            onPressed: _sedangMemproses ? null : () => _ubahStatusPesanan(p.id, 'menunggu_konfirmasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ZWarna.info,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            child: const Text('Simulasi Bayar', style: TextStyle(fontSize: 11, color: ZWarna.putih)),
                          ),
                        if (p.status == 'menunggu_konfirmasi')
                          ElevatedButton(
                            onPressed: _sedangMemproses ? null : () => _ubahStatusPesanan(p.id, 'dibayar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ZWarna.sukses,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            child: const Text('Konfirmasi Pembayaran', style: TextStyle(fontSize: 11, color: ZWarna.putih)),
                          ),
                        if (p.status == 'dibayar')
                          ElevatedButton(
                            onPressed: _sedangMemproses ? null : () => _ubahStatusPesanan(p.id, 'diproses'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ZWarna.oranye,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            child: const Text('Proses Barang', style: TextStyle(fontSize: 11, color: ZWarna.hitam)),
                          ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => RincianPesananPage(
                                  idPesanan: p.id,
                                  layananApi: widget.layananApi,
                                ),
                              ),
                            );
                            _muatDataDashboard();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: ZWarna.batas),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: const Text('Rincian Serial', style: TextStyle(fontSize: 11, color: ZWarna.putih)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
