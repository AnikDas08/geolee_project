import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

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
                    hintText: "Sports Club",
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
                  child: DropdownButtonFormField<String>(
                    initialValue: controller.selectedPrivacyType,
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
                  ),
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
                    hintText: "About The Role\nWe Are Looking for a Senior and Friendly Plumber To Join Our Team...",
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
                CommonText(
                  text: "Selected Member (${controller.selectedMembers.length})",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  bottom: 12.h,
                ),

                /// Selected Members Chips
                if (controller.selectedMembers.isNotEmpty)
                  Wrap(
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
                  ),

                SizedBox(height: 40.h),

                /// Create Group Button
                CommonButton(
                  titleText: 'Create Group',
                  buttonHeight: 50.h,
                  buttonRadius: 8.r,
                  titleSize: 16.sp,
                  onTap: (){
                    Get.toNamed(AppRoutes.chat);
                  },
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context, CreateGroupController controller) {
    // Mock data for demo - replace with actual API call
    final List<GroupMember> availableMembers = [
      GroupMember(id: '1', name: 'Shahir Ahmed'),
      GroupMember(id: '2', name: 'Emily Davis'),
      GroupMember(id: '3', name: 'Alex Johnson'),
      GroupMember(id: '4', name: 'Sarah Wilson'),
      GroupMember(id: '5', name: 'Mike Brown'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return GetBuilder<CreateGroupController>(
          builder: (controller) {
            final filteredMembers = controller.searchQuery.isEmpty
                ? availableMembers
                : availableMembers.where((member) {
              return member.name.toLowerCase().contains(controller.searchQuery);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
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
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      /// Search Field
                      TextField(
                        controller: controller.searchController,
                        onChanged: (value) => controller.searchMembers(value),
                        decoration: InputDecoration(

                          hintText: "Search members...",
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),

                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          suffixIcon: controller.searchQuery.isNotEmpty
                              ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () => controller.clearSearch(),
                          )
                              : null,
                          filled: true,
                          fillColor: Colors.grey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      /// Members List
                      Expanded(
                        child: filteredMembers.isEmpty
                            ? Center(
                          child: CommonText(
                            text: "No members found",
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        )
                            : ListView.builder(
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            final isSelected = controller.selectedMembers
                                .any((m) => m.id == member.id);

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 4.h,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                                child: Text(
                                  member.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                member.name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              )
                                  : Icon(
                                Icons.add_circle_outline,
                                color: Colors.grey[400],
                              ),
                              onTap: () {
                                if (isSelected) {
                                  controller.removeMember(member.id);
                                } else {
                                  controller.addMember(member);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h,),
                      CommonButton(
                          titleText: "Confirm",
                        onTap: ()=>Get.back(),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}