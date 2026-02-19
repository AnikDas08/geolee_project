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

  // Index 0: Home, Index 1: AddPost, Index 2: Chat
  final List<Widget> userScreens = [
    const HomeScreen(),
    AddPostScreen(),
    const ChatListScreen(),
  ];

  // Index 0: Home (Shared), Index 1: CreateAds, Index 2: Dashboard
  final List<Widget> advertiseScreens = [
    const HomeScreen(),
    const CreateAdsScreen(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack switches between lists based on isUserScreenActive
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: controller.isUserScreenActive.value
              ? userScreens
              : advertiseScreens,
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        if (!controller.showNavBar.value) return const SizedBox.shrink();
        return SizedBox(
          height: 70.w,
          width: 70.w,
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () => controller.changeIndex(1), // Middle Button
            child: const Center(child: CommonImage(imageSrc: AppIcons.add)),
          ),
        );
      }),

      bottomNavigationBar: Obx(() {
        if (!controller.showNavBar.value) return const SizedBox.shrink();

        // CORRECT WAY TO CHECK ROLE
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
                // LEFT BUTTON: Home
                _buildNavItem(
                  index: 0,
                  iconPath: AppIcons.homeIcon,
                  label: 'Home',
                ),

                SizedBox(width: 40.w), // Space for FAB

                // RIGHT BUTTON: Message or Dashboard
                _buildNavItem(
                  index: 2,
                  iconPath: isUser ? AppIcons.chatIcon : AppIcons.chatIcon, // Assuming you have a dashboard icon
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
      final bool isSelected = controller.currentIndex.value == index;
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
      );
    });
  }
}