import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import '../controller/add_member_controller.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddMemberController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColors.black),
        ),
        centerTitle: true,
        title: const CommonText(text: 'Add Member', fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Search Bar Section ---
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: 'Add Friends',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search friends...',
                        prefixIcon: Icon(Icons.search, size: 22.sp),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Friends List (Search Results) ---
            if (controller.searchResults.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CommonText(text: 'No friends to add', fontSize: 14, color: Colors.grey),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final friend = controller.searchResults[index];
                      final imageUrl = friend.image.startsWith('http')
                          ? friend.image
                          : "${ApiEndPoint.imageUrl}${friend.image}";

                      return _buildPersonItem(
                        imageUrl: imageUrl,
                        name: friend.name,
                        trailing: ElevatedButton(
                          onPressed: () => controller.onAddMember(friend),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: Size(60.w, 30.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            elevation: 0,
                          ),
                          child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                    childCount: controller.searchResults.length,
                  ),
                ),
              ),

            // --- Divider & Header for Current Members ---
            if (controller.currentMembers.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 1.h, color: Colors.grey.shade200),
                      SizedBox(height: 20.h),
                      CommonText(
                        text: 'Group Members (${controller.currentMembers.length})',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),

            // --- Current Members List ---
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final member = controller.currentMembers[index];
                    final imageUrl = member.image.startsWith('http')
                        ? member.image
                        : "${ApiEndPoint.imageUrl}${member.image}";

                    return _buildPersonItem(
                      imageUrl: imageUrl,
                      name: member.name,
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade300, size: 24.sp),
                        onPressed: () => controller.showRemoveMemberDialog(member),
                      ),
                    );
                  },
                  childCount: controller.currentMembers.length,
                ),
              ),
            ),

            // Bottom Padding for smooth scrolling
            SliverToBoxAdapter(child: SizedBox(height: 30.h)),
          ],
        );
      }),
    );
  }

  // Common Widget for List Items to keep code clean
  Widget _buildPersonItem({required String imageUrl, required String name, required Widget trailing}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: CommonText(
              text: name,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}