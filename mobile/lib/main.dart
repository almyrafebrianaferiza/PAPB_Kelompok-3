import 'package:flutter/material.dart';
import 'services/layanan_api.dart';
import 'screens/katalog_page.dart';
import 'theme/zenvora_warna.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final layananApi = LayananApi();
  runApp(AplikasiZenvora(layananApi: layananApi));
}

class AplikasiZenvora extends StatelessWidget {
  final LayananApi layananApi;

  const AplikasiZenvora({super.key, required this.layananApi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenvorā - Toko Online Elektronik & Gawai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: ZWarna.oranye,
          onPrimary: ZWarna.hitam,
          secondary: ZWarna.oranyeTerang,
          onSecondary: ZWarna.hitam,
          surface: ZWarna.permukaan,
          onSurface: ZWarna.putih,
          error: ZWarna.galat,
          onError: ZWarna.putih,
        ),
        scaffoldBackgroundColor: ZWarna.hitam,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: ZWarna.permukaan,
          foregroundColor: ZWarna.putih,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            color: ZWarna.putih,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: ZWarna.putih),
        ),
        cardTheme: CardThemeData(
          color: ZWarna.permukaan,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZRadius.besar),
            side: const BorderSide(color: ZWarna.batas, width: 0.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: tombolUtama(penuh: false),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: tombolSekunder(penuh: false),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ZWarna.permukaanTinggi,
          labelStyle: const TextStyle(color: ZWarna.teksSekunder, fontSize: 14),
          hintStyle: const TextStyle(color: ZWarna.teksSamar, fontSize: 14),
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
        ),
        dividerTheme: const DividerThemeData(
          color: ZWarna.batas,
          thickness: 0.5,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: ZWarna.permukaan,
          selectedItemColor: ZWarna.oranye,
          unselectedItemColor: ZWarna.teksSamar,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: ZWarna.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ZRadius.besar),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: ZWarna.permukaanTinggi,
          contentTextStyle: TextStyle(
            fontFamily: 'Poppins',
            color: ZWarna.putih,
            fontSize: 14,
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: ZWarna.permukaanTinggi,
          selectedColor: ZWarna.oranye,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(color: ZWarna.batas),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: ZWarna.oranye,
        ),
      ),
      home: KatalogPage(layananApi: layananApi),
    );
  }
}
