<<<<<<< HEAD
# LAPORAN PRAKTIKUM PEMROGRAMAN APLIKASI BERGERAK
## PERTEMUAN 12 — INTEGRASI KAMERA DAN NOTIFIKASI LOKAL

### IDENTITAS MAHASISWA
* **Nama** : Abdee Alamsyah Noer Siyam
* **NIM** : 2311102247
* **Kelas** : S1-IF11-04
* **Program Studi** : S1 Teknik Informatika
* **Kampus** : Telkom University Purwokerto

---

## 1. TUJUAN PRAKTIKUM
Tujuan dari praktikum ini adalah mendemonstrasikan integrasi perangkat keras (hardware) kamera, galeri foto, serta sistem notifikasi lokal pada platform mobile menggunakan framework Flutter. Mahasiswa diharapkan memahami:
* Penggunaan package `camera` untuk membuat tampilan tangkapan kamera kustom (*custom camera preview*).
* Penggunaan package `image_picker` untuk memilih gambar dari galeri penyimpanan eksternal perangkat.
* Penggunaan package `flutter_local_notifications` untuk menjadwalkan dan menampilkan notifikasi lokal instan ke sistem operasi Android/iOS.
* Manajemen status (*state management*) sederhana dan penanganan siklus hidup (*lifecycle state*) dari kontroler kamera.

---

## 2. STRUKTUR PROYEK
Proyek ini diatur dengan struktur folder standar Flutter sebagai berikut:
```text
Pertemuan 12/
├── Screenshot/
│   └── halaman utama.png
└── sourcecode/
    ├── android/
    ├── ios/
    ├── lib/
    │   └── main.dart
    ├── pubspec.yaml
    └── ...
```

---

## 3. DEPENDENSI DAN KONFIGURASI
Aplikasi ini memanfaatkan tiga dependensi utama yang dikonfigurasi pada file `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  camera: ^0.12.0+1
  flutter_local_notifications: ^21.0.0
  image_picker: ^1.2.2
```

### Penjelasan Package:
1. **`camera`**: Digunakan untuk mengakses sensor kamera perangkat fisik, menampilkan feed kamera secara realtime melalui widget `CameraPreview`, dan menangkap gambar (*take picture*).
2. **`flutter_local_notifications`**: Menyediakan abstraksi lintas platform untuk menampilkan notifikasi lokal pada area status bar perangkat dengan kustomisasi suara, ikon, dan prioritas.
3. **`image_picker`**: Membuka galeri bawaan sistem operasi agar pengguna dapat memilih dokumen gambar yang sudah ada.

---

## 4. PENJELASAN IMPLEMENTASI SOURCE CODE (`lib/main.dart`)

Implementasi kode program dalam file `lib/main.dart` dibagi menjadi beberapa bagian utama:

