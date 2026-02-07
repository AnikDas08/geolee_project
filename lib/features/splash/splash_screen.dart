import 'package:flutter/material.dart';
import 'package:giolee78/features/ads/presentation/screen/create_ads_screen.dart';
import 'package:giolee78/features/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:giolee78/features/home/presentation/screen/home_nav_screen.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import '../../../../config/route/app_routes.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_images.dart';
import '../../component/image/common_image.dart';
import '../ads/presentation/screen/history_ads_screen.dart';

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

        print("My Role Is :===========================💕💕💕💕💕💕 ${LocalStorage.role.toString()}");
       // Get.offAllNamed(AppRoutes.homeNav);
        // Get.to(() => const DashboardScreen());
         Get.to(() => HomeNav());
      } else {
        print("My Role Is :===========================💕💕💕💕💕💕 ${LocalStorage.role.toString()}");
        Get.offAllNamed(AppRoutes.onboarding);
      }
    });
    super.initState();
  }
  //lksdjfldsf

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonImage(imageSrc: AppImages.logo, size: 250).center,
    );
  }
}
