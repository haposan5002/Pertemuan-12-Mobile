<div style="font-family: 'Times New Roman', Times, serif;">

<div align="center">
  <br />

  <h1>LAPORAN PRAKTIKUM <br>
  PEMROGRAMAN BERBASIS PLATFORM
  </h1>

  <br />

  <h3>TUGAS PERTEMUAN - 12<br>
    Praktikum Flutter — Notifikasi & API Perangkat Keras
  </h3>

  <br />

  <img src="assets/logotelu.jpeg" alt ="logo" width = "300">

  <br />
  <br />
  <br />

  <h3>Disusun Oleh :</h3>

  <p>
    <strong> Titanio Francy Naddiansa </strong><br>
    <strong> 2311102289 </strong><br>
    <strong> IF-11-04 </strong>
  </p>

  <br />

  <h3>Dosen Pengampu :</h3>

  <p>
    <strong> Cahyo Prihantoro, S.Kom., M.Eng. </strong>
  </p>

  <br />

  <h3>LABORATORIUM REKAYASA PERANGKAT LUNAK
  <br>FAKULTAS INFORMATIKA <br> UNIVERSITA TELKOM PURWOKERTO  <br>2026</h3>
</div>

<hr>

## 1. Penjelasan Singkat

Pada tugas **Pertemuan 12** ini, praktikum berfokus pada integrasi **API Perangkat Keras (Kamera & Galeri)** dan sistem **Notifikasi Lokal (Local Notifications)** pada framework Flutter. Aplikasi didesain dengan konsep **modern, bersih, dan fungsional** menggunakan skema warna Teal/Hijau Gelap.

Konsep utama yang diterapkan:

1. **Camera API (image_picker — Kamera)** : Menggunakan package `image_picker` dengan `ImageSource.camera` untuk berinteraksi langsung dengan modul kamera perangkat. Pengguna dapat mengambil foto secara real-time dan hasilnya langsung ditampilkan di halaman utama.
2. **Gallery Picker (image_picker — Galeri)** : Menggunakan `image_picker` dengan `ImageSource.gallery` untuk memicu antarmuka galeri bawaan sistem operasi Android, memungkinkan pengguna memilih foto yang tersimpan di memori perangkat.
3. **Local Notifications** : Menggunakan package `flutter_local_notifications` untuk menampilkan push notification secara lokal di perangkat sesaat setelah foto berhasil diambil dari kamera ataupun dipilih dari galeri.
4. **Permission Handling** : Mengimplementasikan `permission_handler` untuk mengelola izin runtime (kamera, galeri, notifikasi) secara dinamis sesuai versi Android target.
5. **Desain Modern & Elegan** : Mengimplementasikan antarmuka Material 3 dengan warna utama `Color(0xFF2D6A4F)` (Teal/Hijau Gelap), kartu status, area preview gambar berbingkai membulat, serta tombol aksi dengan gradasi dan elevasi lembut.

---

## 2. Penjelasan Singkat Tiap File / Widget

Berikut adalah penjelasan file utama yang digunakan dalam proyek ini:

### `lib/main.dart`
- Merupakan **entry point** dari aplikasi. Bertugas memanggil `WidgetsFlutterBinding.ensureInitialized()` agar plugin Flutter siap sebelum aplikasi berjalan, kemudian menyajikan `MyApp` sebagai root widget.
- `MyApp` (`StatelessWidget`) mengatur konfigurasi `MaterialApp`: tema visual utama berbasis `ColorScheme.fromSeed` dengan warna seed `Color(0xFF2D6A4F)`, menonaktifkan banner debug, serta menetapkan `HomeScreen` sebagai halaman utama.

### `lib/screens/home_screen.dart`
- `HomeScreen` (`StatefulWidget`) adalah halaman dashboard utama yang memegang state dari file foto yang dipilih (`_selectedImage`). Widget ini memuat:
  - **Status Card**: Kartu informasi di bagian atas yang menampilkan pesan status terkini (loading, berhasil, dibatalkan) beserta indikator `CircularProgressIndicator` saat proses berlangsung.
  - **Button Row**: Dua tombol aksi utama yang ditampilkan secara horizontal.
    - **Tombol "Buka Kamera"** (`_ActionButton`, warna hijau gelap): Memanggil `ImagePicker` dengan `ImageSource.camera` setelah memvalidasi izin kamera.
    - **Tombol "Buka Galeri"** (`_ActionButton`, warna biru gelap): Memanggil `ImagePicker` dengan `ImageSource.gallery` setelah memvalidasi izin penyimpanan/foto.
  - **Image Area**: Area pratinjau foto dengan logika kondisional — menampilkan placeholder ikon jika belum ada foto, atau menampilkan gambar melalui `Image.file()` jika foto berhasil diperoleh, dilengkapi tombol "Hapus".
  - **`_ActionButton`** (`StatelessWidget`): Widget tombol reusable yang menerima icon, label, subtitle, warna, dan callback. Mendukung animasi disabled saat proses berlangsung.

