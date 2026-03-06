import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/message/presentation/controller/chat_controller.dart';

import '../../../../component/image/common_image.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../addpost/presentation/screen/add_post_screen.dart';
import '../../../ads/presentation/screen/create_ads_screen.dart';
import '../../../dashboard/presentation/screen/dashboard_screen.dart';
import '../../../message/presentation/screen/chat_screen.dart';
import 'home_screen.dart';

class HomeNav extends StatefulWidget {
  HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
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
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        if (controller.currentIndex.value == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ChatController.instance.getChatRepos();
          });
        }
        return IndexedStack(
          index: controller.currentIndex.value,
          children: controller.isUserScreenActive.value
              ? userScreens
              : advertiseScreens,
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: Obx(() {
        // Unconditionally access observable
        final showNavBar = controller.showNavBar.value;
        final bool isKeyboardVisible =
            MediaQuery.of(context).viewInsets.bottom > 0;
        if (!showNavBar || isKeyboardVisible) return const SizedBox.shrink();

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
            child: const Center(child: CommonImage(imageSrc: AppIcons.add)),
          ),
        );
      }),

      bottomNavigationBar: Obx(() {
        // Unconditionally access observable
        final showNavBar = controller.showNavBar.value;
        final bool isKeyboardVisible =
            MediaQuery.of(context).viewInsets.bottom > 0;
        if (!showNavBar || isKeyboardVisible) return const SizedBox.shrink();

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
                  iconPath: isUser ? AppIcons.chatIcon : AppIcons.dashBoard,
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
      // Unconditionally access observable to prevent GetX error
      final bool isSelected = controller.currentIndex.value == index;

      return GestureDetector(
        onTap: () {
          if (isGuest && index != 0) {
            Get.snackbar(
              "Login required",
              "Please sign up to use this feature.",
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
              Stack(
                clipBehavior: Clip.none,
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
                  if (index == 2 && LocalStorage.role == "user")
                    GetBuilder<ChatController>(
                      builder: (chatCtrl) {
                        final count = chatCtrl.unreadCountUser;
                        if (count <= 0) return const SizedBox.shrink();
                        return Positioned(
                          right: -8.w,
                          top: -8.w,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16.w,
                              minHeight: 16.w,
                            ),
                            child: Center(
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
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
