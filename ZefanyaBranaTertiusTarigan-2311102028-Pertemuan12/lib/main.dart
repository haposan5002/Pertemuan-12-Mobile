import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(const MyApp());
}

Future<void> showLocalNotification(String message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'foto_channel',
    'Notifikasi Foto',
    channelDescription: 'Notifikasi setelah mengambil atau memilih foto',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: 1,
    title: 'Berhasil',
    body: message,
    notificationDetails: notificationDetails,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kamera dan Notifikasi',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedImage;

  Future<void> openCameraPage() async {
    final String? imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );

    if (imagePath != null) {
      setState(() {
        selectedImage = File(imagePath);
      });

      await showLocalNotification('Foto berhasil diambil dari kamera.');
    }
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });

      await showLocalNotification('Foto berhasil dipilih dari galeri.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum Kamera & Notifikasi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Aplikasi Kamera dan Galeri',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: openCameraPage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil Foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pilih Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: selectedImage == null
                    ? const Center(
                        child: Text(
                          'Belum ada foto yang dipilih',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? cameraController;
  Future<void>? initializeControllerFuture;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          errorMessage = 'Kamera tidak ditemukan di perangkat ini.';
        });
        return;
      }

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      initializeControllerFuture = cameraController!.initialize();

      setState(() {});
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal membuka kamera: $e';
      });
    }
  }

  Future<void> takePicture() async {
    try {
      await initializeControllerFuture;

      final XFile photo = await cameraController!.takePicture();

      if (!mounted) return;

      Navigator.pop(context, photo.path);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kamera'),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (cameraController == null || initializeControllerFuture == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kamera'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Foto'),
      ),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox.expand(
                  child: CameraPreview(cameraController!),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: takePicture,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}