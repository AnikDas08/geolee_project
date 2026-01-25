import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';

import '../../../../component/image/common_image.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../../utils/enum/enum.dart';
import '../../../addpost/presentation/screen/add_post_screen.dart';
import '../../../ads/presentation/screen/create_ads_screen.dart';
import '../../../dashboard/presentation/screen/dashboard_screen.dart';
import '../../../message/presentation/screen/chat_screen.dart';
import 'home_screen.dart';

class HomeNav extends StatelessWidget {
  HomeNav({super.key});

  final HomeNavController controller = Get.put(HomeNavController());

  final List<Widget> userScreens = [
    HomeScreen(),
    AddPostScreen(),
    ChatListScreen(),
  ];

  final List<Widget> advertiseScreens = [
    HomeScreen(),
    CreateAdsScreen(),
    DashboardScreen(),
  ];

  final List<String> icons = [
    AppIcons.homeIcon,
    AppIcons.chatIcon,
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

      /// FAB
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        return controller.showNavBar.value
            ? SizedBox(
          height: 70.w,
          width: 70.w,
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () {
              controller.changeIndex(1); // AddPost / CreateAds
            },
            child: Center(
              child: CommonImage(imageSrc: AppIcons.add),
            ),
          ),
        )
            : SizedBox.shrink();
      }),

      /// Bottom Navigation
      bottomNavigationBar: Obx(() {
        if (!controller.showNavBar.value) return SizedBox.shrink();

        final isUser = controller.userType == UserType.user;

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
                  iconPath: icons[0],
                  label: 'Home',
                ),
                SizedBox(width: 40.w),
                _buildNavItem(
                  index: 2,
                  iconPath: icons[1],
                  label: isUser ? 'Message' : 'Dashboard',
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String label,
  }) {
    return Obx(() {
      final bool isSelected =
          controller.currentIndex.value == index;

      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24.w,
              width: 24.w,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? AppColors.primaryColor
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
