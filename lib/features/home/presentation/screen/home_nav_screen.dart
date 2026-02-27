import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';

import '../../../../component/image/common_image.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../addpost/presentation/screen/add_post_screen.dart';
import '../../../ads/presentation/screen/create_ads_screen.dart';
import '../../../dashboard/presentation/screen/dashboard_screen.dart';
import '../../../message/presentation/screen/chat_screen.dart';
import 'home_screen.dart';

class HomeNav extends StatelessWidget {
  HomeNav({super.key});

  final HomeNavController controller = Get.put(HomeNavController());

  bool get isGuest => LocalStorage.token.isEmpty;

  final List<Widget> userScreens = [
    const HomeScreen(),
    AddPostScreen(),
    const ChatListScreen(),
  ];

  final List<Widget> advertiseScreens = [
    const HomeScreen(),
    const CreateAdsScreen(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: controller.isUserScreenActive.value
              ? userScreens
              : advertiseScreens,
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ FAB with guest restriction
      floatingActionButton: Obx(() {
        if (!controller.showNavBar.value) return const SizedBox.shrink();

        return SizedBox(
          height: 70.w,
          width: 70.w,
          child: FloatingActionButton(
            backgroundColor: isGuest ? Colors.grey : AppColors.primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () {
              if (isGuest) {
                Get.snackbar(
                  "Login required",
                  "Please login to use this feature",
                );
                return;
              }
              controller.changeIndex(1);
            },
            child: const Center(
              child: CommonImage(imageSrc: AppIcons.add),
            ),
          ),
        );
      }),

      // ✅ Bottom Nav with guest restriction
      bottomNavigationBar: Obx(() {
        if (!controller.showNavBar.value) return const SizedBox.shrink();

        final bool isUser = LocalStorage.role == "user";

        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 14.w,
          color: AppColors.navBarColor,
          child: SizedBox(
            height: 80.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  iconPath: AppIcons.homeIcon,
                  label: 'Home',
                ),

                SizedBox(width: 40.w),

                _buildNavItem(
                  index: 2,
                  iconPath: AppIcons.chatIcon,
                  label: isUser ? 'Message' : 'Dashboard',
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ✅ Nav item with disable logic
  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String label,
  }) {
    return Obx(() {
      final bool isSelected = controller.currentIndex.value == index;

      return GestureDetector(
        onTap: () {
          if (isGuest && index != 0) {
            Get.snackbar(
              "Login required",
              "Please login to access this feature",
            );
            return;
          }
          controller.changeIndex(index);
        },
        child: Opacity(
          opacity: (isGuest && index != 0) ? 0.4 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconPath,
                height: 24.w,
                width: 24.w,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primaryColor : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected ? AppColors.primaryColor : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}