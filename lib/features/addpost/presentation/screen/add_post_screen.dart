import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/app_bar/custom_appbar.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/addpost/presentation/controller/post_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';

class AddPostScreen extends StatelessWidget {
  AddPostScreen({super.key});
  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: "Create Post", showBackButton: true),
                SizedBox(height: 20.h),

                // Upload Image Section
                Obx(() {
                  if (controller.selectedImage.value != null) {
                    return _buildimageUpload();
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _buildselectedImage(
                          context: context,
                          title: "Upload Image",
                          imageSrc: AppIcons.upload2,
                          onTap: () => controller.pickImageFromGallery(),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildselectedImage(
                          context: context,
                          title: "Take a Photo",
                          imageSrc: AppIcons.camera,
                          onTap: () => controller.pickImageFromCamera(),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 20.h),

                // Description
                CommonText(
                  text: "Description",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 5.h),
                _buildTextField(
                  controller: controller.descriptionController,
                  hintText:
                      "About The Role\nWe Are Looking For A Skilled And Reliable Plumber To Join Our Team. The Ideal Candidate Will Have Experience In Installing, Repairing, And Monitoring Residential And/Or Commercial Plumbing Systems.",
                  maxLines: 5,
                ),
                SizedBox(height: 16.h),

                // Pricing / Fee Options
                CommonText(
                  text: "Select Clicker",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 6.h),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _buildPricingOption(
                          title: "Great Vibes",
                          isSelected:
                              controller.selectedPricingOption.value ==
                              'Great Vibes',
                          onTap: () =>
                              controller.selectPricingOption('Great Vibes'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildPricingOption(
                          title: "Off Vibes",
                          isSelected:
                              controller.selectedPricingOption.value ==
                              'Off Vibes',
                          onTap: () =>
                              controller.selectPricingOption('Off Vibes'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildPricingOption(
                        title: "Charming Gentleman",
                        isSelected:
                            controller.selectedPricingOption.value ==
                            'Charming Gentleman',
                        onTap: () => controller.selectPricingOption(
                          'Charming Gentleman',
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildPricingOption(
                        title: "Lovely Lady",
                        isSelected:
                            controller.selectedPricingOption.value ==
                            'Lovely Lady',
                        onTap: () =>
                            controller.selectPricingOption('Lovely Lady'),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),

                SizedBox(height: 16.h),

                // Priority Level
                CommonText(
                  text: "Privacy",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => _buildDropdown(
                    value: controller.selectedPriorityLevel.value.isEmpty
                        ? null
                        : controller.selectedPriorityLevel.value,
                    hint: "Select Privacy",
                    items: controller.priorityLevels,
                    onChanged: (value) {
                      controller.selectedPriorityLevel.value = value!;
                    },
                  ),
                ),
                SizedBox(height: 32.h),

                // Post Button
                Obx(() {
                  return CommonButton(
                    titleText: controller.isLoading.value
                        ? "Posting..."
                        : "Post",
                    buttonColor: AppColors.primaryColor,
                    buttonRadius: 8,
                    onTap: controller.isLoading.value
                        ? null
                        : () => controller.createPost(),
                  );
                }),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? suffixIcon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.textSecond),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[600], size: 20.sp)
              : null,
        ),
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    IconData? icon,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.textSecond),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: Colors.grey[700]),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                ),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                items: items.isEmpty
                    ? null
                    : items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                onChanged: items.isEmpty ? null : onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          color: isSelected ? AppColors.primaryColor : Colors.white,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecond,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildimageUpload() {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              controller.selectedImage.value!,
              width: double.infinity,
              height: 150.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () {
                controller.selectedImage.value = null;
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildselectedImage({
    required BuildContext context,
    required String title,
    required String imageSrc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage(imageSrc: imageSrc),
            SizedBox(height: 12.h),
            CommonText(
              text: title,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
