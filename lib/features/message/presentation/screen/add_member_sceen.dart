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

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Search Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: 'Add Friends to Group',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: controller.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search friends...',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 22.sp,
                            color: AppColors.primaryColor,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Results ──
            if (controller.searchResults.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_search_rounded,
                        size: 52.sp,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 12.h),
                      CommonText(
                        text: 'No friends to add',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final friend = controller.searchResults[index];
                      final imageUrl = friend.image.startsWith('http')
                          ? friend.image
                          : "${ApiEndPoint.imageUrl}${friend.image}";

                      return _buildPersonCard(
                        imageUrl: imageUrl,
                        name: friend.name,
                        subtitle: 'Friend',
                        trailing: _buildAddButton(
                          onTap: () => controller.onAddMember(friend),
                        ),
                      );
                    },
                    childCount: controller.searchResults.length,
                  ),
                ),
              ),

            // ── Current Members Header ──
            if (controller.currentMembers.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CommonText(
                        text: 'Group Members',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${controller.currentMembers.length}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Current Members List ──
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final member = controller.currentMembers[index];
                    final imageUrl = member.image.startsWith('http')
                        ? member.image
                        : "${ApiEndPoint.imageUrl}${member.image}";

                    return _buildPersonCard(
                      imageUrl: imageUrl,
                      name: member.name,
                      subtitle: 'Member',
                      trailing: _buildRemoveButton(
                        onTap: () =>
                            controller.showRemoveMemberDialog(member),
                      ),
                    );
                  },
                  childCount: controller.currentMembers.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          ],
        );
      }),
    );
  }


  Widget _buildPersonCard({
    required String imageUrl,
    required String name,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (_, __) {},
                child: Icon(Icons.person, size: 24.sp, color: Colors.grey),
              ),
              // Online dot (optional)
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: Container(
              //     width: 10.w,
              //     height: 10.w,
              //     decoration: BoxDecoration(
              //       color: const Color(0xFF0FE16D),
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.white, width: 1.5),
              //     ),
              //   ),
              // ),
            ],
          ),

          SizedBox(width: 12.w),

          // Name & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          trailing,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ✅ Add Button
  // ─────────────────────────────────────────────
  Widget _buildAddButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 14.sp,
              color: Colors.white,
            ),
            SizedBox(width: 5.w),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_remove_outlined,
              size: 14.sp,
              color: Colors.redAccent,
            ),
            SizedBox(width: 5.w),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}