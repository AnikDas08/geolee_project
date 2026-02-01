import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/friend/data/my_friends_model.dart';
import 'package:giolee78/features/friend/presentation/screen/view_friend_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../data/friend_model.dart';
import '../controller/my_friend_controller.dart';

class MyFriendScreen extends StatelessWidget {
  const MyFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyFriendController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        title: const CommonText(
          text: 'My Friend',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              const _SearchField(),
              SizedBox(height: 16.h),

              /// ================= Suggested Friends =================
              if (controller.suggestedFriends.isNotEmpty) ...[
                const CommonText(
                  text: 'Suggested Friends',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                SizedBox(height: 12.h),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.suggestedFriends.length,
                  itemBuilder: (context, index) {
                    final friend = controller.suggestedFriends[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _SuggestedFriendCard(
                        userId: friend['id'],
                        userName: friend['name'],
                        avatar: friend['avatar'],
                        controller: controller,
                      ),
                    );
                  },
                ),

                SizedBox(height: 20.h),
              ],

              /// ================= My Friends =================
              CommonText(
                text: 'Total Friend (${controller.myFriendsList.length})',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              SizedBox(height: 12.h),

              if (controller.myFriendsList.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const Center(
                    child: CommonText(
                      text: 'No friends yet',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.myFriendsList.length,
                  itemBuilder: (context, index) {
                   var data = controller.myFriendsList[index];
                    final friend = data.friend;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _FriendListItem(
                        userId: friend?.sId ?? "",
                        userName: friend?.name ?? "Unknown",
                        avatar: "${ApiEndPoint.imageUrl}${friend!.image}",
                        controller: controller,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= Search =================
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      hintText: 'Search friends...',
      borderRadius: 8,
      paddingHorizontal: 14,
      paddingVertical: 12,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Icon(Icons.search, size: 18.sp, color: AppColors.textFiledColor),
      ),
    );
  }
}

/// ================= Suggested Friend Card =================
class _SuggestedFriendCard extends StatelessWidget {
  const _SuggestedFriendCard({
    required this.userId,
    required this.userName,
    required this.controller,
    this.avatar,
  });

  final String userId;
  final String userName;
  final String? avatar;
  final MyFriendController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRequestSent = controller.isRequestSent(userId);

      return GestureDetector(
        onTap: () =>
            Get.to(() => ViewFriendScreen(isFriend: false, userId: userId)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundImage: AssetImage(avatar ?? AppImages.profileImage),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CommonText(
                  text: userName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  maxLines: 1,
                ),
              ),
              isRequestSent
                  ? Icon(Icons.check_circle, color: Colors.green, size: 20.sp)
                  : GestureDetector(
                      onTap: () => controller.sendFriendRequest(userId),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const CommonText(
                          text: 'Add',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }
}

/// ================= Friend List Item =================
class _FriendListItem extends StatelessWidget {
  const _FriendListItem({
    required this.userId,
    required this.userName,
    required this.controller,
    this.avatar,
  });

  final String userId;
  final String userName;
  final String? avatar;
  final MyFriendController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => ViewFriendScreen(isFriend: true, userId: userId)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundImage: (avatar != null && avatar!.startsWith('http'))
                  ? NetworkImage(avatar!) as ImageProvider
                  : AssetImage(AppImages.profileImage),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CommonText(
                text: userName,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                maxLines: 1,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.message),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 20.sp,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () => controller.removeFriend(userId),
              child: Icon(
                Icons.close,
                size: 20.sp,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
