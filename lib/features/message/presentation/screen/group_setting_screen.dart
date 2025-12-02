import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// Assuming CommonImage handles network/asset images
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'dart:io'; // Required for File image

import '../controller/group_setting_controller.dart'; // Corrected import based on your provided file

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

  void _showEditGroupNameDialog(GroupSettingsController controller) {
    TextEditingController textController = TextEditingController(text: controller.groupName.value);
    Get.defaultDialog(
      title: "Edit Group Name",
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new group name",
          ),
        ),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      onCancel: () =>   Navigator.pop(Get.context!), // Use Get.back() for GetX dialogs
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.primaryColor,
      onConfirm: () {
        controller.onUpdateGroupName(textController.text.trim());
        Navigator.pop(Get.context!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupSettingsController>(
      init: GroupSettingsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => Navigator.pop(context), // Use Get.back()
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
              color: AppColors.black,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Group Avatar Section (MODIFIED FOR IMAGE PICKER) ---
                  GestureDetector( // Make the whole avatar area tappable
                    onTap: controller.pickGroupImage, // Call image picker
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Obx(() { // Obx to react to changes in avatarFilePath
                          if (controller.avatarFilePath!.value.isNotEmpty) {
                            // Display selected image from file
                            return CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: FileImage(File(controller.avatarFilePath!.value)),
                              // Optionally, use a child for error/fallback icon
                              child: ClipOval(
                                child: Image.file(
                                  File(controller.avatarFilePath!.value),
                                  width: 100.r,
                                  height: 100.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.group, size: 50.sp, color: AppColors.white);
                                  },
                                ),
                              ),
                            );
                          } else {
                            // Display text fallback
                            return CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.grey.shade300,
                              child: CommonText(
                                text: controller.groupName.value.substring(0, 2).toUpperCase(),
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
                    onTap: () => _showEditGroupNameDialog(controller),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(
                          text: controller.groupName.value,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.edit, size: 16.sp, color: Colors.grey.shade600),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // --- Member Count ---
                  CommonText(
                    text: '${controller.memberCount.value} Member',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),

                  SizedBox(height: 30.h),

                  // --- Settings List ---
                  _SettingsTile(
                    title: 'Add Member',
                    onTap: (){
                      Get.toNamed(AppRoutes.addMemberScreen);
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
                  _SettingsTile(
                    title: 'Leave Group',
                    onTap: controller.onLeaveGroup,
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