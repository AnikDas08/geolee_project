import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/chat_nearby/data/nearby_friends_model.dart';
import 'package:giolee78/features/chat_nearby/presentation/controller/nearby_chat_controller.dart';
import 'package:giolee78/features/chat_nearby/presentation/screen/chat_nearby_profile_screen.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ChatNearbyScreen extends StatelessWidget {
  const ChatNearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NearbyChatController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _ChatNearbyAppBar(),
      ),
      body: Obx(() {
        // Handle loading state
        if (controller.isNearbyChatLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Handle error state
        if (controller.nearbyChatError.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.r, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  controller.nearbyChatError.value,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.getNearbyChat(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Handle empty state
        if (controller.nearbyChatList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48.r, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No nearby users found',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Display list
        return RefreshIndicator(
          onRefresh: () => controller.getNearbyChat(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemBuilder: (context, index) {
              final user = controller.nearbyChatList[index];
              return _NearbyUserCard(nearbyChatUser: user);
            },
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemCount: controller.nearbyChatList.length,
          ),
        );
      }),
    );
  }
}

class _ChatNearbyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Center(
                  child: CommonText(
                    text: 'Chat Nearby',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'clear_data') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clear Data action selected!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'clear_data',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.black,
                        ),
                        SizedBox(width: 8.w),
                        CommonText(
                          text: 'Clear Data',
                          fontSize: 14.sp,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_horiz_rounded),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyUserCard extends StatelessWidget {
  const _NearbyUserCard({required this.nearbyChatUser});

  final NearbyChatUserModel nearbyChatUser; // Changed from NearbyChatResponseModel

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ChatNearbyProfileScreen(user: nearbyChatUser));
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [



            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryColor2.withOpacity(0.1),
              child: nearbyChatUser.privacy == "public"
                  ? ClipOval(
                child: nearbyChatUser.image != null && nearbyChatUser.image!.isNotEmpty
                    ? CommonImage(
                  imageSrc: ApiEndPoint.imageUrl + nearbyChatUser.image!,
                  size: 40.r,
                  fill: BoxFit.cover,
                )
                    : CommonImage(
                  imageSrc: "assets/images/profile_image.png",
                  size: 40.r,
                  fill: BoxFit.cover,
                ),
              )
                  : Image.asset(AppImages.private),
            ),

            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: nearbyChatUser.name,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),

                  SizedBox(height: 4.h),

                  CommonText(
                    text: nearbyChatUser.location.toString(),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor2,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}