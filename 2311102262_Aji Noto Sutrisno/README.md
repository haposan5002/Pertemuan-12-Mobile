# 📱 Praktikum 12 — Kamera & Notifikasi

Aplikasi Flutter sederhana untuk praktikum mata kuliah Pengembangan Aplikasi Berbasis Platform (ABP) yang mengimplementasikan akses kamera perangkat, pemilihan foto dari galeri, dan notifikasi lokal.

---

##  Identitas Mahasiswa

| Atribut | Keterangan |
|---|---|
| Nama | Aji Noto Sutrisno |
| NIM | 2311102262 |
| Mata Kuliah | Pemrograman Aplikasi Berbasis Platform |
| Pertemuan | Praktikum 12 |

---

##  Fitur

- **Kamera Langsung** — Membuka kamera perangkat menggunakan `camera` package untuk mengambil foto secara real-time
- **Pilih dari Galeri** — Memilih foto dari galeri penyimpanan menggunakan `image_picker` package
- **Preview Foto** — Menampilkan foto yang diambil/dipilih langsung di halaman utama
- **Notifikasi Lokal** — Menampilkan notifikasi lokal setiap kali foto berhasil diambil atau dipilih menggunakan `flutter_local_notifications`
- **Tes Notifikasi Manual** — Tombol di AppBar untuk memicu notifikasi secara manual

---

##  Teknologi & Package

| Package | Versi | Kegunaan |
|---|---|---|
| `camera` | latest | Akses kamera perangkat secara langsung |
| `image_picker` | latest | Memilih foto dari galeri |
| `flutter_local_notifications` | latest | Menampilkan notifikasi lokal |

---

##  Struktur Project

```
lib/
└── main.dart        # Entry point, HomePage, dan CameraScreen
```

---

##  Cara Menjalankan

### Prasyarat

- Flutter SDK (versi stabil terbaru)
- Android Studio / VS Code
- Emulator Android atau perangkat fisik

### Langkah-langkah

1. **Clone atau buka project**
   ```bash
   cd Pertemuan-12-Mobile
   cd 23111102262_Aji Noto Sutrisno
   cd SourceCode
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

##  Izin (Permissions)

Tambahkan izin berikut di `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```



##  Catatan

- Aplikasi hanya mendukung platform **Android**
- Untuk emulator, tambahkan foto ke galeri terlebih dahulu menggunakan:
  ```bash
  adb push foto.jpg /sdcard/Pictures/
  adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/Pictures/
  ```