### `lib/services/notification_service.dart`
- `NotificationService` (Singleton): Kelas layanan yang mengenkapsulasi seluruh logika notifikasi lokal.
  - `initialize()`: Menginisialisasi `FlutterLocalNotificationsPlugin` dengan `AndroidInitializationSettings` dan mendaftarkan callback untuk notifikasi yang di-tap.
  - `requestPermission()`: Meminta izin `POST_NOTIFICATIONS` pada Android 13+ menggunakan `permission_handler`.
  - `showFotoKameraNotification()`: Menampilkan notifikasi bertajuk "📸 Foto Berhasil Diambil!" dengan channel `foto_channel`, prioritas tinggi, dan vibration aktif.
  - `showFotoGaleriNotification()`: Menampilkan notifikasi bertajuk "🖼️ Foto Berhasil Dipilih!" dengan konfigurasi channel yang sama.

### `android/app/src/main/AndroidManifest.xml`
- Mendefinisikan seluruh **izin (permissions)** yang diperlukan aplikasi: `CAMERA`, `READ_MEDIA_IMAGES` (Android 13+), `READ_EXTERNAL_STORAGE` (Android < 13), `POST_NOTIFICATIONS`, dan `VIBRATE`.
- Mendaftarkan `FileProvider` untuk mendukung `image_picker` dalam berbagi URI file secara aman antar aplikasi.
- Mendaftarkan receiver `ScheduledNotificationReceiver` dan `ScheduledNotificationBootReceiver` untuk mendukung notifikasi terjadwal dari `flutter_local_notifications`.

---

## 3. Langkah-langkah Pembuatan Aplikasi

### Langkah 1 — Inisialisasi Project Flutter

Buat project Flutter baru melalui Android Studio atau terminal:
```bash
flutter create flutter_foto_notif
cd flutter_foto_notif
```

---

### Langkah 2 — Tambahkan Dependencies di `pubspec.yaml`

Tambahkan library eksternal berikut untuk mengaktifkan fitur kamera, galeri, notifikasi lokal, dan pengelolaan izin pada file `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  flutter_local_notifications: ^17.1.2
  permission_handler: ^11.3.0
  path_provider: ^2.1.3
  path: ^1.9.0
```

Setelah itu, jalankan perintah untuk mengunduh package:
```bash
flutter pub get
```

---

### Langkah 3 — Konfigurasi Izin Sistem Android

**a. Edit `android/app/src/main/AndroidManifest.xml`**

Tambahkan izin runtime dan konfigurasi FileProvider di dalam tag `<manifest>`:
```xml
<!-- Permissions Kamera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Permissions Galeri (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Permissions Galeri (Android < 13) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Permissions Notifikasi -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
```

**b. Edit `android/app/build.gradle`**

Pastikan `minSdkVersion` diset ke `21` agar kompatibel dengan semua library yang digunakan:
```groovy
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
    compileSdkVersion 34
}
```

---

### Langkah 4 — Buat File `res/xml/file_paths.xml`

Buat folder `android/app/src/main/res/xml/` dan buat file `file_paths.xml` untuk konfigurasi FileProvider:
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="my_images" path="." />
    <cache-path name="cache" path="." />
