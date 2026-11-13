import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../enums/keadaan_muat.dart';
import '../exceptions/galat_api.dart';
import '../models/keranjang.dart';
import '../models/kurir.dart';
import '../models/metode_pembayaran.dart';
import '../services/layanan_api.dart';
import '../theme/zenvora_warna.dart';
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
  List<Map<String, dynamic>> _daftarKota = [];
  int? _idKotaTerpilih;

  Kurir? _kurirTerpilih;
  MetodePembayaran? _metodeTerpilih;

  final TextEditingController _pengontrolNama =
      TextEditingController(text: 'Ahmad Fauzi');
  final TextEditingController _pengontrolAlamat =
      TextEditingController(text: 'Jl. Ijen No. 45, Klojen, Kota Malang');

  String? _kunciIdempoten;
  bool _sedangCheckout = false;
  bool _sedangDeteksiLokasi = false;
  Map<String, String> _galatServer = {};

  Future<void> _deteksiLokasiOtomatis() async {
    setState(() => _sedangDeteksiLokasi = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan lokasi (GPS) tidak aktif. Silakan aktifkan GPS perangkat.'),
              backgroundColor: ZWarna.peringatan,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin akses lokasi ditolak.'),
                backgroundColor: ZWarna.galat,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.'),
              backgroundColor: ZWarna.galat,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final alamatDitemukan = await widget.layananApi.geocodingBalik(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        int? kotaCocok;
        final alamatKecil = alamatDitemukan.toLowerCase();
        for (final k in _daftarKota) {
          final namaKota = (k['city_name'] ?? '').toString().toLowerCase();
          if (namaKota.isNotEmpty && alamatKecil.contains(namaKota)) {
            kotaCocok = (k['city_id'] as num?)?.toInt();
            break;
          }
        }

        setState(() {
          _pengontrolAlamat.text = alamatDitemukan;
          if (kotaCocok != null) _idKotaTerpilih = kotaCocok;
          _kunciDiubahIsi();
        });

        if (kotaCocok != null) {
          _pilihKota(kotaCocok);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil dideteksi otomatis.'),
            backgroundColor: ZWarna.sukses,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendeteksi lokasi otomatis. Silakan masukkan alamat manual.'),
            backgroundColor: ZWarna.galat,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sedangDeteksiLokasi = false);
      }
    }
  }

  Future<void> _pilihKota(int kotaId) async {
    setState(() {
      _idKotaTerpilih = kotaId;
      _kunciDiubahIsi();
    });
    try {
      final kurir = await widget.layananApi.ambilKurir(kotaId: kotaId);
      if (mounted) {
        setState(() {
          _daftarKurir = kurir;
          if (kurir.isNotEmpty) _kurirTerpilih = kurir.first;
        });
      }
    } catch (_) {}
  }

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
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  void _kunciDiubahIsi() {
    if (_kunciIdempoten != null || _galatServer.isNotEmpty) {
      setState(() {
        _kunciIdempoten = null;
        _galatServer = {};
      });
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
      List<Map<String, dynamic>> kota = [];
      try {
        kota = await widget.layananApi.ambilDaftarKota();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _keranjang = keranjang;
          _daftarKurir = kurir;
          _daftarMetode = metode;
          _daftarKota = kota;
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

  int get _ongkirEstimasi => _kurirTerpilih?.ongkir ?? 0;
  int get _totalEstimasi =>
      _kurirTerpilih?.totalEstimasi ?? (_keranjang?.subtotal ?? 0);

  Future<void> _lakukanCheckout() async {
    if (_galatServer.isNotEmpty) {
      setState(() => _galatServer = {});
    }
    if (!_kunciForm.currentState!.validate()) return;
    if (_kurirTerpilih == null || _metodeTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kurir dan metode pembayaran terlebih dahulu.'),
          backgroundColor: ZWarna.galat,
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
            backgroundColor: ZWarna.sukses,
          ),
        );

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
    } on ValidasiException catch (e) {
      if (mounted) {
        setState(() {
          _galatServer = e.errors.map((k, v) => MapEntry(k, v.join(', ')));
        });
        final kolomLain = e.errors.keys
            .where((k) => k != 'nama_penerima' && k != 'alamat_penerima');
        if (kolomLain.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.pesan),
              backgroundColor: ZWarna.galat,
            ),
          );
        }
      }
    } on GalatApi catch (e) {
      if (mounted) {
        if (e is BentrokException) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: ZWarna.galat),
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
            SnackBar(content: Text(e.pesan), backgroundColor: ZWarna.galat),
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
      appBar: AppBar(title: const Text('Pengiriman & Checkout')),
      body: _bangunBadan(),
      bottomNavigationBar: _bangunBarBawah(),
    );
  }

  Widget _bangunBadan() {
    if (_keadaan == KeadaanMuat.memuat) {
      return const Center(child: CircularProgressIndicator());
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
            _kartuBagian(
              judul: '1. Informasi Penerima',
              anak: Column(
                children: [
                  TextFormField(
                    controller: _pengontrolNama,
                    onChanged: (_) => _kunciDiubahIsi(),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap Penerima *',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      errorText: _galatServer['nama_penerima'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pengontrolAlamat,
                    onChanged: (_) => _kunciDiubahIsi(),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat Lengkap Pengiriman *',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                      suffixIcon: _sedangDeteksiLokasi
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location, color: ZWarna.oranye, size: 20),
                              tooltip: 'Gunakan Lokasi Saat Ini (GPS)',
                              onPressed: _deteksiLokasiOtomatis,
                            ),
                      hintText: 'Jalan, nomor rumah, RT/RW, kecamatan, kota',
                      errorText: _galatServer['alamat_penerima'],
                    ),
                  ),
                  if (_daftarKota.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _idKotaTerpilih,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kota / Kabupaten Tujuan (RajaOngkir)',
                        prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                      ),
                      hint: const Text(
                        'Pilih kota tujuan untuk hitung tarif RajaOngkir',
                        style: TextStyle(color: ZWarna.teksSamar, fontSize: 13),
                      ),
                      dropdownColor: ZWarna.permukaanTinggi,
                      items: _daftarKota.map((k) {
                        return DropdownMenuItem<int>(
                          value: (k['city_id'] as num).toInt(),
                          child: Text(
                            k['label'] ?? '${k['city_name']}',
                            style: const TextStyle(fontSize: 13, color: ZWarna.putih),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) _pilihKota(val);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                        style: const TextStyle(fontSize: 12, color: ZWarna.teksSekunder),
                      ),
                      secondary: Text(
                        _formatRupiah(k.ongkir),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ZWarna.oranye,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      subtitle: Text(m.kode, style: const TextStyle(fontSize: 12, color: ZWarna.teksSekunder)),
                      secondary: Icon(
                        m.kode.toLowerCase().contains('qris')
                            ? Icons.qr_code_2
                            : Icons.account_balance,
                        color: ZWarna.oranye,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  const Divider(height: 16, color: ZWarna.batas),
                  _barisRincian(
                    'Total Pembayaran',
                    _formatRupiah(_totalEstimasi),
                    tebal: true,
                    warna: ZWarna.oranye,
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
    return Material(
      color: ZWarna.permukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZRadius.sedang),
        side: const BorderSide(color: ZWarna.batas),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ZWarna.putih,
              ),
            ),
            const SizedBox(height: 12),
            anak,
          ],
        ),
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
            color: ZWarna.teksSekunder,
            fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          nilai,
          style: TextStyle(
            fontSize: ukuran,
            fontWeight: tebal ? FontWeight.w900 : FontWeight.w600,
            color: warna ?? ZWarna.putih,
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
                const Text('Total Tagihan', style: TextStyle(fontSize: 11, color: ZWarna.teksSekunder)),
                Text(
                  _formatRupiah(_totalEstimasi),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ZWarna.putih,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _sedangCheckout ? null : _lakukanCheckout,
              child: _sedangCheckout
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: ZWarna.putih, strokeWidth: 2),
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
