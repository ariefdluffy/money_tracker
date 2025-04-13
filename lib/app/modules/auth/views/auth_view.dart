import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:money_tracker/app/modules/auth/views/signup_view.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});

  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background dengan warna biru
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo atau gambar di atas
                CircleAvatar(
                  radius: 60,
                  // backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),

                // Judul login dengan teks yang lebih besar dan bold
                Text(
                  "Login Money Tracker",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Email
                TextField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passwordC,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      authC.loginWithEmail(
                        email: emailC.text.trim(),
                        password: passwordC.text,
                      );
                    },
                    // icon: Icon(Icons.login),
                    label: Text(
                      "Masuk",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Belum punya akun?
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUpView(),
                      ), // Ganti sesuai halaman kamu
                    );
                  },
                  child: Text(
                    "Belum punya akun? Daftar",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),

                // Tombol login dengan Google yang lebih modern
                ElevatedButton.icon(
                  onPressed: () => controller.signInWithGoogle(),
                  icon: Icon(Icons.g_mobiledata_rounded),
                  label: Text(
                    "SignIn/SignUp with Google",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Tombol dengan warna yang menarik
                    minimumSize: Size(
                      double.infinity,
                      50,
                    ), // Tombol memenuhi lebar
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ), // Sudut tombol yang melengkung
                    ),
                    elevation: 5,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
