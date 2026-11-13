# ZENVORĀ --- Design System

> **Tagline:** Explore the Future of Technology\
> **Versi:** 1.0\
> **Platform:** Web application dan mobile application\
> **Arah visual:** Modern, futuristik, premium, tegas, dan mudah
> digunakan.

Dokumen ini menjadi acuan visual dan UI saat merancang maupun
mengembangkan aplikasi Zenvorā. Identitas visual mengacu pada logo:
latar gelap, tipografi putih, serta aksen oranye dan kuning dengan efek
gradasi.

------------------------------------------------------------------------

## 1. Brand Identity

### Karakter desain

-   **Modern:** tampilan bersih dengan komposisi yang rapi.
-   **Futuristik:** aksen gradasi, highlight, dan elemen visual yang
    terasa dinamis.
-   **Premium:** dominasi warna hitam, ruang kosong yang cukup, dan
    penggunaan efek secukupnya.
-   **Accessible:** teks mudah dibaca, kontras jelas, dan kontrol mudah
    digunakan di layar kecil.

### Prinsip penggunaan

1.  Gunakan hitam atau putih sebagai warna dasar halaman.
2.  Gunakan oranye--kuning sebagai aksen untuk tombol utama, tautan
    penting, ikon aktif, dan highlight.
3.  Jangan menggunakan gradasi pada semua elemen. Simpan untuk elemen
    yang perlu menonjol.
4.  Utamakan keterbacaan dan konsistensi dibanding dekorasi.
5.  Hindari teks abu-abu yang terlalu redup di atas latar hitam.

------------------------------------------------------------------------

## 2. Color Palette

### Warna utama

  -----------------------------------------------------------------------
  Token                   HEX                     Penggunaan
  ----------------------- ----------------------- -----------------------
  `Black / Primary`       `#050505`               Latar utama dark mode,
                                                  header, footer

  `Black / Surface`       `#111111`               Card dan panel di dark
                                                  mode

  `Black / Elevated`      `#1B1B1B`               Input, dropdown,
                                                  surface bertingkat

  `White / Primary`       `#FFFFFF`               Teks utama pada dark
                                                  mode dan latar light
                                                  mode

  `White / Soft`          `#F5F5F5`               Latar halaman light
                                                  mode

  `Gray / Text`           `#777777`               Teks sekunder pada
                                                  light mode

  `Gray / Muted`          `#A3A3A3`               Teks sekunder pada dark
                                                  mode

  `Gray / Border`         `#2A2A2A`               Border pada dark mode

  `Gray / Light Border`   `#E5E5E5`               Border pada light mode
  -----------------------------------------------------------------------

### Warna aksen dan gradasi

  -----------------------------------------------------------------------
  Token                   HEX                     Penggunaan
  ----------------------- ----------------------- -----------------------
  `Orange / Deep`         `#F05A00`               Hover, aksen gelap,
                                                  gradient start

  `Orange / Primary`      `#FF6A00`               Tombol utama, ikon
                                                  aktif, link penting

  `Orange / Bright`       `#FF8A00`               Highlight dan gradient
                                                  middle

  `Yellow / Primary`      `#FFC928`               Ujung gradasi, badge,
                                                  highlight

  `Yellow / Soft`         `#FFE08A`               Background aksen lembut
  -----------------------------------------------------------------------

**Gradient utama Zenvorā**

``` css
linear-gradient(110deg, #F05A00 0%, #FF6A00 45%, #FFC928 100%)
```

**Gradient alternatif untuk highlight**

``` css
linear-gradient(135deg, #FF8A00 0%, #FFC928 100%)
```

Gunakan gradient utama untuk tombol CTA, garis aksen, ikon khusus, atau
bagian logo. Untuk teks panjang, gunakan warna solid agar tetap terbaca.

### Warna status

  Status    HEX         Penggunaan
  --------- ----------- --------------------------------------
  Success   `#22A06B`   Berhasil, tersedia, selesai
  Warning   `#E5A000`   Perhatian, stok terbatas
  Error     `#E5484D`   Gagal, kesalahan, tindakan berbahaya
  Info      `#3B82F6`   Informasi dan bantuan

------------------------------------------------------------------------

## 3. Typography

### Font family

Gunakan **Poppins** sebagai font utama untuk seluruh aplikasi.

``` css
font-family: 'Poppins', sans-serif;
```

Import dari Google Fonts:

``` css
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
```

### Font weight

  Weight        Nilai Penggunaan
  ----------- ------- ---------------------------------
  Light           300 Teks dekoratif atau tagline
  Regular         400 Paragraf dan deskripsi
  Medium          500 Label, navigasi, teks pendukung
  SemiBold        600 Subjudul dan tombol
  Bold            700 Judul dan heading
  ExtraBold       800 Hero heading atau angka promosi

