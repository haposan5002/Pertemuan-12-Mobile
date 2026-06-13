import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await notificationsPlugin.initialize(initializationSettings);

  // Minta izin notifikasi Android 13+
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Praktikum',
      theme: ThemeData(
        primarySwatch: Colors.red,
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
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'photo_channel',
      'Photo Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      'Foto Berhasil',
      message,
      notificationDetails,
    );
  }

Future<void> openCamera() async {
  final XFile? photo =
      await picker.pickImage(source: ImageSource.camera);

  if (photo != null) {
    setState(() {
      imageFile = File(photo.path);
    });

    await showNotification(
      'Foto berhasil diambil dari kamera',
    );
  }
}

Future<void> openGallery() async {
  final XFile? photo =
      await picker.pickImage(source: ImageSource.gallery);

  if (photo != null) {
    setState(() {
      imageFile = File(photo.path);
    });

    await showNotification(
      'Foto berhasil dipilih dari galeri',
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Kamera dan Galeri'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: openCamera,
              child: const Text('Ambil Foto (Kamera)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: openGallery,
              child: const Text('Pilih Foto (Galeri)'),
            ),
            const SizedBox(height: 20),

            imageFile != null
                ? Image.file(
                    imageFile!,
                    height: 300,
                  )
                : const Text('Belum ada foto'),
          ],
        ),
      ),
    );
  }
}