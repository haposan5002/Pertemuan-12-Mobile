# Camera & Local Notifications App

Aplikasi Flutter sederhana yang mendemonstrasikan cara berinteraksi dengan hardware kamera, mengakses galeri foto menggunakan package `image_picker`, serta memicu notifikasi sistem lokal menggunakan `flutter_local_notifications`.

---

## 🛠️ Penjelasan Singkat Tiap Widget

Aplikasi ini dibangun menggunakan kombinasi beberapa widget bawaan Flutter untuk menyusun struktur, tata letak (layout), dan tampilan visual:

### 1. Widget Struktur & Navigasi Utama
* **`MyApp` (StatelessWidget)**: Widget akar (root) dari seluruh aplikasi. Di sini kita mengatur tema global aplikasi dan menentukan halaman pertama yang akan dibuka (`HomeScreen`).
* **`MaterialApp`**: Widget utama yang membungkus seluruh aplikasi untuk mengaktifkan desain standar Android (Material Design), sistem navigasi, dan konfigurasi tema.
* **`HomeScreen` (StatefulWidget)**: Halaman utama aplikasi. Menggunakan `StatefulWidget` karena tampilan layar perlu berubah secara dinamis (me-refresh diri) ketika foto berhasil diambil atau dipilih.
* **`Scaffold`**: Menyediakan struktur dasar halaman Android, seperti area untuk menaruh `AppBar` di bagian atas dan `body` untuk konten utama.
* **`AppBar`**: Batang aplikasi di bagian atas layar yang berfungsi untuk menampilkan judul proyek ("Aplikasi Foto & Notifikasi").

### 2. Widget Tata Letak (Layout & Spacing)
* **`Padding`**: Memberikan jarak pembatas (margin/space) sebesar `16.0` di semua sisi agar konten aplikasi tidak mepet ke pinggir layar HP.
* **`Column`**: Menyusun komponen secara **vertikal** (dari atas ke bawah). Di aplikasi ini, `Column` memisahkan area tampilan foto (di atas) dan barisan tombol (di bawah).
* **`Row`**: Menyusun komponen secara **horizontal** (dari kiri ke kanan). Digunakan untuk menaruh tombol "Buka Kamera" dan "Dari Galeri" secara berdampingan.
* **`Expanded`**: Memaksa widget anak (dalam hal ini area foto) untuk mengambil semua sisa ruang vertikal yang tersedia, sehingga tampilan aplikasi menjadi proporsional di berbagai ukuran layar HP.
* **`SizedBox`**: Widget "kotak kosong" yang digunakan khusus untuk memberikan jarak/jeda *padding* (tinggi atau lebar) antar widget agar tidak saling menempel.

### 3. Widget Tampilan Konten & Dekorasi
* **`Center`**: Memastikan objek di dalamnya (foto atau ikon placeholder) berada tepat di tengah-tengah area yang tersedia.
* **`Container`**: Kotak dekorasi serbaguna. Digunakan sebagai wadah abu-abu (*placeholder*) saat aplikasi baru dibuka dan belum ada foto yang dipilih.
* **`Icon`**: Menampilkan grafis ikon statis bawaan Flutter (seperti ikon gambar `Icons.image` dan ikon kamera `Icons.camera_alt`).
* **`ClipRRect` (Clip Rounded Rectangle)**: Memotong sudut tajam dari foto yang ditampilkan agar melengkung halus (`BorderRadius.circular(12)`) supaya estetik.
* **`Image.file`**: Widget khusus untuk membaca dan menampilkan file gambar yang berasal dari penyimpanan lokal HP berdasarkan jalur *path* yang didapatkan dari `image_picker`.

### 4. Widget Interaksi (Tombol)
* **`ElevatedButton.icon`**: Tombol modern dengan efek bayangan (timbul) yang sudah dilengkapi dengan slot ikon dan teks sekaligus. Digunakan untuk tombol pemicu Kamera dan Galeri.

---

## 📦 Package yang Digunakan 

* **`image_picker`**: Berperan langsung untuk menjembatani kode Dart ke Camera API bawaan perangkat dan sistem galeri foto.
* **`flutter_local_notifications`**: Mengurus pembuatan jalur (*channel*) notifikasi ke sistem operasi dan memicu munculnya *banner* notifikasi di HP saat foto berhasil dimuat.