### Skala tipografi --- Desktop

  Elemen                    Ukuran     Weight   Line height
  -------------------- ----------- ---------- -------------
  Display / Hero             56 px   700--800          1.15
  H1 / Judul halaman         40 px        700           1.2
  H2 / Judul bagian          32 px   600--700          1.25
  H3 / Subjudul              24 px        600           1.3
  H4 / Judul card            20 px        600          1.35
  Body Large                 18 px        400           1.6
  Body / Paragraf            16 px        400           1.6
  Body Small                 14 px        400           1.5
  Caption                    12 px   400--500           1.5
  Button / Label         14--16 px        600           1.2

### Skala tipografi --- Mobile

  Elemen                    Ukuran     Weight   Line height
  -------------------- ----------- ---------- -------------
  Display / Hero             36 px   700--800          1.15
  H1 / Judul halaman         30 px        700           1.2
  H2 / Judul bagian          24 px   600--700          1.25
  H3 / Subjudul              20 px        600           1.3
  H4 / Judul card            18 px        600          1.35
  Body Large                 16 px        400           1.6
  Body / Paragraf            14 px        400           1.6
  Body Small                 13 px        400           1.5
  Caption                11--12 px   400--500           1.5
  Button / Label         14--16 px        600           1.2

### Warna teks

  ------------------------------------------------------------------------
  Token              Dark mode         Light mode        Penggunaan
  ------------------ ----------------- ----------------- -----------------
  `Text Primary`     `#FFFFFF`         `#111111`         Judul dan isi
                                                         utama

  `Text Secondary`   `#A3A3A3`         `#777777`         Deskripsi dan
                                                         informasi
                                                         pendukung

  `Text Muted`       `#737373`         `#999999`         Placeholder dan
                                                         caption

  `Text Accent`      `#FF8A00`         `#F05A00`         Link dan teks
                                                         yang di-highlight

  `Text Disabled`    `#555555`         `#BDBDBD`         Teks nonaktif
  ------------------------------------------------------------------------

**Aturan:** judul menggunakan hitam atau putih sesuai latar. Subjudul
dan teks pendukung menggunakan abu-abu. Oranye digunakan sebagai
penekanan, bukan untuk seluruh paragraf.

------------------------------------------------------------------------

## 4. Layout dan Responsive Breakpoints

Gunakan pendekatan **mobile-first**. Layout harus tetap nyaman digunakan
pada ponsel, tablet, laptop, dan desktop.

  Device            Lebar viewport   Container maksimum   Padding horizontal
  --------------- ---------------- -------------------- --------------------
  Small mobile         320--374 px                Fluid                16 px
  Mobile               375--767 px                Fluid                20 px
  Tablet              768--1023 px               720 px                24 px
  Laptop             1024--1279 px               960 px                32 px
  Desktop            1280--1439 px              1200 px                40 px
  Large desktop           ≥1440 px              1320 px                48 px

### Grid

-   Desktop: 12 kolom.
-   Tablet: 8 kolom.
-   Mobile: 4 kolom.
-   Jarak antar-kolom desktop: 24 px.
-   Jarak antar-kolom mobile: 16 px.
-   Lebar konten teks panjang sebaiknya dibatasi sekitar 65--75 karakter
    per baris.

### Breakpoint CSS

``` css
/* Mobile first */
@media (min-width: 768px) { /* Tablet */ }
@media (min-width: 1024px) { /* Laptop */ }
@media (min-width: 1280px) { /* Desktop */ }
@media (min-width: 1440px) { /* Large desktop */ }
```

------------------------------------------------------------------------

## 5. Spacing System

Gunakan kelipatan 4 px agar jarak antar-elemen konsisten.

  Token          Ukuran Penggunaan
  ------------ -------- -------------------------------
  `space-1`        4 px Jarak ikon dan teks
  `space-2`        8 px Jarak elemen kecil
  `space-3`       12 px Jarak label dan input
  `space-4`       16 px Jarak standar komponen
  `space-5`       20 px Jarak dalam card
  `space-6`       24 px Jarak antar-komponen
  `space-8`       32 px Jarak antar-kelompok
  `space-10`      40 px Jarak section kecil
  `space-12`      48 px Jarak section
  `space-16`      64 px Jarak section besar
  `space-20`      80 px Jarak hero atau section utama

------------------------------------------------------------------------

## 6. Border Radius, Border, dan Shadow

### Radius

  Token             Ukuran Penggunaan
  --------------- -------- ------------------------
  `radius-sm`         6 px Badge kecil
  `radius-md`        10 px Input dan tombol
  `radius-lg`        16 px Card
  `radius-xl`        24 px Panel besar atau modal
  `radius-full`     999 px Pill button dan avatar

