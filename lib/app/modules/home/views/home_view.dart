import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/app/modules/admob/controllers/admob_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final AdmobController admobController = Get.put(AdmobController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Money Tracker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: "Keluar",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              _buildUserCard(user),
              const SizedBox(height: 10),
            ],

            // Saldo Saat Ini
            _buildBalanceCard(),

            const SizedBox(height: 10),
            Text(
              "Riwayat Transaksi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Menampilkan banner ad di bawah konten transaksi
            admobController.getBannerAdWidget(),

            // Riwayat transaksi
            Expanded(child: _buildTransactionHistory()),
            const SizedBox(height: 34),
          ],
        ),
      ),

      // Tombol Tambah Transaksi
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          onPressed: () => _showTransactionDialog(context),
          label: Text("Tambah"),
          icon: Icon(Icons.add),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Menampilkan kartu pengguna
  // Function to build user profile card
  Widget _buildUserCard(User user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? "No Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  user.email ?? "",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build balance card
  Widget _buildBalanceCard() {
    return Obx(() {
      final saldo =
          controller.totalIncome.value - controller.totalExpense.value;
      return Card(
        color: saldo >= 0 ? Colors.green.shade50 : Colors.red.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saldo Saat Ini",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 6),
              Text(
                "Rp ${NumberFormat('#,###', 'id_ID').format(saldo)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: saldo >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Function to build transaction history
  Widget _buildTransactionHistory() {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: controller.getTransactionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Belum ada data."),
            );
          }

          final transactions = snapshot.data!.docs;

          return ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transactions.length,
            separatorBuilder: (_, __) => SizedBox(height: 4),
            itemBuilder: (context, index) {
              final data = transactions[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final amount = data['amount'] ?? 0;
              final type = data['type'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp?.toDate();

              return _buildTransactionCard(
                data: data,
                title: title,
                amount: amount,
                type: type,
                date: date,
                transactionId: transactions[index].id,
              );
            },
          );
        },
      ),
    );
  }

  // Function to build transaction card
  Widget _buildTransactionCard({
    required Map<String, dynamic> data,
    required String title,
    required double amount,
    required String type,
    required DateTime? date,
    required String transactionId,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => controller.showEditTransactionDialog(transactionId, data),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon for income/expense
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    type == 'income'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                child: Icon(
                  type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: type == 'income' ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),

              // Title and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: type == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount and delete button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}"
                        : "Tanpa tanggal",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.grey[700]),
                    onPressed:
                        () =>
                            controller.confirmDeleteTransaction(transactionId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menampilkan dialog input transaksi
  void _showTransactionDialog(BuildContext context) {
    controller.clearForm();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tambah Transaksi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    labelText: "Nama Transaksi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Jumlah (Rp)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 15),
                Obx(
                  () => ToggleButtons(
                    isSelected: [
                      controller.selectedType.value == "income",
                      controller.selectedType.value == "expense",
                    ],
                    borderRadius: BorderRadius.circular(12),
                    onPressed: (index) {
                      controller.selectedType.value =
                          index == 0 ? "income" : "expense";
                    },
                    selectedColor: Colors.white,
                    fillColor:
                        controller.selectedType.value == "income"
                            ? Colors.green
                            : Colors.red,

                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward),
                            SizedBox(width: 5),
                            Text("Pemasukan"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward),
                            SizedBox(width: 5),
                            Text("Pengeluaran"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text("Batal"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.submitTransaction();
                        Get.back();
                      },
                      // icon: Icon(Icons.save),
                      label: Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
}
