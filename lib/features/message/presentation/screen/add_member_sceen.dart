import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// Note: Assuming AppColors, CommonText, CommonImage exist in your project structure
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import '../controller/add_member_controller.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  // Reusable list tile for both search results and current members
  Widget _UserTile({
    required User user,
    required Widget actionWidget,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Mock Avatar (replace with CommonImage)
              CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(user.avatarUrl),
                backgroundColor: AppColors.secondaryText.withOpacity(0.1),
              ),
              SizedBox(width: 12.w),
              CommonText(
                text: user.name,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          actionWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddMemberController>(
      init: AddMemberController(),
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
              text: 'Add Member',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Search Input ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: 'Add Member',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        onChanged: controller.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search user',
                          hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(0.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                        style: TextStyle(fontSize: 16.sp, color: AppColors.black),
                      ),
                    ],
                  ),
                ),

                // --- Search Results (Users to Invite) ---
                if (controller.searchKeyword.isNotEmpty && controller.usersToInvite.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Column(
                      children: controller.usersToInvite.map((user) {
                        return _UserTile(
                          user: user,
                          actionWidget: ElevatedButton(
                            onPressed: () => controller.onAddMember(user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              minimumSize: Size(70.w, 35.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: CommonText(
                              text: 'Add',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // --- Separator ---
                SizedBox(height: 16.h),
                Divider(height: 1.h, color: Colors.grey.shade200),
                SizedBox(height: 16.h),

                // --- Current Members List ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CommonText(
                    text: 'Total Member (${controller.currentMembers.length})',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    itemCount: controller.filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = controller.filteredMembers[index];
                      return _UserTile(
                        user: member,
                        actionWidget: IconButton(
                          icon: Icon(Icons.close, size: 20.sp, color: Colors.grey.shade500),
                          onPressed: () => controller.onRemoveMember(member),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}