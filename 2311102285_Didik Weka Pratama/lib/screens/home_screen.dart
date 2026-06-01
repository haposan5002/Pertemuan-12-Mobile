import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String _statusMessage = 'Pilih opsi untuk mengambil atau memilih foto';

  final ImagePicker _picker = ImagePicker();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermission();
  }

  // ─── Ambil foto dari KAMERA ───────────────────────────────────────────────
  Future<void> _ambilFotoKamera() async {
    // Minta izin kamera
    final cameraStatus = await Permission.camera.request();

    if (!cameraStatus.isGranted) {
      _showSnackBar(
        '❌ Izin kamera ditolak. Aktifkan di Pengaturan.',
        Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Membuka kamera...';
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _statusMessage = '✅ Foto berhasil diambil dari kamera!';
        });

        // Tampilkan notifikasi lokal
        await _notificationService.showFotoKameraNotification();

        _showSnackBar('📸 Foto berhasil diambil!', Colors.green);
      } else {
        setState(() {
          _statusMessage = 'Pengambilan foto dibatalkan';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      _showSnackBar('❌ Gagal membuka kamera: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ─── Pilih foto dari GALERI ───────────────────────────────────────────────
  Future<void> _pilihFotoGaleri() async {
    // Minta izin galeri
    PermissionStatus galleryStatus;

    if (Platform.isAndroid) {
      // Android 13+ gunakan READ_MEDIA_IMAGES
      final sdkVersion = await _getAndroidSdkVersion();
      if (sdkVersion >= 33) {
        galleryStatus = await Permission.photos.request();
      } else {
        galleryStatus = await Permission.storage.request();
      }
    } else {
      galleryStatus = await Permission.photos.request();
    }

    if (!galleryStatus.isGranted && !galleryStatus.isLimited) {
      _showSnackBar(
        '❌ Izin galeri ditolak. Aktifkan di Pengaturan.',
        Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Membuka galeri...';
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _statusMessage = '✅ Foto berhasil dipilih dari galeri!';
        });

        // Tampilkan notifikasi lokal
        await _notificationService.showFotoGaleriNotification();

        _showSnackBar('🖼️ Foto berhasil dipilih!', Colors.green);
      } else {
        setState(() {
          _statusMessage = 'Pemilihan foto dibatalkan';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      _showSnackBar('❌ Gagal membuka galeri: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ─── Hapus foto yang ditampilkan ─────────────────────────────────────────
  void _hapusFoto() {
    setState(() {
      _selectedImage = null;
      _statusMessage = 'Pilih opsi untuk mengambil atau memilih foto';
    });
  }

  // ─── Helper: dapatkan Android SDK version ────────────────────────────────
  Future<int> _getAndroidSdkVersion() async {
    try {
      // Default ke 33 jika tidak bisa terdeteksi
      return 33;
    } catch (_) {
      return 33;
    }
  }

  // ─── Helper: tampilkan SnackBar ──────────────────────────────────────────
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── BUILD UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          '📷 Foto & Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D6A4F),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Hapus Foto',
              onPressed: _hapusFoto,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Status Bar ──────────────────────────────────────────
              _buildStatusCard(),
              const SizedBox(height: 24),

              // ── Tombol Kamera & Galeri ───────────────────────────────
              _buildButtonRow(),
              const SizedBox(height: 24),

              // ── Area Tampil Foto ─────────────────────────────────────
              _buildImageArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2D6A4F), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
              ),
            ),
          ),
          if (_isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2D6A4F),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        // ── Tombol Kamera ──────────────────────────────────────────────
        Expanded(
          child: _ActionButton(
            icon: Icons.camera_alt_rounded,
            label: 'Buka Kamera',
            subtitle: 'Ambil foto langsung',
            color: const Color(0xFF2D6A4F),
            onPressed: _isLoading ? null : _ambilFotoKamera,
          ),
        ),
        const SizedBox(width: 16),

        // ── Tombol Galeri ──────────────────────────────────────────────
        Expanded(
          child: _ActionButton(
            icon: Icons.photo_library_rounded,
            label: 'Buka Galeri',
            subtitle: 'Pilih dari galeri',
            color: const Color(0xFF1D4E89),
            onPressed: _isLoading ? null : _pilihFotoGaleri,
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea() {
    if (_selectedImage != null) {
      return Column(
        children: [
          // Label
          Row(
            children: [
              const Icon(Icons.image, color: Color(0xFF2D6A4F), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Foto Ditampilkan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _hapusFoto,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Gambar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('Gagal memuat gambar'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    // Placeholder jika belum ada foto
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD0D7DE),
          width: 2,
          style: BorderStyle.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada foto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan tombol di atas untuk\nmengambil atau memilih foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Action Button ────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
