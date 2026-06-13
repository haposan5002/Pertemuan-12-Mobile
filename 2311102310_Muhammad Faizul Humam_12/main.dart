import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Modul 8-9',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HalamanUtamaTugas(),
    );
  }
}

class HalamanUtamaTugas extends StatefulWidget {
  const HalamanUtamaTugas({super.key});

  @override
  State<HalamanUtamaTugas> createState() => _HalamanUtamaTugasState();
}

class _HalamanUtamaTugasState extends State<HalamanUtamaTugas> {
  Uint8List? _bytesGambar;
  CameraController? _cameraController;
  List<CameraDescription>? _listKamera;
  bool _isKameraAktif = false;

  final ImagePicker _picker = ImagePicker();

  void _tampilkanNotifikasiWeb(String judul, String isiPesan) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.amberAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(isiPesan, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.teal.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _aktifkanWebcam() async {
    try {
      _listKamera = await availableCameras();
      
      if (_listKamera != null && _listKamera!.isNotEmpty) {
        _cameraController = CameraController(
          _listKamera![0],
          ResolutionPreset.medium,
        );

        await _cameraController!.initialize();
        setState(() {
          _isKameraAktif = true;
          _bytesGambar = null; 
        });
        
        _tampilkanNotifikasiWeb("Kamera Aktif! 📷", "Silakan klik tombol 'Ambil Foto' di bawah layar.");
      } else {
        _tampilkanNotifikasiWeb("Kamera Tidak Ada", "Perangkat kamera tidak ditemukan.");
      }
    } catch (e) {
      _tampilkanNotifikasiWeb("Akses Ditolak", "Harap izinkan akses.");
    }
  }

  Future<void> _tangkapFotoWebcam() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile foto = await _cameraController!.takePicture();
      final Uint8List bytes = await foto.readAsBytes();

      setState(() {
        _bytesGambar = bytes;
        _isKameraAktif = false; 
      });

      await _cameraController?.dispose();
      _cameraController = null;

      _tampilkanNotifikasiWeb(
        "Foto Berhasil Diambil! 📸", 
        "Gambar sukses ditangkap."
      );
    }
  }

  Future<void> _pilihFotoDariGaleri() async {
    if (_isKameraAktif) {
      await _cameraController?.dispose();
      _cameraController = null;
      _isKameraAktif = false;
    }

    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery);

    if (foto != null) {
      final Uint8List bytes = await foto.readAsBytes();
      setState(() {
        _bytesGambar = bytes;
      });
      _tampilkanNotifikasiWeb(
        "File Berhasil Dipilih! 🖼️", 
        "Gambar sukses diunggah dari penyimpanan lokal."
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Modul 8-9'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Area Pratinjau (Kamera / Gambar):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.teal.shade300, width: 2),
                ),
                child: _isKameraAktif && _cameraController != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: CameraPreview(_cameraController!),
                      )
                    : _bytesGambar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.memory(
                              _bytesGambar!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_camera_back, size: 60, color: Colors.grey),
                                SizedBox(height: 10),
                                Text('Kamera mati / Belum ada gambar', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 30),

              _isKameraAktif
                  ? ElevatedButton.icon(
                      onPressed: _tangkapFotoWebcam,
                      icon: const Icon(Icons.circle),
                      label: const Text('Ambil Foto Sekarang (Capture)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _aktifkanWebcam,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Buka Kamera'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: _pilihFotoDariGaleri,
                icon: const Icon(Icons.folder_open),
                label: const Text('Pilih Gambar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.teal, width: 2),
                  foregroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}