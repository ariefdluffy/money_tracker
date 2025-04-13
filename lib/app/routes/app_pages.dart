import 'package:get/get.dart';
import 'package:money_tracker/app/modules/auth/views/signup_view.dart';

import '../modules/admob/bindings/admob_binding.dart';
import '../modules/admob/views/admob_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/transaction/bindings/transaction_binding.dart';
import '../modules/transaction/views/transaction_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(name: _Paths.AUTH, page: () => AuthView(), binding: AuthBinding()),
    GetPage(
      name: _Paths.TRANSACTION,
      page: () => const TransactionView(),
      binding: TransactionBinding(),
    ),
    // GetPage(
    //   name: _Paths.ADMOB,
    //   page: () => const AdmobView(),
    //   binding: AdmobBinding(),
    // ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignUpView(),
      binding: AuthBinding(),
    ),
  ];
}
