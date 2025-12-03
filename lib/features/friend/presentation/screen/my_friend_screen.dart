import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/friend/presentation/screen/view_friend_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../controller/friend_controller.dart';

class MyFriendScreen extends StatelessWidget {
  const MyFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(MyFriendController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
        child: Obx(() => ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            _SearchField(),
            SizedBox(height: 16.h),

            // Suggested friends section
            if (controller.suggestedFriends.isNotEmpty) ...[
              const CommonText(
                text: 'Suggested Friends',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 12.h),
              ...controller.suggestedFriends.map((friend) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _SuggestedFriendCard(
                  userId: friend['id'],
                  userName: friend['name'],
                  avatar: friend['avatar'],
                  controller: controller,
                ),
              )),
              SizedBox(height: 20.h),
            ],

            // Friends list section
            CommonText(
              text: 'Total Friend (${controller.friendsList.length})',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 12.h),

            // Friend list
            if (controller.friendsList.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const CommonText(
                    text: 'No friends yet',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),
                ),
              )
            else
              ...controller.friendsList.map((friend) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _FriendListItem(
                  userId: friend['id'],
                  userName: friend['name'],
                  avatar: friend['avatar'],
                  controller: controller,
                ),
              )),
          ],
        )),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
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
        onTap: (){
          Get.to(()=>ViewFriendScreen(isFriend: false));
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                  textAlign: TextAlign.start,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 12.w),

              // Show checkmark if request sent, otherwise show Add button
              if (isRequestSent)
                Container(
                  height: 32.h,
                  width: 32.h,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_circle,
                    size: 20.sp,
                    color: Colors.green,
                  ),
                )
              else
                GestureDetector(
                  onTap: () => controller.sendFriendRequest(userId),
                  child: Container(
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
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
      onTap: () => Get.to(()=>ViewFriendScreen(isFriend: true)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.message);
              },
              child: Icon(
                Icons.chat_bubble_outline,
                size: 20.sp,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () {
                // Show confirmation dialog before removing
                Get.dialog(
                  AlertDialog(
                    title: const CommonText(
                      text: 'Remove Friend',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    content: CommonText(
                      text: 'Are you sure you want to remove $userName from your friends?',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                      maxLines: 4,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const CommonText(
                          text: 'Cancel',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.removeFriend(userId);
                        },
                        child: const CommonText(
                          text: 'Remove',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
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