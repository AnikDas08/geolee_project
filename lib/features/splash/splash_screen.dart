import 'package:flutter/material.dart';
import 'package:giolee78/features/addpost/presentation/screen/edit_post.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import '../../../../config/route/app_routes.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/app_images.dart';
import '../../component/image/common_image.dart';
import '../addpost/presentation/screen/add_post_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (LocalStorage.isLogIn || LocalStorage.token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.homeNav);
      } else {
        Get.offAllNamed(AppRoutes.homeNav);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonImage(imageSrc: AppImages.logo, size: 250).center,
    );
  }
}
