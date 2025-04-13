import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;
  // Form field controller
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final selectedType = "income".obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.currentUser;
    listenToTransactionSummary();
  }

  void listenToTransactionSummary() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('transactions')
        .snapshots()
        .listen((snapshot) {
          double income = 0;
          double expense = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final type = data['type'];
            final amount = (data['amount'] ?? 0).toDouble();

            if (type == 'income') {
              income += amount;
            } else {
              expense += amount;
            }
          }

          totalIncome.value = income;
          totalExpense.value = expense;
        });
  }

  void submitTransaction() async {
    final title = titleController.text;
    final amount = double.tryParse(amountController.text);
    final type = selectedType.value;

    if (title.isEmpty || amount == null) {
      Get.snackbar("Error", "Judul dan jumlah harus diisi dengan benar.");
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('transactions')
          .add({
            'title': title,
            'amount': amount,
            'type': type,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Reset form
      titleController.clear();
      amountController.clear();
      selectedType.value = "income";

      Get.snackbar(
        "Berhasil",
        "Transaksi berhasil disimpan!",
        // snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 2),
        animationDuration: Duration(milliseconds: 400),
      );
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: $e");
    }
  }

  void confirmDeleteTransaction(String docId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Hapus Transaksi?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Apakah kamu yakin ingin menghapus transaksi ini? Tindakan ini tidak bisa dibatalkan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text("Batal")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      Get.back(); // Tutup dialog
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('transactions')
                            .doc(docId)
                            .delete();
                        Get.snackbar("Berhasil", "Transaksi dihapus");
                      } catch (e) {
                        Get.snackbar("Gagal", "Error: $e");
                      }
                    },
                    child: Text("Hapus"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditTransactionDialog(String docId, Map<String, dynamic> data) {
    titleController.text = data['title'] ?? '';
    amountController.text = data['amount'].toString();
    selectedType.value = data['type'] ?? 'income';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 36,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Edit Transaksi",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),

                // Input Nama Transaksi
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Nama Transaksi",
                    prefixIcon: Icon(Icons.text_fields_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Jumlah
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Jumlah (Rp)",
                    prefixIcon: Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pilihan Tipe Transaksi
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: "income",
                            groupValue: selectedType.value,
                            onChanged: (val) => selectedType.value = val!,
                            activeColor: Colors.green,
                            title: Row(
                              children: [
                                // Icon(Icons.arrow_downward, color: Colors.green),
                                // const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "Income",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: "expense",
                            groupValue: selectedType.value,
                            onChanged: (val) => selectedType.value = val!,
                            activeColor: Colors.red,
                            title: Row(
                              children: [
                                // Icon(Icons.arrow_upward, color: Colors.red),
                                // const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "Expense",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.cancel_outlined),
                      label: Text("Batal"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save_rounded, color: Colors.white),
                      label: Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(
                          amountController.text.trim(),
                        );
                        final type = selectedType.value;

                        if (title.isEmpty || amount == null) {
                          Get.snackbar(
                            "Error",
                            "Judul dan jumlah wajib diisi.",
                          );
                          return;
                        }

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('transactions')
                              .doc(docId)
                              .update({
                                'title': title,
                                'amount': amount,
                                'type': type,
                              });
                          Get.back();
                          Get.snackbar(
                            "Berhasil",
                            "Transaksi berhasil diperbarui.",
                            duration: Duration(seconds: 2),
                          );
                        } catch (e) {
                          Get.snackbar("Gagal", "Terjadi kesalahan: $e");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> getTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/auth');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void clearForm() {
    titleController.clear();
    amountController.clear();
    selectedType.value = "income";
  }
}
