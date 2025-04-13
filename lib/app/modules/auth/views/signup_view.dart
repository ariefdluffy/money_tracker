import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money_tracker/app/modules/auth/views/auth_view.dart';
import '../controllers/auth_controller.dart';

class SignUpView extends StatelessWidget {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();
  final authC = Get.find<AuthController>();

  SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Akun")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nama
            TextField(
              controller: nameC,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordC,
              decoration: InputDecoration(
                labelText: "Konfirmasi Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),

            // Tombol Daftar
            ElevatedButton.icon(
              onPressed: () {
                final name = nameC.text.trim();
                final email = emailC.text.trim();
                final password = passwordC.text;
                final confirmPassword = confirmPasswordC.text;

                if (name.isEmpty ||
                    email.isEmpty ||
                    password.isEmpty ||
                    confirmPassword.isEmpty) {
                  Get.snackbar("Error", "Semua field harus diisi");
                  return;
                }

                if (password != confirmPassword) {
                  Get.snackbar("Error", "Password tidak sama");
                  return;
                }

                authC.signUp(
                  name: nameC.text.trim(),
                  email: emailC.text.trim(),
                  password: passwordC.text,
                );
              },
              icon: Icon(Icons.app_registration),
              label: Text(
                "Daftar",
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
            const SizedBox(height: 16),
            Divider(),
            // Sudah punya akun?
            TextButton(
              onPressed: () {
                Get.offAllNamed('/auth');
              },
              child: Text(
                "Sudah punya akun? Klik Login",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
