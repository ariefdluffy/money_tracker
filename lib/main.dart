import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Money Tracker",
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
    );
  }

  // Fungsi untuk memeriksa status login dan menentukan rute awal
  String _getInitialRoute() {
    // Cek status login saat aplikasi pertama kali dibuka
    User? user = FirebaseAuth.instance.currentUser;

    // Jika sudah login, arahkan ke halaman utama, jika belum login arahkan ke login
    return user != null ? '/home' : '/auth';
  }
}