### Border

-   Dark mode: `1px solid #2A2A2A`.
-   Light mode: `1px solid #E5E5E5`.
-   Border aksen: gunakan oranye hanya untuk kondisi aktif atau
    terpilih.

### Shadow

``` css
/* Card pada light mode */
box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);

/* Elemen mengambang pada dark mode */
box-shadow: 0 8px 28px rgba(0, 0, 0, 0.28);

/* Glow aksen — gunakan seperlunya */
box-shadow: 0 0 24px rgba(255, 106, 0, 0.18);
```

------------------------------------------------------------------------

## 7. Komponen UI

### Button

  -----------------------------------------------------------------------
  Jenis                   Tampilan                Penggunaan
  ----------------------- ----------------------- -----------------------
  Primary                 Gradient                Aksi utama
                          oranye--kuning, teks    
                          hitam atau putih dengan 
                          kontras memadai         

  Secondary               Background transparan,  Aksi pendamping
                          border abu-abu          

  Outline                 Border oranye, teks     Aksi alternatif
                          oranye                  

  Ghost                   Tanpa background, teks  Aksi ringan
                          mengikuti tema          

  Danger                  Background merah        Hapus atau tindakan
                                                  berisiko
  -----------------------------------------------------------------------

Spesifikasi: - Tinggi desktop: 48 px. - Tinggi mobile: minimal 44 px. -
Padding horizontal: 20--24 px. - Radius: 10 px. - Font: Poppins 14--16
px, weight 600. - Sediakan state default, hover, pressed, focus,
disabled, dan loading.

### Input dan Form

-   Tinggi input: 48--52 px.
-   Padding horizontal: 16 px.
-   Radius: 10 px.
-   Border default: abu-abu.
-   Border focus: oranye.
-   Label: 14 px, weight 500.
-   Placeholder: abu-abu.
-   Pesan error: 12--13 px, warna error.
-   Jangan hanya mengandalkan warna untuk menandai error; sertakan pesan
    teks.

### Card

-   Background dark: `#111111`.
-   Background light: `#FFFFFF`.
-   Border: 1 px.
-   Radius: 16 px.
-   Padding desktop: 24 px.
-   Padding mobile: 16 px.
-   Gunakan shadow ringan dan hindari glow berlebihan.

### Navigation

**Desktop** - Navbar horizontal. - Tinggi sekitar 72--80 px. - Logo di
sisi kiri, menu di tengah atau kanan, CTA di sisi kanan. - Item aktif
diberi aksen oranye.

**Mobile** - Navbar ringkas dengan logo dan menu. - Gunakan bottom
navigation jika aplikasi memiliki 3--5 menu utama. - Tinggi area
navigasi sentuh minimal 44 px.

### Badge dan Chip

-   Tinggi: 24--32 px.
-   Radius: full.
-   Font: 12--13 px, weight 500--600.
-   Gunakan warna aksen untuk status penting saja.

### Modal dan Dialog

-   Radius: 16--24 px.
-   Padding desktop: 24--32 px.
-   Padding mobile: 20 px.
-   Tampilkan judul, penjelasan singkat, dan aksi yang jelas.
-   Pada mobile, modal dapat menggunakan pola bottom sheet.

------------------------------------------------------------------------

## 8. Iconography dan Imagery

-   Gunakan satu gaya ikon secara konsisten, disarankan outline
    sederhana.
-   Ukuran ikon standar: 20--24 px.
-   Ikon kecil: 16 px; ikon fitur utama: 28--32 px.
-   Ikon aktif dapat menggunakan oranye atau gradient.
-   Gunakan ilustrasi dan foto produk berkualitas tinggi dengan latar
    yang tidak terlalu ramai.
-   Hindari mencampur ikon 3D, outline, dan filled tanpa aturan.
-   Berikan ruang kosong yang cukup di sekitar logo dan elemen visual
    utama.

------------------------------------------------------------------------

## 9. Dark Mode dan Light Mode

### Dark mode --- tampilan utama brand

-   Page background: `#050505`.
-   Surface/card: `#111111`.
-   Elevated surface: `#1B1B1B`.
-   Primary text: `#FFFFFF`.
-   Secondary text: `#A3A3A3`.
-   Border: `#2A2A2A`.
-   Accent: gradient oranye--kuning.

### Light mode --- alternatif

-   Page background: `#F5F5F5`.
-   Surface/card: `#FFFFFF`.
-   Primary text: `#111111`.
-   Secondary text: `#777777`.
-   Border: `#E5E5E5`.
-   Accent: `#F05A00` atau gradient utama.

