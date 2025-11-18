import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/other_widgets/item.dart';
import 'package:giolee78/features/home/presentation/screen/friend_request_screen.dart';
import 'package:giolee78/features/home/presentation/screen/my_friend_screen.dart';
import 'package:giolee78/features/home/presentation/screen/my_post_screen.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../utils/constants/app_colors.dart';
import '../controller/home_controller.dart';
import '../widgets/home_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HomeDetails(
                      notificationCount: controller.notificationCount,
                    ),
                    SizedBox(height: 20.h),
                    CommonImage(
                      imageSrc: AppImages.map,
                      width: double.infinity,
                      height: 350.h,
                    ),
                    SizedBox(height: 20.h),
                    Item(
                      imageSrc: AppIcons.clicker,
                      title: 'Clicker',
                      onTap: () {},
                    ),
                    Item(
                      imageSrc: AppIcons.bubbleChat,
                      title: 'Chat Nearby',
                      onTap: () {},
                    ),
                    Item(
                      imageSrc: AppIcons.myPost,
                      title: 'My Post',
                      onTap: () {
                        Get.to(() => const MyPostScreen());
                      },
                    ),
                    Item(
                      imageSrc: AppIcons.myFriend,
                      title: 'My Friend',
                      onTap: () {
                        Get.to(() => const MyFriendScreen());
                      },
                    ),
                    Item(
                      imageSrc: AppIcons.friend,
                      title: 'Friend Request',
                      onTap: () {
                        Get.to(() => const FriendRequestScreen());
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
