import 'dart:typed_data'; // <--- Library tambahan untuk membaca bytes memori di Web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi otomatis jika di-run di Web
import '../services/notification_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  XFile? _pickedFile; // Menggunakan XFile (Aman untuk Mobile maupun Web)
  Uint8List? _webImage; // Menyimpan data gambar dalam bentuk bytes khusus untuk Chrome
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _fileInfo = "Status: Menunggu kiriman media baru...";

  Future<bool> _requestPermission(Permission permission) async {
    // Di Web/Chrome, izin runtime tidak perlu dicek lewat permission_handler karena diatur otomatis oleh browser
    if (kIsWeb) return true; 

    final status = await permission.status;
    if (status.isGranted) return true;
    
    final result = await permission.request();
    return result.isGranted;
  }

  Future<void> _processMedia(ImageSource source, String sourceName) async {
    setState(() => _isProcessing = true);

    try {
      bool hasPermission = await _requestPermission(
        source == ImageSource.camera ? Permission.camera : Permission.photos
      );

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Akses $sourceName ditolak oleh sistem.")),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Ambil berkas gambar
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85);

      if (pickedFile != null) {
        // Ambil data ukuran & waktu
        final int fileSizeInBytes = await pickedFile.length();
        final double fileSizeInKB = fileSizeInBytes / 1024;
        final String timestamp = DateFormat('HH:mm:ss WIB').format(DateTime.now());

        // BACA SEBAGAI BYTES (Ini Kunci Rahasia Biar Bisa Muncul di Chrome!)
        final Uint8List imageBytes = await pickedFile.readAsBytes();

        setState(() {
          _pickedFile = pickedFile;
          _webImage = imageBytes;
          _fileInfo = "INFO BERKAS:\n• Nama: ${pickedFile.name.substring(0, pickedFile.name.length > 20 ? 20 : pickedFile.name.length)}...\n• Ukuran: ${fileSizeInKB.toStringAsFixed(2)} KB\n• Jam Sinkron: $timestamp";
        });

        // Catatan: Flutter Local Notifications belum mendukung platform Web Browser secara native.
        // Jadi fungsi notifikasi kita bypass/lewati agar aplikasi tidak crash di Chrome.
        if (!kIsWeb) {
          await NotificationManager().showMediaNotification(
            sourceTitle: sourceName,
            detailTime: timestamp,
          );
        } else {
          // Opsional: Memunculkan snackbar di Chrome sebagai pengganti tanda notifikasi sukses
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFFFFB703),
                content: Text('✨ Berkas Masuk! ($sourceName) pada jam $timestamp', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error capture: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAPTURE & NOTIFY v2', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F1135), Color(0xFF0B0416)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. IMAGE PREVIEW BOX (Mendukung Web & Mobile)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: _isProcessing
                          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                          : _webImage != null
                              ? Image.memory(_webImage!, fit: BoxFit.cover) // <--- Menggunakan Image.memory untuk Chrome!
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome_mosaic_outlined, size: 72, color: Colors.white24),
                                    SizedBox(height: 16),
                                    Text('Belum Ada Gambar Terpilih', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. METADATA CARD VIEW
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    _fileInfo,
                    style: const TextStyle(color: Colors.amberAccent, fontFamily: 'monospace', fontSize: 12, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. VERTICAL BUTTON ACTIONS
                ElevatedButton.icon(
                  onPressed: () => _processMedia(ImageSource.camera, "Kamera Utama"),
                  icon: const Icon(Icons.photo_camera_front_rounded, size: 22),
                  label: const Text('BUKA AKSES KAMERA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 14),
                
                OutlinedButton.icon(
                  onPressed: () => _processMedia(ImageSource.gallery, "Galeri Sistem"),
                  icon: const Icon(Icons.collections_bookmark_rounded, size: 22),
                  label: const Text('JELAJAHI FILE GALERI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                if (_webImage != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _pickedFile = null;
                        _webImage = null;
                        _fileInfo = "Status: Menunggu kiriman media baru...";
                      });
                    },
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                    label: const Text('Kosongkan Tampilan', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}