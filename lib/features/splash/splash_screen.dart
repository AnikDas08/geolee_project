import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../config/route/app_routes.dart';
import 'package:giolee78/services/notification/firebase_notification_service.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_images.dart';
import '../../component/image/common_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _fetchFCMToken();
    super.initState();
  }

  Future<void> _fetchFCMToken() async {
    // Import logic done locally or via standard imports
    try {
      final token = await _getFCMToken();
      if (token != null) {
        debugPrint("Splash Screen: Fetched FCM Token: $token");
        // Save to local storage or API based on requirements later
      }
    } catch (e) {
      debugPrint("FCM token fetch error in Splash: $e");
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (LocalStorage.isLogIn) {
        debugPrint(
          "My Role Is :===========================💕💕💕💕💕💕 ${LocalStorage.role.toString()}",
        );
        Get.offAllNamed(AppRoutes.homeNav);
      } else {
        debugPrint(
          "My Role Is :===========================💕💕💕💕💕💕 ${LocalStorage.role.toString()}",
        );
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
  }

  Future<String?> _getFCMToken() async {
    try {
      return await FirebaseNotificationService().getFCMToken();
    } catch (_) {
      return null;
    }
  }

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
            const CommonImage(imageSrc: AppImages.logo, size: 250).center,

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
