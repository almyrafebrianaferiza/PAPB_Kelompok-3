import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/keranjang.dart';
import '../models/kurir.dart';
import '../models/metode_pembayaran.dart';
import '../services/layanan_api.dart';
import '../widgets/tampilan_galat.dart';
import 'rincian_pesanan_page.dart';

class CheckoutPage extends StatefulWidget {
  final LayananApi layananApi;

  const CheckoutPage({super.key, required this.layananApi});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _kunciForm = GlobalKey<FormState>();

  KeadaanMuat _keadaan = KeadaanMuat.memuat;
  GalatApi? _galat;

  Keranjang? _keranjang;
  List<Kurir> _daftarKurir = [];
  List<MetodePembayaran> _daftarMetode = [];

  Kurir? _kurirTerpilih;
  MetodePembayaran? _metodeTerpilih;

  final TextEditingController _pengontrolNama =
      TextEditingController(text: 'Ahmad Fauzi');
  final TextEditingController _pengontrolAlamat =
      TextEditingController(text: 'Jl. Ijen No. 45, Klojen, Kota Malang');

  // Kunci idempoten: null di awal, dibuat sekali per percobaan checkout,
  // dipertahankan saat galat (Coba lagi memakai kunci sama),
  // direset saat pengguna mengubah isi form/kurir/metode atau setelah sukses (ars 5.5).
  String? _kunciIdempoten;
  bool _sedangCheckout = false;

  @override
  void initState() {
    super.initState();
    _muatDataPersiapan();
  }

  @override
  void dispose() {
    _pengontrolNama.dispose();
    _pengontrolAlamat.dispose();
    super.dispose();
  }

  String _hasilkanKunciIdempoten() {
    // 32 karakter heksadesimal dari Random.secure() tanpa pustaka tambahan (ars 5.5).
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  void _kunciDiubahIsi() {
    if (_kunciIdempoten != null) {
      setState(() => _kunciIdempoten = null);
    }
  }

  Future<void> _muatDataPersiapan() async {
    setState(() {
      _keadaan = KeadaanMuat.memuat;
      _galat = null;
    });

    try {
      final keranjang = await widget.layananApi.ambilKeranjang();
      final kurir = await widget.layananApi.ambilKurir();
      final metode = await widget.layananApi.ambilMetodePembayaran();

      if (mounted) {
        setState(() {
          _keranjang = keranjang;
          _daftarKurir = kurir;
          _daftarMetode = metode;
          if (kurir.isNotEmpty) _kurirTerpilih = kurir.first;
          if (metode.isNotEmpty) _metodeTerpilih = metode.first;
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

  // Angka checkout hanya menampilkan nilai yang dihitung server (H1):
  // GET /api/kurir sudah membawa ongkir dan total_estimasi per kurir.
  int get _ongkirEstimasi => _kurirTerpilih?.ongkir ?? 0;
  int get _totalEstimasi =>
      _kurirTerpilih?.totalEstimasi ?? (_keranjang?.subtotal ?? 0);

  Future<void> _lakukanCheckout() async {
    if (!_kunciForm.currentState!.validate()) return;
    if (_kurirTerpilih == null || _metodeTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kurir dan metode pembayaran terlebih dahulu.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _sedangCheckout = true;
      _kunciIdempoten ??= _hasilkanKunciIdempoten();
    });

    try {
      final respon = await widget.layananApi.checkout(
        kunciIdempoten: _kunciIdempoten!,
        kurirId: _kurirTerpilih!.id,
        metodePembayaranId: _metodeTerpilih!.id,
        namaPenerima: _pengontrolNama.text.trim(),
        alamatPenerima: _pengontrolAlamat.text.trim(),
      );

      if (mounted) {
        _kunciIdempoten = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan berhasil dibuat: ${respon.nomorPesanan}'),
            backgroundColor: const Color(0xFF059669),
          ),
        );

        // 201: pushReplacement agar tombol kembali tidak kembali ke form (ars 5.6).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => RincianPesananPage(
              idPesanan: respon.id,
              layananApi: widget.layananApi,
            ),
          ),
        );
      }
    } on GalatApi catch (e) {
      if (mounted) {
        if (e is BentrokException) {
          // 409: pesan dari server, pengguna tetap berada di halaman checkout (ars 5.6).
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Color(0xFFDC2626)),
                  SizedBox(width: 8),
                  Text('Stok Tidak Mencukupi'),
                ],
              ),
              content: Text(e.pesan),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.pesan), backgroundColor: const Color(0xFFDC2626)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _sedangCheckout = false;
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
        title: const Text('Pengiriman & Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunBarBawah(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
    }

