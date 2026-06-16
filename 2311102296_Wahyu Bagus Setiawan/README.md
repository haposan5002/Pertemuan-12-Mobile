<div style="font-family: 'Times New Roman', Times, serif;">

<div align="center">
  <br />

  <h1>LAPORAN PRAKTIKUM <br>
  PEMROGRAMAN BERBASIS PLATFORM
  </h1>

  <br />

  <h3>TUGAS PERTEMUAN - 12<br>
    Praktikum Flutter — Notifikasi & API Perangkat Keras (Web & Mobile Compatibility)
  </h3>

  <br />

  <img src="assets/logotelu.jpeg" alt ="logo" width = "300">

  <br />
  <br />
  <br />

  <h3>Disusun Oleh :</h3>

  <p>
    <strong> Wahyu Bagus Setiawan </strong><br>
    <strong> 2311102296 </strong><br>
    <strong> IF-11-04 </strong>
  </p>

  <br />

  <h3>Dosen Pengampu :</h3>

  <p>
    <strong> Cahyo Prihantoro, S.Kom., M.Eng. </strong>
  </p>

  <br />

  <h3>LABORATORIUM REKAYASA PERANGKAT LUNAK
  <br>FAKULTAS INFORMATIKA <br> UNIVERSITAS TELKOM PURWOKERTO  <br>2026</h3>
</div>

<hr>

## 1. Penjelasan Singkat

Pada tugas **Pertemuan 12** ini, praktikum berfokus pada integrasi **API Perangkat Keras (Kamera & Galeri)** dan sistem **Notifikasi Lokal (Local Notifications)** pada framework Flutter. Aplikasi didesain secara adaptif dengan konsep **modern, elegan, dan fungsional** menggunakan tema **Dark Amethyst & Amber Theme** (Gradasi Ungu Gelap dan Aksen Kuning Amber Premium) serta dioptimalkan agar berjalan lancar baik di perangkat **Mobile maupun Web Browser (Google Chrome)**.

Konsep utama yang diterapkan:

1. **Cross-Platform Media Capture (image_picker)** : Menggunakan package `image_picker` untuk berinteraksi dengan modul kamera (`ImageSource.camera`) dan galeri (`ImageSource.gallery`). Kode disesuaikan agar mampu menangani pembacaan file mentah via memori bytes (`Uint8List`) demi mendukung pembatasan keamanan (*sandbox*) pada Google Chrome.
2. **Byte-Array Image Loading** : Mengganti implementasi `Image.file()` konvensional dengan `Image.memory()` yang menerima data *stream* bytes, sehingga gambar yang dipilih dari komputer/HP dapat dirender secara instan di platform web tanpa terhalang isu *broken path*.
3. **Conditional Local Notifications** : Memanfaatkan `flutter_local_notifications` untuk memicu push notification instan di tingkat native Android. Menggunakan pemeriksaan `kIsWeb` untuk mengalihkan notifikasi menjadi komponen *Interactive SnackBar* berbasis aksen Amber saat aplikasi dijalankan di lingkungan Google Chrome.
4. **Dynamic Permission Handling** : Mengintegrasikan `permission_handler` secara kondisional. Izin runtime (kamera dan galeri) akan dicek secara ketat pada platform mobile, namun dilewati (*bypassed*) secara cerdas pada platform web karena browser mengelola izin media secara internal.
5. **UI Eksklusif (Dark Amethyst)** : Antarmuka dibangun di atas kontainer gradasi linier ungu safir gelap (`Color(0xFF1F1135)` ke `Color(0xFF0B0416)`), kartu informasi EXIF/Metadata dengan font *monospace* berbingkai emas amber, serta susunan tombol aksi vertikal yang ergonomis.

---

## 2. Penjelasan Singkat Tiap File / Widget

Berikut adalah struktur komponen dan file utama yang diimplementasikan dalam proyek ini:

### `lib/main.dart`
- Bertindak sebagai **entri utama (entry point)** dari siklus hidup aplikasi. Memanggil fungsi asinkron `WidgetsFlutterBinding.ensureInitialized()` untuk memastikan jembatan komunikasi API Native (Android/Web) siap sebelum merender widget.
- Menginisialisasi layanan notifikasi lewat `NotificationManager().initNotification()`.
- Menyajikan kelas `ApplicationRoot` (`StatelessWidget`) yang mengonfigurasi `MaterialApp` dengan skema warna gelap kustom (`ThemeData.dark()`) berbasis *seed color* Amethyst, menonaktifkan banner debug, serta memuat `DashboardScreen`.

### `lib/screens/dashboard_screen.dart`
- Merupakan komponen dashboard utama (`StatefulWidget`) yang mengatur manajemen state media (`_webImage` berbasis `Uint8List`) dan status pemrosesan (`_isProcessing`). Widget ini memuat struktur visual berikut:
  - **Oval Image Preview Container**: Wadah pratinjau gambar membulat (*border radius* 32) dengan latar transparan redup. Menampilkan indikator loading secara dinamis saat berkas dimuat, atau merender gambar via `Image.memory()`.
  - **Metadata EXIF Card View**: Kotak informasi monospaced di bagian bawah pratinjau yang menampilkan status berkas, nama media (dipotong maksimal 20 karakter agar rapi), ukuran file dalam satuan KiloBytes (KB), serta jam sinkronisasi waktu lokal secara real-time.
  - **Vertical Action Buttons**: Sepasang tombol aksi vertikal. Tombol utama menggunakan `ElevatedButton` berwarna Amber emas untuk memicu kamera, sementara tombol kedua menggunakan `OutlinedButton` putih transparan untuk menjelajahi galeri sistem.

### `lib/services/notification_manager.dart`
- Kelas manager yang mengadopsi pola rancangan **Singleton Pattern** (`_internal()`) untuk menjamin hanya ada satu instance plugin notifikasi yang hidup di memori.
- Mengonfigurasi `FlutterLocalNotificationsPlugin` menggunakan ikon peluncur bawaan (`@mipmap/ic_launcher`) untuk inisialisasi Android.
- Menyediakan fungsi `showMediaNotification()` dengan konfigurasi kanal khusus (`media_capture_channel_id`, prioritas tinggi, getaran, dan suara aktif) untuk memicu push notification instan bertajuk "✨ Berkas Masuk!" beserta payload jam real-time.

### `android/app/build.gradle`
- Mengonfigurasi parameter kompilasi level Android. Mengubah `minSdkVersion` menjadi **21** (Android 5.0 Lollipop) agar menjamin kecocokan penuh dengan pustaka notifikasi lokal dan manajemen izin modern.

---

## 3. Langkah-langkah Pembuatan Aplikasi

### Langkah 1 — Inisialisasi Project Flutter
Buat proyek baru dengan nama paket organisasi kustom melalui terminal (pastikan nama folder menggunakan huruf kecil/lowercase sesuai standar Dart):
```bash
flutter create --org com.wahyubagus laprak_pertemuan_12
cd laprak_pertemuan_12