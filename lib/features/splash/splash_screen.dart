import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../config/route/app_routes.dart';
import 'package:giolee78/services/notification/firebase_notification_service.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_images.dart';
import '../../component/image/common_image.dart';


import 'package:giolee78/services/api/user_api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _initFCM();
    await Future.delayed(const Duration(seconds: 3));
    _handleNavigation();
  }

  /// 🔥 Firebase + Token Setup
  Future<void> _initFCM() async {
    try {
      final firebaseService = FirebaseNotificationService();

      // Init notification
      await firebaseService.initNotifications();

      // Get token
      final token = await firebaseService.getFCMToken();

      if (token != null) {
        debugPrint("✅ FCM Token: $token");

        // 👉 Backend এ পাঠানো
        if (LocalStorage.userId.isNotEmpty) {
          await UserApiService.sendTokenToServer(
            userId: LocalStorage.userId,
            token: token,
          );
        }


        LocalStorage.setString(LocalStorageKeys.fcmToken, token);

        print("FCM TOKEN IS:${token}");


      }
    } catch (e) {
      debugPrint("❌ FCM Init Error: $e");
    }
  }

  /// 🚀 Navigation Logic
  void _handleNavigation() {
    if (LocalStorage.isLogIn) {
      debugPrint("➡️ Go to Home");
      Get.offAllNamed(AppRoutes.homeNav);
    } else {
      debugPrint("➡️ Go to Onboarding");
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  /// 📦 App Version
  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return "${info.version}+${info.buildNumber}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CommonImage(
              imageSrc: AppImages.logo,
              size: 250,
            ).center,

            SizedBox(height: 50.h),

            FutureBuilder<String>(
              future: getAppVersion(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                return CommonText(
                  text: "Version: ${snapshot.data} (beta)",
                  fontSize: 15.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}