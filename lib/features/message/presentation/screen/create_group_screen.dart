import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import '../../../../config/api/api_end_point.dart';
import '../controller/create_group_controller.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateGroupController>(
      init: CreateGroupController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: const CommonText(
              text: "Create Group",
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Group Name Field
                CommonText(
                  text: "Group Name",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  bottom: 8.h,
                ),
                TextField(
                  controller: controller.groupNameController,
                  decoration: InputDecoration(
                    hintText: "Enter Your Group Name",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// Privacy Type Dropdown
                CommonText(
                  text: "Privacy Type",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  bottom: 8.h,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Obx(() {
                    return DropdownButtonFormField<String>(
                      value: controller.privacyOptions[controller.selectedPrivacyType.value],
                      items: controller.privacyTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        );
                      }).toList(),
                      onChanged: controller.changePrivacyType,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: InputBorder.none,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20.h),

                /// Description Field
                CommonText(
                  text: "Description",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  bottom: 8.h,
                ),
                TextField(
                  controller: controller.descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Write here your group description",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// Add Member Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: "Add Member",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    TextButton(
                      onPressed: () {
                        _showAddMemberDialog(context, controller);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      child: Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                /// Selected Members Count
                Obx(() => CommonText(
                  text: "Selected Member (${controller.selectedMembers.length})",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  bottom: 12.h,
                )),

                /// Selected Members Chips
                Obx(() {
                  if (controller.selectedMembers.isEmpty) {
                    return CommonText(
                      text: "No members selected",
                      fontSize: 13.sp,
                      color: Colors.grey,
                    );
                  }

                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: controller.selectedMembers.map((member) {
                      return Chip(
                        backgroundColor: Colors.grey[100],
                        deleteIconColor: Colors.grey[600],
                        label: Text(
                          member.name,
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        onDeleted: () => controller.removeMember(member.id),
                      );
                    }).toList(),
                  );
                }),

                SizedBox(height: 40.h),

                /// Create Group Button
                Obx(() => CommonButton(
                  titleText: controller.isCreating.value
                      ? 'Creating...'
                      : 'Create Group',
                  buttonHeight: 50.h,
                  buttonRadius: 8.r,
                  titleSize: 16.sp,
                  onTap: () {
                    controller.createGroup();
                  },
                )),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberDialog(
      BuildContext context,
      CreateGroupController controller,
      ) {
    controller.fetchMyChats();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Obx(() {
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        text: "Add Members",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.clearSearch();
                          Get.back();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  /// Search
                  TextField(
                    controller: controller.searchController,
                    onChanged: controller.searchMembers,
                    decoration: InputDecoration(
                      hintText: "Search members...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clearSearch,
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),


                  Expanded(
                    child: controller.isMemberLoading.value
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : controller.availableMembers.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "No members found",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: controller.availableMembers.length,
                      itemBuilder: (context, index) {
                        final member =
                        controller.availableMembers[index];
                        final isSelected = controller.selectedMembers.any((m) => m.id == member.id);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            AppColors.primaryColor,
                            backgroundImage: member.image != null
                                ? NetworkImage(
                                ApiEndPoint.imageUrl +
                                    member.image!)
                                : null,
                            child: member.image == null
                                ? Text(
                              member.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : null,
                          ),
                          title: Text(member.name),
                          trailing: isSelected
                              ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                              : const Icon(
                            Icons.add_circle_outline,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            controller.toggleMember(member);
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  CommonButton(
                    titleText: "Confirm",
                    buttonHeight: 48.h,
                    onTap: () => Get.back(),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}