</paths>
```

---

### Langkah 5 — Implementasi `NotificationService`

Buat folder `lib/services/` dan implementasikan `notification_service.dart` sebagai singleton service yang mengelola inisialisasi plugin, permintaan izin, dan pengiriman notifikasi lokal dengan channel dan prioritas yang tepat.

---

### Langkah 6 — Implementasi `HomeScreen`

Buat folder `lib/screens/` dan implementasikan `home_screen.dart` dengan:
- State management untuk `_selectedImage` dan `_isLoading`
- Logika permission handling berbasis versi Android
- Integrasi `ImagePicker` untuk kamera dan galeri
- Pemanggilan `NotificationService` setelah foto berhasil diperoleh
- UI responsif dengan `Status Card`, `Button Row`, dan `Image Area`

---

### Langkah 7 — Update `main.dart`

Pastikan `WidgetsFlutterBinding.ensureInitialized()` dipanggil sebelum `runApp()` agar semua plugin native dapat diinisialisasi dengan benar:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

---

## 4. Struktur File Proyek

Struktur folder akhir dari project `flutter_foto_notif` adalah sebagai berikut:

```
flutter_foto_notif/
├── android/
│   └── app/
│       ├── src/main/
│       │   ├── AndroidManifest.xml          ← izin hardware, FileProvider, receiver notif
│       │   └── res/xml/
│       │       └── file_paths.xml           ← konfigurasi path FileProvider
│       └── build.gradle                     ← konfigurasi minSdk & compileSdk
├── lib/
│   ├── main.dart                            ← entry point & konfigurasi tema MaterialApp
│   ├── screens/
│   │   └── home_screen.dart                 ← halaman utama, UI, logika kamera & galeri
│   └── services/
│       └── notification_service.dart        ← singleton service notifikasi lokal
└── pubspec.yaml                             ← dependencies proyek
```

---

## 5. Cara Menjalankan Aplikasi

1. Aktifkan **USB Debugging** pada smartphone Android Anda dan hubungkan ke laptop/PC menggunakan kabel data.
2. Buka terminal pada folder project.
3. Pastikan perangkat Anda terdeteksi dengan perintah:
   ```bash
   flutter devices
   ```
4. Jalankan aplikasi ke perangkat target:
   ```bash
   flutter run
   ```
5. Saat aplikasi terbuka untuk pertama kali, berikan izin ketika muncul pop-up untuk menggunakan **kamera**, **galeri**, dan mengirimkan **notifikasi**.

> **Catatan:** Fitur kamera tidak berjalan optimal di emulator. Disarankan menggunakan **perangkat fisik** untuk pengujian penuh.

---

## 6. Screenshot Hasil Tampilan

<div align="center">

| No | Deskripsi Tampilan | Screenshot |
|:---:|:---|:---:|
| 1 | **Halaman Utama** — Pop-up izin notifikasi muncul pertama kali | <img src="/assets/gambar1.png" width="250" /> |
| 2 | **Halaman Utama** — Setelah foto berhasil diambil dari kamera, notifikasi muncul | <img src="/assets/gambar2.png" width="250" /> |
| 3 | **Galeri Android** — Antarmuka pemilih foto dari galeri terbuka | <img src="/assets/gambar3.png" width="250" /> |
| 4 | **Halaman Utama** — Setelah foto berhasil dipilih dari galeri, foto ditampilkan | <img src="/assets/gambar4.png" width="250" /> |

</div>

> 

---

## 7. Kesimpulan

Pada praktikum Pertemuan 12 ini, telah berhasil diimplementasikan:

1. **Penggunaan API Kamera & Galeri** melalui package `image_picker` yang memungkinkan interaksi langsung dengan perangkat keras kamera maupun galeri media bawaan Android secara aman dan lintas versi.
2. **Pengelolaan Izin Runtime (Permission Handling)** secara dinamis menggunakan `permission_handler`, termasuk penanganan perbedaan izin antara Android 13+ (`READ_MEDIA_IMAGES`) dan Android versi di bawahnya (`READ_EXTERNAL_STORAGE`).
3. **Penyajian Notifikasi Lokal** secara instan di system tray Android setelah foto berhasil diambil atau dipilih, menggunakan notification channel yang dikonfigurasi melalui `flutter_local_notifications` dengan prioritas tinggi dan vibration aktif.
4. **Arsitektur Kode Terstruktur** dengan pemisahan tanggung jawab yang jelas antara layer UI (`home_screen.dart`) dan layer layanan (`notification_service.dart`), menggunakan pola Singleton untuk efisiensi inisialisasi plugin.
5. **Desain Antarmuka Modern & Fungsional** berbasis Material 3 dengan skema warna Teal/Hijau Gelap, status card informatif, tombol aksi responsif, dan area preview foto yang adaptif.

</div>
