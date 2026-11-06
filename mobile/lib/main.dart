import 'package:flutter/material.dart';
import 'services/layanan_api.dart';
import 'screens/katalog_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Seluruh konfigurasi (alamat server, token, timeout) ada di konfigurasi.dart;
  // LayananApi membaca konstanta top-level tersebut tanpa parameter constructor.
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: KatalogPage(layananApi: layananApi),
    );
  }
}
