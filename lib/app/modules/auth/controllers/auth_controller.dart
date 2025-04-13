import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Rxn<User> firebaseUser = Rxn<User>();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.reload();
      Get.snackbar("Sukses", "Akun berhasil dibuat");

      Get.offAllNamed('/home'); // Navigasi ke home setelah sign up
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Terjadi kesalahan");
    }
  }

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  Future<void> signInWithGoogle() async {
    try {
      // Membuat instance baru GoogleSignIn setiap kali
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Memaksa memilih akun setiap kali
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar("Batal", "Login dibatalkan");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Get.offAllNamed('/home'); // Navigasi ke halaman utama
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Terjadi kesalahan");
    }
  }

  // Future<void> signInWithGoogle() async {
  //   try {

  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return; // Cancel login

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await _auth.signInWithCredential(credential);
  //     Get.offAllNamed('/home');
  //   } catch (e) {
  //     Get.snackbar("Login Error", e.toString());
  //   }
  // }

  // Login dengan email & password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan password wajib diisi",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Get.snackbar(
        "Berhasil",
        "Login berhasil!",
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      // Arahkan ke halaman home atau dashboard
      Get.offAllNamed('/home'); // Sesuaikan dengan route kamu
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Gagal Login",
        e.message ?? "Terjadi kesalahan",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed('/auth');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
