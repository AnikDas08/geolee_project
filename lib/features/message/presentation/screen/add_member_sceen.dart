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
    // We use Get.put here to ensure the controller is initialized when this screen opens
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
        if (controller.isLoading.value && controller.currentMembers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar Section ---
            _buildSearchSection(controller),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Search Results (Global Users) ---
                    if (controller.searchKeyword.isNotEmpty)
                      _buildSearchResults(controller),

                    // --- Divider ---
                    if (controller.searchKeyword.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Divider(height: 1.h, color: Colors.grey.shade200),
                      ),

                    // --- Current Members List ---
                    _buildCurrentMembersList(controller),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchSection(AddMemberController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            text: 'Invite Friends',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 8.h),
          TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search user',
              prefixIcon: Icon(Icons.search, size: 20.sp),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AddMemberController controller) {
    if (controller.searchResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: const CommonText(text: "No users found to add", fontSize: 12, color: Colors.grey),
      );
    }

    return Column(
      children: controller.searchResults.map((user) {
        return _UserTile(
          name: user.name,
          image: user.image,
          actionWidget: ElevatedButton(
            onPressed: () => controller.onAddMember(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: Size(60.w, 30.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              elevation: 0,
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentMembersList(AddMemberController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: CommonText(
            text: 'Group Members (${controller.currentMembers.length})',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: controller.currentMembers.length,
          itemBuilder: (context, index) {
            final member = controller.currentMembers[index];
            return _UserTile(
              name: member.name,
              image: member.image,
              actionWidget: IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade300, size: 22.sp),
                onPressed: () => controller.showRemoveMemberDialog(member),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _UserTile({required String name, required String image, required Widget actionWidget}) {
    // Construct full image URL
    final imageUrl = image.startsWith('http') ? image : "${ApiEndPoint.imageUrl}$image";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (e, s) => const Icon(Icons.person),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CommonText(text: name, fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
          actionWidget,
        ],
      ),
    );
  }
}