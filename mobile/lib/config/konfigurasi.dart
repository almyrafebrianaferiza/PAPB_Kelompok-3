// Konfigurasi Terpusat Aplikasi Zenvorā Mobile
// Tempat tunggal untuk mengubah alamat server, token statis, dan batas waktu timeout.

// Pilihan Alamat Server:
// 1. Emulator Android: 'http://10.0.2.2:8000/api'
// 2. HP Fisik: Ganti dengan IP LAN laptop Anda, misal: 'http://192.168.1.10:8000/api'
// 3. Web AI Studio Cloud Preview: 'http://localhost:3000/api'
const String alamatServer = 'http://10.0.2.2:8000/api';

// Token statis pembeli sesuai instruksi tugas perkuliahan
const String tokenStatis = 'zenvora-dev-token-2026';

// Batas waktu pemanggilan HTTP sebelum melempar BatasWaktuException
const Duration batasWaktu = Duration(seconds: 10);
