import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Capture',
      theme: ThemeData(
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
  final ImagePicker picker = ImagePicker();

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  File? imageFile;

  String fileName = "";
  String lastAction = "";

  @override
  void initState() {
    super.initState();
    initializeNotification();
  }

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings);

    final androidPlugin =
        notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'photo_channel',
      'Photo Notification',
      channelDescription: 'Notification Photo',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      0,
      'Photo Capture',
      message,
      details,
    );
  }

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> openCamera() async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
        fileName = photo.name;
        lastAction = "Diambil dari Kamera";
      });

      await showNotification(
        "Foto berhasil diambil",
      );

      showSnack(
        "Foto berhasil diambil",
      );
    }
  }

  Future<void> openGallery() async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        imageFile = File(photo.path);
        fileName = photo.name;
        lastAction = "Dipilih dari Galeri";
      });

      await showNotification(
        "Foto berhasil dipilih",
      );

      showSnack(
        "Foto berhasil dipilih",
      );
    }
  }

  Widget menuButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  const Color(0xff6D5DF6),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        GoogleFonts.poppins(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff081120),
              Color(0xff16243D),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                          24),
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(30),
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xff4F46E5),
                        Color(0xff8B5CF6),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 70,
                        color:
                            Colors.white,
                      ),
                      const SizedBox(
                          height: 10),
                      Text(
                        "Photo Capture",
                        style:
                            GoogleFonts
                                .poppins(
                          color:
                              Colors.white,
                          fontSize: 30,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Text(
                        "Dsharlendita Febianda Aurelia",
                        textAlign:
                            TextAlign.center,
                        style:
                            GoogleFonts
                                .poppins(
                          color:
                              Colors.white70,
                        ),
                      ),
                      Text(
                        "2311102069",
                        style:
                            GoogleFonts
                                .poppins(
                          color:
                              Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                menuButton(
                  title: "Ambil Foto",
                  subtitle:
                      "Gunakan kamera perangkat",
                  icon: Icons.camera_alt,
                  onTap: openCamera,
                ),

                const SizedBox(height: 14),

                menuButton(
                  title:
                      "Pilih dari Galeri",
                  subtitle:
                      "Pilih foto dari galeri",
                  icon:
                      Icons.photo_library,
                  onTap: openGallery,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(
                      Icons.image,
                      color:
                          Colors.deepPurpleAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Preview Foto",
                      style:
                          GoogleFonts
                              .poppins(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  height: 250,
                  width: double.infinity,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius
                            .circular(24),
                    border: Border.all(
                      color:
                          Colors.white24,
                    ),
                  ),
                  child: imageFile == null
                      ? Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            const Icon(
                              Icons
                                  .image_outlined,
                              size: 70,
                              color:
                                  Colors.white38,
                            ),
                            const SizedBox(
                                height: 10),
                            Text(
                              "Belum Ada Foto",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color: Colors
                                    .white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            Text(
                              "Ambil foto atau pilih galeri",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color: Colors
                                    .white54,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      24),
                          child: InteractiveViewer(
                            child: Image.file(
                              imageFile!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                ),

                if (imageFile != null) ...[
                  const SizedBox(
                      height: 16),
                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .all(12),
                    decoration:
                        BoxDecoration(
                      color: Colors
                          .green
                          .withOpacity(
                              0.15),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .check_circle,
                              color: Colors
                                  .greenAccent,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Foto Berhasil Dimuat",
                              style: TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 8),
                        Text(
                          fileName,
                          textAlign:
                              TextAlign.center,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              GoogleFonts
                                  .poppins(
                            color:
                                Colors.white70,
                          ),
                        ),
                        const SizedBox(
                            height: 4),
                        Text(
                          lastAction,
                          textAlign:
                              TextAlign.center,
                          style:
                              GoogleFonts
                                  .poppins(
                            color:
                                Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}