    if (_keadaan == KeadaanMuat.galat) {
      return TampilanGalat(
        galat: _galat ?? ServerException('Gagal memuat opsi checkout'),
        saatCobaLagi: _muatDataPersiapan,
      );
    }

    return Form(
      key: _kunciForm,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian 1: Data Penerima (kolom sesuai kontrak 4.11)
            _kartuBagian(
              judul: '1. Informasi Penerima',
              anak: Column(
                children: [
                  TextFormField(
                    controller: _pengontrolNama,
                    onChanged: (_) => _kunciDiubahIsi(),
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Penerima *',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Nama wajib diisi';
                      if (val.trim().length < 3) return 'Nama minimal 3 karakter';
                      if (val.trim().length > 100) return 'Nama maksimal 100 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pengontrolAlamat,
                    onChanged: (_) => _kunciDiubahIsi(),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap Pengiriman *',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      hintText: 'Jalan, nomor rumah, RT/RW, kecamatan, kota',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Alamat wajib diisi';
                      if (val.trim().length < 10) return 'Alamat minimal 10 karakter';
                      if (val.trim().length > 500) return 'Alamat maksimal 500 karakter';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 2: Ekspedisi - ongkir tampil dari server, tanpa hitungan di Dart (H1)
            _kartuBagian(
              judul: '2. Ekspedisi & Jasa Kirim Elektronik',
              anak: RadioGroup<Kurir>(
                groupValue: _kurirTerpilih,
                onChanged: (val) {
                  _kunciDiubahIsi();
                  setState(() => _kurirTerpilih = val);
                },
                child: Column(
                  children: _daftarKurir.map((k) {
                    return RadioListTile<Kurir>(
                      value: k,
                      title: Text(k.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${k.wilayah} • ${_formatRupiah(k.tarifPerKg)}/kg (berat ${k.beratKgTertagih} kg)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      secondary: Text(
                        _formatRupiah(k.ongkir),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 3: Metode Pembayaran
            _kartuBagian(
              judul: '3. Metode Pembayaran',
              anak: RadioGroup<MetodePembayaran>(
                groupValue: _metodeTerpilih,
                onChanged: (val) {
                  _kunciDiubahIsi();
                  setState(() => _metodeTerpilih = val);
                },
                child: Column(
                  children: _daftarMetode.map((m) {
                    return RadioListTile<MetodePembayaran>(
                      value: m,
                      title: Text(m.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(m.kode, style: const TextStyle(fontSize: 12)),
                      secondary: Icon(
                        m.kode.toLowerCase().contains('qris')
                            ? Icons.qr_code_2
                            : Icons.account_balance,
                        color: const Color(0xFF0284C7),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 4: Ringkasan Biaya - seluruh angka dari respons server
            _kartuBagian(
              judul: '4. Ringkasan Transaksi',
              anak: Column(
                children: [
                  _barisRincian(
                    'Total Produk (${_keranjang?.totalJumlah ?? 0} item)',
                    _formatRupiah(_keranjang?.subtotal ?? 0),
                  ),
                  const SizedBox(height: 6),
                  _barisRincian(
                    'Ongkos Kirim (${_kurirTerpilih?.nama ?? "-"})',
                    _formatRupiah(_ongkirEstimasi),
                  ),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _barisRincian(
                    'Total Pembayaran',
                    _formatRupiah(_totalEstimasi),
                    tebal: true,
                    warna: const Color(0xFF0284C7),
                    ukuran: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _kartuBagian({required String judul, required Widget anak}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          anak,
        ],
      ),
    );
  }

  Widget _barisRincian(
    String label,
    String nilai, {
    bool tebal = false,
    Color? warna,
    double ukuran = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ukuran,
            color: const Color(0xFF64748B),
            fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          nilai,
          style: TextStyle(
            fontSize: ukuran,
            fontWeight: tebal ? FontWeight.w900 : FontWeight.w600,
            color: warna ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget? _bangunBarBawah() {
    if (_keadaan != KeadaanMuat.berhasil) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                const Text('Total Tagihan', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text(
                  _formatRupiah(_totalEstimasi),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _sedangCheckout ? null : _lakukanCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _sedangCheckout
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Bayar Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
