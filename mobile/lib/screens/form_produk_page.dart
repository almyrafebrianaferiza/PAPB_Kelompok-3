import 'package:flutter/material.dart';
import '../exceptions/galat_api.dart';
import '../models/produk.dart';
import '../services/layanan_api.dart';
import '../theme/zenvora_warna.dart';

class FormProdukPage extends StatefulWidget {
  final Produk? produk;
  final LayananApi layananApi;

  const FormProdukPage({super.key,
    this.produk,
    required this.layananApi,
  });

  @override
  State<FormProdukPage> createState() => _FormProdukPageState();
}

class _FormProdukPageState extends State<FormProdukPage> {
  final _kunciForm = GlobalKey<FormState>();

  late TextEditingController _namaCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _stokCtrl;
  late TextEditingController _beratCtrl;
  late TextEditingController _garansiCtrl;
  late TextEditingController _merkCtrl;
  late TextEditingController _deskripsiCtrl;

  String _kategori = 'gadget';
  bool _sedangMenyimpan = false;

  final List<String> _kategoriOpsi = [
    'gadget',
    'laptop',
    'tv',
    'monitor',
    'tablet',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.produk;
    _namaCtrl = TextEditingController(text: p?.nama ?? '');
    _hargaCtrl = TextEditingController(text: p != null ? '${p.harga}' : '');
    _stokCtrl = TextEditingController(text: p != null ? '${p.stok}' : '10');
    _beratCtrl = TextEditingController(text: p != null ? '${p.beratGram}' : '250');
    _garansiCtrl = TextEditingController(text: p != null ? '${p.garansiBulan}' : '12');
    _merkCtrl = TextEditingController(text: p?.merek ?? 'Zenvora');
    _deskripsiCtrl = TextEditingController(text: p?.deskripsi ?? '');

    if (p != null && _kategoriOpsi.contains(p.kategori)) {
      _kategori = p.kategori;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    _beratCtrl.dispose();
    _garansiCtrl.dispose();
    _merkCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() {
      _sedangMenyimpan = true;
    });

    final data = {
      'nama': _namaCtrl.text.trim(),
      'merek': _merkCtrl.text.trim(),
      'harga': int.parse(_hargaCtrl.text.trim()),
      'stok': int.parse(_stokCtrl.text.trim()),
      'berat_gram': int.parse(_beratCtrl.text.trim()),
      'garansi_bulan': int.parse(_garansiCtrl.text.trim()),
      'kategori': _kategori,
      'deskripsi': _deskripsiCtrl.text.trim().isNotEmpty ? _deskripsiCtrl.text.trim() : null,
    };

    try {
      if (widget.produk == null) {
        await widget.layananApi.tambahProduk(data);
      } else {
        await widget.layananApi.ubahProduk(widget.produk!.id, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.produk == null
                ? 'Produk berhasil ditambahkan.'
                : 'Produk berhasil diperbarui.'),
            backgroundColor: ZWarna.sukses,
          ),
        );
        Navigator.pop(context, true);
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
          _sedangMenyimpan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool apakahUbah = widget.produk != null;

    return Scaffold(
      backgroundColor: ZWarna.hitam,
      appBar: AppBar(
        title: Text(apakahUbah ? 'Ubah Produk' : 'Tambah Produk Baru'),
      ),
      body: Form(
        key: _kunciForm,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _kolomTeks(_namaCtrl, 'Nama Produk *', 'Contoh: Zenvora Nova Pro 5G'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _kolomTeks(_hargaCtrl, 'Harga (Rp) *', '1000000', angka: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kolomTeks(_stokCtrl, 'Stok *', '10', angka: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _kolomTeks(_beratCtrl, 'Berat (Gram) *', '250', angka: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kolomTeks(_garansiCtrl, 'Garansi (Bulan) *', '12', angka: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _kategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori *',
                        filled: true,
                        fillColor: ZWarna.permukaanTinggi,
                        border: OutlineInputBorder(),
                      ),
                      items: _kategoriOpsi.map((k) {
                        return DropdownMenuItem(
                          value: k,
                          child: Text('${k[0].toUpperCase()}${k.substring(1)}'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _kategori = v ?? _kategori),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _kolomTeks(_merkCtrl, 'Merk / Brand', 'Zenvora'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Produk (Opsional)',
                  filled: true,
                  fillColor: ZWarna.permukaanTinggi,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sedangMenyimpan ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZWarna.oranye,
                    foregroundColor: ZWarna.putih,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _sedangMenyimpan
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          apakahUbah ? 'Simpan Perubahan' : 'Tambah Produk',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kolomTeks(
    TextEditingController ctrl,
    String label,
    String hint, {
    bool angka = false,
    bool wajib = true,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: angka ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: ZWarna.permukaanTinggi,
        border: const OutlineInputBorder(),
      ),
      validator: wajib
          ? (v) {
              if (v == null || v.trim().isEmpty) return '$label wajib diisi';
              if (angka && int.tryParse(v.trim()) == null) return 'Harus angka bilangan bulat';
              return null;
            }
          : null,
    );
  }
}
