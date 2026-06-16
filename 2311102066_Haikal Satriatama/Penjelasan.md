Penjelasan Singkat Program 
Aplikasi ini dibuat menggunakan Flutter dengan fitur mengambil foto dari kamera, 
memilih foto dari galeri, menampilkan foto yang dipilih, dan memberikan notifikasi lokal 
setelah foto berhasil dipilih atau diambil. 
Penjelasan Widget 
1. MaterialApp 
Digunakan sebagai widget utama aplikasi untuk mengatur tema, judul aplikasi, dan 
halaman awal yang ditampilkan. 
2. Scaffold 
Digunakan sebagai kerangka dasar halaman yang terdiri dari AppBar dan Body. 
3. AppBar 
Menampilkan judul aplikasi yaitu "Notifikasi & API Perangkat Keras". 
4. Column 
Digunakan untuk menyusun widget secara vertikal pada halaman. 
5. Padding 
Memberikan jarak antara isi halaman dengan tepi layar agar tampilan lebih rapi. 
6. ElevatedButton.icon 
Digunakan untuk membuat tombol beserta ikon. Terdapat dua tombol yaitu: 
• Ambil Foto Kamera  
• Pilih Dari Galeri  
7. Icon 
Menampilkan ikon kamera dan galeri pada tombol. 
8. Text 
Digunakan untuk menampilkan tulisan seperti judul tombol dan pesan "Belum ada 
foto". 
9. SizedBox 
Memberikan jarak antar widget agar tampilan lebih teratur. 
10. Image.file 
Digunakan untuk menampilkan foto yang berhasil diambil dari kamera atau dipilih dari 
galeri. 
Penjelasan Package 
1. image_picker 
Digunakan untuk mengakses kamera dan galeri perangkat sehingga pengguna dapat 
mengambil atau memilih foto. 
2. flutter_local_notifications 
Digunakan untuk menampilkan notifikasi lokal ketika foto berhasil diambil atau dipilih. 
Alur Kerja Program 
1. Pengguna membuka aplikasi.  
2. Pengguna memilih tombol "Ambil Foto Kamera" atau "Pilih Dari Galeri".  
3. Foto diproses menggunakan package image_picker.  
4. Foto ditampilkan pada halaman aplikasi.  
5. Sistem menampilkan notifikasi lokal menggunakan flutter_local_notifications.  
6. Proses selesai. 