Jangan membalik semua warna secara otomatis tanpa mengecek kontras
setiap komponen.

------------------------------------------------------------------------

## 10. Accessibility dan Usability

1.  Pastikan kontras teks dan background nyaman dibaca; targetkan WCAG
    AA untuk teks normal.
2.  Jangan menyampaikan status hanya melalui warna. Tambahkan label,
    ikon, atau pesan.
3.  Area sentuh tombol dan kontrol minimal 44 × 44 px.
4.  Sediakan focus state yang terlihat untuk navigasi keyboard.
5.  Gunakan ukuran teks body minimal 14 px pada mobile.
6.  Berikan label yang jelas pada input dan ikon yang memiliki aksi.
7.  Hormati pengaturan reduced motion jika menggunakan animasi.
8.  Pastikan layout tidak menyebabkan scroll horizontal pada layar
    kecil.

------------------------------------------------------------------------

## 11. Motion dan Interaction

-   Durasi transisi standar: 150--250 ms.
-   Gunakan easing yang halus, misalnya `ease-in-out`.
-   Hover button: perubahan brightness atau sedikit perubahan warna.
-   Card hover desktop: naik 2--4 px atau border sedikit lebih terang.
-   Hindari animasi yang terus bergerak dan mengganggu fokus.
-   Jangan menjadikan animasi sebagai satu-satunya petunjuk bahwa aksi
    berhasil.

``` css
transition: all 200ms ease-in-out;
```

------------------------------------------------------------------------

## 12. Contoh Design Tokens CSS

Gunakan token berikut sebagai dasar implementasi. Token dapat
dikembangkan sesuai kebutuhan halaman.

``` css
:root {
  /* Brand */
  --color-black: #050505;
  --color-surface: #111111;
  --color-surface-elevated: #1B1B1B;
  --color-white: #FFFFFF;
  --color-white-soft: #F5F5F5;

  /* Accent */
  --color-orange-deep: #F05A00;
  --color-orange: #FF6A00;
  --color-orange-bright: #FF8A00;
  --color-yellow: #FFC928;
  --color-yellow-soft: #FFE08A;
  --gradient-brand: linear-gradient(
    110deg,
    #F05A00 0%,
    #FF6A00 45%,
    #FFC928 100%
  );

  /* Text */
  --text-primary-dark: #FFFFFF;
  --text-secondary-dark: #A3A3A3;
  --text-muted-dark: #737373;
  --text-primary-light: #111111;
  --text-secondary-light: #777777;

  /* Border */
  --border-dark: #2A2A2A;
  --border-light: #E5E5E5;

  /* Typography */
  --font-family: 'Poppins', sans-serif;

  /* Radius */
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
  --radius-xl: 24px;
  --radius-full: 999px;

  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;
}
```

------------------------------------------------------------------------

## 13. Do and Don't

  -----------------------------------------------------------------------
  Do                                  Don't
  ----------------------------------- -----------------------------------
  Gunakan hitam sebagai dasar visual  Menggunakan banyak warna aksen
  utama                               sekaligus

  Gunakan gradient oranye--kuning     Memberi gradient pada semua card
  secara terarah                      dan teks

  Gunakan Poppins secara konsisten    Mencampur banyak jenis font

  Gunakan abu-abu untuk teks sekunder Membuat teks sekunder terlalu samar

  Jaga jarak dan alignment tetap      Menumpuk elemen terlalu rapat
  konsisten                           

  Buat layout responsif dan           Hanya mendesain untuk desktop
  mobile-first                        

  Gunakan animasi singkat dan         Menggunakan animasi berlebihan
  fungsional                          
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 14. Checklist Sebelum Development

-   [ ] Warna mengikuti token yang sudah ditentukan.
-   [ ] Font Poppins dan weight sesuai hierarki.
-   [ ] Ukuran heading dan body sesuai device.
-   [ ] Layout diuji pada mobile, tablet, dan desktop.
-   [ ] Button, input, card, dan navigasi konsisten.
-   [ ] State hover, focus, active, disabled, dan error tersedia.
-   [ ] Kontras teks dapat dibaca.
-   [ ] Tidak ada horizontal overflow pada mobile.
-   [ ] Penggunaan gradient tetap terkontrol.
-   [ ] Tampilan dark mode dan light mode (jika tersedia) sudah
    diperiksa.

------------------------------------------------------------------------

**Catatan:** nilai ukuran dan warna dalam dokumen ini merupakan design
token awal. Saat implementasi, sesuaikan berdasarkan kebutuhan konten
dan hasil pengujian pada perangkat nyata, tanpa menghilangkan
konsistensi identitas visual Zenvorā.
