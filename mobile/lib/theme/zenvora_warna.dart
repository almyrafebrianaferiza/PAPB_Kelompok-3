import 'package:flutter/material.dart';

abstract final class ZWarna {
  static const hitam = Color(0xFF050505);
  static const permukaan = Color(0xFF111111);
  static const permukaanTinggi = Color(0xFF1B1B1B);

  static const putih = Color(0xFFFFFFFF);
  static const teksSekunder = Color(0xFFA3A3A3);
  static const teksSamar = Color(0xFF737373);
  static const teksNonaktif = Color(0xFF555555);

  static const batas = Color(0xFF2A2A2A);

  static const oranye = Color(0xFFFF6A00);
  static const oranyeGelap = Color(0xFFF05A00);
  static const oranyeTerang = Color(0xFFFF8A00);
  static const kuning = Color(0xFFFFC928);
  static const kuningLembut = Color(0xFFFFE08A);

  static const sukses = Color(0xFF22A06B);
  static const peringatan = Color(0xFFE5A000);
  static const galat = Color(0xFFE5484D);
  static const info = Color(0xFF3B82F6);

  static const gradienUtama = LinearGradient(
    begin: Alignment(-0.7, -0.3),
    end: Alignment(0.9, 0.5),
    colors: [oranyeGelap, oranye, kuning],
    stops: [0.0, 0.45, 1.0],
  );

  static const gradienAksen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [oranyeTerang, kuning],
  );
}

abstract final class ZRadius {
  static const kecil = 6.0;
  static const sedang = 10.0;
  static const besar = 16.0;
  static const ekstra = 24.0;
  static const penuh = 999.0;
}

ButtonStyle tombolUtama({bool penuh = true}) {
  return ElevatedButton.styleFrom(
    backgroundColor: ZWarna.oranye,
    foregroundColor: ZWarna.hitam,
    disabledBackgroundColor: ZWarna.permukaanTinggi,
    disabledForegroundColor: ZWarna.teksNonaktif,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    minimumSize: penuh ? const Size.fromHeight(48) : const Size(0, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
}

ButtonStyle tombolBahaya({bool penuh = true}) {
  return ElevatedButton.styleFrom(
    backgroundColor: ZWarna.galat,
    foregroundColor: ZWarna.putih,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    minimumSize: penuh ? const Size.fromHeight(48) : const Size(0, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
}

ButtonStyle tombolSekunder({bool penuh = true}) {
  return OutlinedButton.styleFrom(
    foregroundColor: ZWarna.teksSekunder,
    side: const BorderSide(color: ZWarna.batas),
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    minimumSize: penuh ? const Size.fromHeight(48) : const Size(0, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
}

InputDecoration dekorasiInput({
  required String label,
  String? petunjuk,
  String? pesanGalat,
  Widget? awalan,
  Widget? akhiran,
}) {
  return InputDecoration(
    labelText: label,
    hintText: petunjuk,
    errorText: pesanGalat,
    prefixIcon: awalan,
    suffixIcon: akhiran,
    filled: true,
    fillColor: ZWarna.permukaanTinggi,
    labelStyle: const TextStyle(color: ZWarna.teksSekunder, fontSize: 14),
    hintStyle: const TextStyle(color: ZWarna.teksSamar, fontSize: 14),
    errorStyle: const TextStyle(color: ZWarna.galat, fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
      borderSide: const BorderSide(color: ZWarna.batas),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
      borderSide: const BorderSide(color: ZWarna.batas),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
      borderSide: const BorderSide(color: ZWarna.oranye, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
      borderSide: const BorderSide(color: ZWarna.galat),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ZRadius.sedang),
      borderSide: const BorderSide(color: ZWarna.galat, width: 1.5),
    ),
  );
}
