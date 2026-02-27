import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/chat_nearby/data/nearby_friends_model.dart';
import 'package:giolee78/features/chat_nearby/presentation/controller/nearby_chat_controller.dart';
import 'package:giolee78/features/chat_nearby/presentation/controller/chat_nearby_profile_controller.dart';
import 'package:giolee78/features/chat_nearby/presentation/screen/chat_nearby_profile_screen.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart'
    hide FriendStatus;
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';

class ChatNearbyScreen extends StatelessWidget {
  const ChatNearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NearbyChatController());
    final clickerController = Get.put(ClickerController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _ChatNearbyAppBar(),
      ),
      body: Obx(() {
        if (controller.isNearbyChatLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

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

        return RefreshIndicator(
          onRefresh: () => controller.getNearbyChat(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: controller.nearbyChatList.length + 1,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == controller.nearbyChatList.length) {
                  return Obx(
                        () => controller.isPaginationLoading.value
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.h),
                        child: const CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  );
                }

                final user = controller.nearbyChatList[index];
                return _NearbyUserCard(
                  nearbyChatUser: user,
                  clickerController: clickerController,
                  controller: controller, // ✅ pass controller
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class _ChatNearbyAppBar extends StatelessWidget {
  Future<void> updateProfileAndLocationVisible() async {
    try {
      final latitude = LocalStorage.lat.toDouble();
      final longitude = LocalStorage.long.toDouble();

      final response = await ApiService.patch(
        ApiEndPoint.updateProfile,
        body: {
          'isLocationVisible': false,
          "location": [longitude, latitude],
        },
      );

      if (response.statusCode == 200) {
        Get.toNamed(AppRoutes.homeNav);
        debugPrint('Profile location updated');
      } else {
        debugPrint('Failed to update profile: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
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
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: CommonText(
                    text: 'Chat Nearby',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'clear_data') {
                    updateProfileAndLocationVisible();
                    Get.back();
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'clear_data',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            color: AppColors.black),
                        SizedBox(width: 8.w),
                        CommonText(text: 'Clear Data', fontSize: 14.sp),
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
  const _NearbyUserCard({
    required this.nearbyChatUser,
    required this.clickerController,
    required this.controller,
  });

  final NearbyChatUserModel nearbyChatUser;
  final ClickerController clickerController;
  final NearbyChatController controller;

  Future<void> _handleUserTap(BuildContext context) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
        barrierDismissible: false,
      );

      final tempController = ChatNearbyProfileController();
      await tempController.checkFriendship(nearbyChatUser.id.toString());

      Get.back();

      if (tempController.friendStatus.value == FriendStatus.friends) {
        await clickerController.createOrGetChatAndGo(
          receiverId: nearbyChatUser.id.toString(),
          name: nearbyChatUser.name,
          image: nearbyChatUser.image ?? '',
        );
      } else {
        Get.to(() => ChatNearbyProfileScreen(user: nearbyChatUser));
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Error checking friend status: $e");
      Get.to(() => ChatNearbyProfileScreen(user: nearbyChatUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Reactive friend status
      final isFriend =
          controller.friendStatusMap[nearbyChatUser.id] ?? false;

      return GestureDetector(
        onTap: () => _handleUserTap(context),
        child: Container(
          decoration: ShapeDecoration(
            //=======================if user is friend show This UI
            color: isFriend
                ? AppColors.primaryColor2.withOpacity(0.08)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isFriend
                  ? const BorderSide(
                color: AppColors.primaryColor,
                width: 0.05,
              )
                  : BorderSide.none,
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 4,
                offset: Offset(0, 2),
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
                  child: nearbyChatUser.image != null &&
                      nearbyChatUser.image!.isNotEmpty
                      ? CommonImage(
                    imageSrc: ApiEndPoint.imageUrl +
                        nearbyChatUser.image!,
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
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 4.h),
                    CommonText(
                      text:
                      "Within ${nearbyChatUser.distance?.toStringAsFixed(2) ?? "0"} KM",
                      fontSize: 12.sp,
                      color: AppColors.primaryColor2,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              // if (isFriend)
              //   Container(
              //     padding:
              //     EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              //     decoration: BoxDecoration(
              //       color: AppColors.primaryColor,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: CommonText(
              //       text: "Friend",
              //       fontSize: 10.sp,
              //       color: Colors.white,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
            ],
          ),
        ),
      );
    });
  }
}