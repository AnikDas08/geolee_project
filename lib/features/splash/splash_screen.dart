import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../config/route/app_routes.dart';
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
    super.initState();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonImage(imageSrc: AppImages.logo, size: 250).center,

            SizedBox(height: 50.h),

            FutureBuilder<String>(
              future: getAppVersion(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
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
