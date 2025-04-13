import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/admob_controller.dart';

class AdmobView extends GetView<AdmobController> {
  const AdmobView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AdmobView'), centerTitle: true),
      body: const Center(
        child: Text('AdmobView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
