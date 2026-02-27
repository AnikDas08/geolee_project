import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/config/route/app_routes.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/log/app_log.dart';
import '../controller/group_setting_controller.dart';

class GroupSettingsScreen extends StatelessWidget {
  const GroupSettingsScreen({super.key});

  Widget _SettingsTile({
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: title,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: titleColor ?? AppColors.black,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.secondaryText.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  void showEditGroupNameDialog(GroupSettingsController controller) {
    final TextEditingController textController = TextEditingController(
      text: controller.groupName.value,
    );
    final RxBool isLoading = false.obs;

    Get.dialog(
      Obx(
        () => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 50.sp, color: AppColors.primaryColor),
                SizedBox(height: 12.h),
                Text(
                  "Edit Group Name",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Enter a new name for the group",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 16.h),

                // Text Field
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter new group name",
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade100,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Save Button
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading.value
                            ? null
                            : () async {
                                try {
                                  isLoading.value = true;
                                  controller.onUpdateGroupName(
                                    textController.text.trim(),
                                  );
                                  Get.back();
                                } finally {
                                  isLoading.value = false;
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppColors.primaryColor,
                          ),
                          alignment: Alignment.center,
                          child: isLoading.value
                              ? SizedBox(
                                  height: 18.h,
                                  width: 18.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Save",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupSettingsController>(
      init: GroupSettingsController(),
      global: false,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18.sp,
                color: AppColors.black,
              ),
            ),
            centerTitle: true,
            title: const CommonText(
              text: 'Settings',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  // --- Group Avatar ---
                  GestureDetector(
                    onTap: controller.pickGroupImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Obx(() {
                          final avatarPath = controller.avatarFilePath.value;

                          // ১. ইমেজ লোড হচ্ছে কিনা তা দেখার জন্য ইন্ডিকেটর (ঐচ্ছিক)
                          if (controller.isSaving.value) {
                            return CircleAvatar(
                              radius: 50.r,
                              child: const CircularProgressIndicator(),
                            );
                          }

                          // ২. যদি ইমেজ পাথ থাকে
                          if (avatarPath.isNotEmpty) {
                            final isNetworkImage =
                                avatarPath.startsWith('http') ||
                                !avatarPath.contains(
                                  '/data/user/',
                                ); // অ্যান্ড্রয়েড লোকাল পাথের সাধারণ চেক

                            return CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: isNetworkImage
                                  ? NetworkImage(
                                      avatarPath.startsWith('http')
                                          ? avatarPath
                                          : () {
                                              // Base URL এবং Path এর মাঝে স্ল্যাশ নিশ্চিত করা
                                              String baseUrl =
                                                  ApiEndPoint.imageUrl;
                                              if (!baseUrl.endsWith('/')) {
                                                baseUrl = '$baseUrl/';
                                              }
                                              final String cleanPath =
                                                  avatarPath.startsWith('/')
                                                  ? avatarPath.substring(1)
                                                  : avatarPath;

                                              return "$baseUrl$cleanPath";
                                            }(),
                                    )
                                  : FileImage(File(avatarPath))
                                        as ImageProvider,

                              // ইমেজ লোড হতে এরর হলে অল্টারনেটিভ টেক্সট দেখাবে
                              onBackgroundImageError: (exception, stackTrace) {
                                appLog("❌ Image Load Error: $exception");
                              },
                            );
                          } else {
                            // ৩. যদি কোন ইমেজ না থাকে (Default Initial)
                            return CircleAvatar(
                              radius: 50.r,
                              backgroundColor: AppColors.primaryColor
                                  .withOpacity(0.8),
                              child: CommonText(
                                text: controller.groupName.value.isNotEmpty
                                    ? controller.groupName.value
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : '?',
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            );
                          }
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 12.r,
                            backgroundColor: AppColors.primaryColor,
                            child: Icon(
                              Icons.edit,
                              size: 14.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // --- Group Name & Edit ---
                  GestureDetector(
                    onTap: () => showEditGroupNameDialog(controller),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => CommonText(
                            text: controller.groupName.value,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.edit,
                          size: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // --- Member Count ---
                  Obx(
                    () => CommonText(
                      text:
                          '${controller.memberCount.value} Member${controller.memberCount.value != 1 ? 's' : ''}',
                      fontSize: 14.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // --- Settings List ---
                  _SettingsTile(
                    title: 'Add Member',
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.addMemberScreen,
                        arguments: {'chatId': controller.chatId},
                      );
                    },
                  ),
                  _SettingsTile(
                    title: 'Pending Request',
                    onTap: controller.onPendingRequest,
                  ),
                  _SettingsTile(
                    title: 'Privacy Settings',
                    onTap: controller.onPrivacySettings,
                  ),

                  // ✅ Admin Approval Switch tile
                  Obx(
                    () => Container(
                      height: 56.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(
                            text: 'Admin Approval',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          CupertinoSwitch(
                            value: controller.accessType.value == 'restricted',
                            activeColor: AppColors.primaryColor,
                            onChanged: (value) =>
                                controller.toggleAdminApproval(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _SettingsTile(
                    title: 'Leave Group',
                    onTap: controller.showLeaveGroupDialog,
                    titleColor: Colors.red,
                  ),
                  _SettingsTile(
                    title: 'Delete Group',
                    onTap: controller.onDeleteGroup,
                    titleColor: Colors.red.shade700,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
