import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inisialisasi plugin notifikasi
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Setting untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setting gabungan
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tap pada notifikasi
        print('Notifikasi di-tap: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  /// Minta izin notifikasi (Android 13+)
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Tampilkan notifikasi setelah foto diambil dari kamera
  Future<void> showFotoKameraNotification() async {
    await _ensureInitialized();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'foto_channel',
      'Notifikasi Foto',
      channelDescription: 'Notifikasi setelah mengambil atau memilih foto',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Foto berhasil',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      1,
      '📸 Foto Berhasil Diambil!',
      'Kamera berhasil mengambil foto. Foto ditampilkan di layar.',
      notificationDetails,
      payload: 'kamera',
    );
  }

  /// Tampilkan notifikasi setelah foto dipilih dari galeri
  Future<void> showFotoGaleriNotification() async {
    await _ensureInitialized();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'foto_channel',
      'Notifikasi Foto',
      channelDescription: 'Notifikasi setelah mengambil atau memilih foto',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Foto dipilih',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      2,
      '🖼️ Foto Berhasil Dipilih!',
      'Foto dari galeri berhasil dipilih dan ditampilkan.',
      notificationDetails,
      payload: 'galeri',
    );
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
