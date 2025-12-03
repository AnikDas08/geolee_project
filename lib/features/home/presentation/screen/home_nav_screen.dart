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

  HomeNavController controller = Get.put(HomeNavController());


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

  final List<String> icons = [AppIcons.homeIcon, AppIcons.chatIcon];
  final List<String> advertiseIcons = [AppIcons.homeIcon, AppIcons.chatIcon];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Core Logic: This switches the content list based on the state variable
        final showUserScreens = controller.isUserScreenActive.value;
        return IndexedStack(
          index: controller.currentIndex.value,
          children: showUserScreens ? userScreens : advertiseScreens,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 70.w,
        width: 70.w,
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: () => controller.currentIndex.value = 1,
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(child: CommonImage(imageSrc: AppIcons.add)),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
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
                  isSelected: controller.currentIndex.value == 0,
                ),
                SizedBox(width: 40.w),
                _buildNavItem(
                  index: 2,
                  iconPath: isUser ? icons[1] : advertiseIcons[1],
                  label: isUser ? 'Message' : 'Dashboard',
                  isSelected: controller.currentIndex.value == 2,
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
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        // Logic: Advertiser controls which screen list is active
        if (controller.userType != UserType.user) {
          if (index == 0) {
            // Click Home: Switch to User Screens List (Home/AddPost/ChatList)
            controller.isUserScreenActive.value = true;
          } else if (index == 2) {
            // Click Dashboard: Switch back to Advertiser Screens List (Home/Ads/Dashboard)
            controller.isUserScreenActive.value = false;
          }
        } else {
          // Regular User: always ensure User Screens are active
          controller.isUserScreenActive.value = true;
        }

        // Set the index for the navigation
        controller.currentIndex.value = index;
      },
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}