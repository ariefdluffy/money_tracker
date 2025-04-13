import 'package:get/get.dart';

import '../controllers/admob_controller.dart';

class AdmobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdmobController>(() => AdmobController());
  }
}