### A. Inisialisasi Aplikasi (`main`)
Fungsi `main` dijalankan secara asinkron (`async`) untuk menjamin semua binding Flutter dan konfigurasi notifikasi telah siap sebelum widget UI dirender.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pengaturan ikon notifikasi khusus Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Inisialisasi plugin notifikasi
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  // Request izin notifikasi khusus perangkat Android terbaru
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  await androidPlugin?.requestNotificationsPermission();

  runApp(const MyApp());
}
```
* **`WidgetsFlutterBinding.ensureInitialized()`**: Wajib dipanggil sebelum inisialisasi plugin pihak ketiga untuk memastikan channel komunikasi engine Flutter telah terhubung.
* **`AndroidInitializationSettings('@mipmap/ic_launcher')`**: Mengatur ikon default yang akan ditampilkan saat notifikasi masuk.
* **`requestNotificationsPermission()`**: Memunculkan dialog permohonan izin notifikasi secara dinamis pada runtime untuk Android 13+.

---

### B. Halaman Utama (`HomePage` & `_HomePageState`)
Mengelola layout utama aplikasi serta logika penjembatanan antara UI dengan fungsionalitas notifikasi dan pemilih gambar.

#### 1. Menampilkan Notifikasi (`_showNotification`)
Metode ini bertugas mengonfigurasi detail notifikasi (seperti ID unik, judul, isi pesan, tingkat urgensi) sebelum mengirimkannya ke sistem operasi.
```dart
Future<void> _showNotification(String title, String message) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'kamera_notif_channel',
        'Notifikasi Praktikum 12',
        channelDescription: 'Notifikasi pengambilan foto',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: DateTime.now().millisecond,
    title: title,
    body: message,
    notificationDetails: platformDetails,
  );
}
```
* **`Importance.max` dan `Priority.high`**: Memastikan notifikasi muncul di bagian atas layar sebagai heads-up banner dengan suara bawaan perangkat.

#### 2. Mengambil Foto Lewat Kamera (`_takePhotoWithCamera`)
Membuka layar kamera kustom (`CameraScreen`) dan menunggu kembalian berupa path lokasi penyimpanan foto hasil tangkapan.
```dart
Future<void> _takePhotoWithCamera() async {
  final String? imagePath = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CameraScreen()),
  );

  if (imagePath != null) {
    setState(() => _imageFile = File(imagePath));
    await _showNotification(
      'Foto Berhasil Diambil',
      'Foto berhasil ditangkap melalui kamera perangkat.',
    );
  }
}
```

#### 3. Memilih Foto dari Galeri (`_pickPhotoFromGallery`)
Membuka galeri internal perangkat dengan memanfaatkan instansiasi dari kelas `ImagePicker`.
```dart
Future<void> _pickPhotoFromGallery() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _showNotification(
        'Foto Berhasil Dipilih',
        'Foto berhasil dipilih dari galeri penyimpanan.',
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
  }
}
```
* **`mounted` check**: Digunakan sebelum pemanggilan `ScaffoldMessenger` untuk memastikan widget masih berada dalam tree dan menghindari *memory leaks* atau *build context crash* jika aksi dibatalkan di tengah jalan.

---

### C. Layar Kamera Kustom (`CameraScreen` & `_CameraScreenState`)
Kelas ini bertugas mengontrol sensor kamera secara langsung dan merender pratampilan kamera (*camera preview*).

#### 1. Inisialisasi Kamera (`_setupCameras`)
Mengambil daftar kamera yang tersedia di perangkat dan menghubungkannya dengan `CameraController`.
```dart
Future<void> _setupCameras() async {
  try {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = 'Tidak ditemukan kamera pada perangkat ini.';
      });
      return;
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    await _initializeControllerFuture;

    if (mounted) setState(() => _isCameraReady = true);
  } catch (e) {
    setState(() => _errorMessage = 'Gagal menginisialisasi kamera: $e');
  }
}
```
* **`availableCameras()`**: Mengembalikan list perangkat keras kamera yang terdeteksi (seperti kamera depan dan belakang).
* **`CameraController`**: Objek yang mengendalikan pembukaan lensa, fokus, flash, dan penangkapan gambar.
* **`ResolutionPreset.medium`**: Mengatur resolusi pratinjau kamera pada resolusi menengah agar hemat memori.

#### 2. Siklus Hidup dan Dispose
Sangat penting untuk melepaskan objek kontroler kamera dari memori saat layar ditutup agar tidak membebani performa perangkat keras.
```dart
@override
void dispose() {
  _controller?.dispose();
  super.dispose();
}
```

#### 3. Penangkapan Gambar (`_capturePhoto`)
Menjalankan fungsi snapshot dari library kamera dan mengembalikan path file lokal kembali ke halaman sebelumnya.
```dart
Future<void> _capturePhoto() async {
  if (_controller == null || !_isCameraReady) return;
  try {
    await _initializeControllerFuture;
    final XFile image = await _controller!.takePicture();
    if (mounted) Navigator.pop(context, image.path);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
  }
}
```

---

## 5. DEMO DAN HASIL EKSEKUSI (SCREENSHOT)
Berikut adalah visualisasi antarmuka utama aplikasi praktikum yang telah berhasil dirancang dan dijalankan:

### Halaman Utama
![Halaman Utama](Screenshot/halaman%20utama.png)

*Antarmuka menampilkan kartu identitas mahasiswa, area penampung pratampilan foto (sebelum/setelah diambil), tombol aksi "Ambil Foto" dan "Galeri", serta tombol shortcut notifikasi manual pada pojok kanan atas.*

---

## 6. LANGKAH MENJALANKAN PROYEK
Untuk menjalankan proyek ini secara lokal, lakukan langkah-langkah berikut:

1. Buka terminal pada direktori root proyek (`sourcecode`):
   ```bash
   cd sourcecode
   ```
2. Pastikan dependensi terpasang lengkap:
   ```bash
   flutter pub get
   ```
3. Hubungkan perangkat emulator Android/iOS atau perangkat fisik dengan fitur *debugging USB* yang aktif.
4. Jalankan aplikasi menggunakan perintah:
   ```bash
   flutter run
   ```
5. Berikan izin saat aplikasi meminta akses kamera dan pengiriman notifikasi pada sistem operasi Anda.
=======
# Pertemuan-12-Mobile Modul 8-9
# TUGAS PRAKTIKUM
# Notifikasi & API Perangkat Keras
## Buat aplikasi Flutter sederhana dengan fitur berikut:
### 1. Ambil Foto
Tampilkan 2 tombol di halaman utama:
• Tombol pertama → buka kamera langsung (Camera API)
• Tombol kedua → pilih foto dari galeri (image_picker)
Foto yang diambil/dipilih ditampilkan di halaman yang sama.

### 2. Notifikasi
Setelah foto berhasil diambil atau dipilih, tampilkan notifikasi lokal menggunakan flutter_local_notifications dengan isi pesan bebas.

## Output yang dikumpulkan  meliputi :
- Screenshot hasilnya
- Source code
- Penjelasan singkat tiap widget
### Pengumpulan cukup up Folder Nama - NIM Isi folder: - Folder Source Code - Folder SS - PDF (Penjelasan dari source code)
>>>>>>> origin/main
