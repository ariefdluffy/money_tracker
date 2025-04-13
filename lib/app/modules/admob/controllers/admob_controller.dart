import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobController extends GetxController {
  late BannerAd _bannerAd;
  RxBool isBannerAdLoaded = false.obs;

  // Memuat iklan banner
  void loadBannerAd() {
    _bannerAd = BannerAd(
      // adUnitId:
      //     'ca-app-pub-3940256099942544~3347511713', // DEmo
      adUnitId:
          'ca-app-pub-2393357737286916/1252487434', // Ganti dengan ID unit iklan banner Anda
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAdLoaded.value = true; // Banner iklan berhasil dimuat
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load banner ad: ${error.message}');
          isBannerAdLoaded.value = false; // Gagal memuat iklan
        },
      ),
    );
    _bannerAd.load(); // Memuat iklan banner
  }

  @override
  void onInit() {
    super.onInit();
    loadBannerAd();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    _bannerAd.dispose();
  }

  // Mengambil banner iklan
  Widget getBannerAdWidget() {
    return Obx(() {
      if (isBannerAdLoaded.value) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
          ],
        );
      } else {
        return SizedBox(); // Tidak menampilkan apapun jika iklan belum dimuat
      }
    });
  }
}
