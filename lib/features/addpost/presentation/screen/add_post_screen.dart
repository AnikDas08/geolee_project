import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/app_bar/custom_appbar.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/addpost/presentation/controller/post_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'dart:io';

class AddPostScreen extends StatelessWidget {
  AddPostScreen({super.key});
  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Get.offAllNamed(AppRoutes.homeNav);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(title: "Create Clicker", showBackButton: true,onBackTap: (){
                    Get.offAllNamed(AppRoutes.homeNav);
                  },),
                  SizedBox(height: 20.h),

                  // Upload Image Section
                  CommonText(
                    text: "Upload Images",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 10.h),
                  Obx(() => _buildImageUploadSection(context)),
                  SizedBox(height: 20.h),

                  // Description
                  CommonText(
                    text: "Description",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 5.h),
                  _buildTextField(
                    controller: controller.description,
                    hintText: "About The Role...",
                    maxLines: 5,
                  ),
                  SizedBox(height: 16.h),

                  // ✅ FIXED: Pricing / Fee Options with proper layout
                  CommonText(
                    text: "Select Clicker",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: 6.h),
                  Obx(
                        () => Column(
                      children: [
                        // First Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildPricingOption(
                                title: "Great Vibes",
                                isSelected: controller.selectedPricingOption.value == 'Great Vibes',
                                onTap: () => controller.selectPricingOption('Great Vibes'),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildPricingOption(
                                title: "Off Vibes",
                                isSelected: controller.selectedPricingOption.value == 'Off Vibes',
                                onTap: () => controller.selectPricingOption('Off Vibes'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Second Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildPricingOption(
                                title: "Charming Gentleman",
                                isSelected: controller.selectedPricingOption.value == 'Charming Gentleman',
                                onTap: () => controller.selectPricingOption('Charming Gentleman'),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildPricingOption(
                                title: "Lovely Lady",
                                isSelected: controller.selectedPricingOption.value == 'Lovely Lady',
                                onTap: () => controller.selectPricingOption('Lovely Lady'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      titleText: controller.isLoading.value ? "Posting..." : "CLICKER COUNT",
                      buttonColor: AppColors.primaryColor,
                      buttonRadius: 8,
                      onTap: () => controller.createPost(),
                    );
                  }),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Image Upload Section
  Widget _buildImageUploadSection(BuildContext context) {
    final images = controller.selectedImages;
    final maxImages = controller.maxImages;
    final bool canAddMore = images.length < maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of Selected Images
        if (images.isNotEmpty)
          _buildSelectedImagesGrid(context, images, maxImages),

        SizedBox(height: images.isNotEmpty ? 16.h : 0),

        // Add Image Buttons (only show if more can be added)
        if (canAddMore)
          Row(
            children: [
              Expanded(
                child: _buildImageOptionButton(
                  title: "Gallery",
                  imageSrc: AppIcons.upload2,
                  onTap: () => controller.pickImageFromGallery(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildImageOptionButton(
                  title: "Camera",
                  imageSrc: AppIcons.camera,
                  onTap: () => controller.pickImageFromCamera(),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Grid View for Selected Images
  Widget _buildSelectedImagesGrid(
      BuildContext context, List<File> images, int max) {
    // Add an empty spot if we haven't reached the max limit
    int itemCount = images.length;
    bool showEmptySlot = images.length < max;
    if (showEmptySlot) {
      itemCount += 1; // For the "Add More" slot
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "Selected: (${images.length}/$max)",
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecond,
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            if (index < images.length) {
              return _buildImageThumbnail(
                file: images[index],
                onRemove: () => controller.removeImageAtIndex(index),
              );
            } else {
              // This is the empty slot for adding more
              return _buildAddMoreSlot(context);
            }
          },
        ),
      ],
    );
  }

  // Add More slot
  Widget _buildAddMoreSlot(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  text: "Add Image",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 20.h),
                _buildImageOptionButton(
                  title: "Upload from Gallery",
                  imageSrc: AppIcons.upload2,
                  onTap: () {
                    controller.pickImageFromGallery();
                    Get.back();
                  },
                ),
                SizedBox(height: 10.h),
                _buildImageOptionButton(
                  title: "Take a Photo",
                  imageSrc: AppIcons.camera,
                  onTap: () {
                    controller.pickImageFromCamera();
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(8.r),
        dashPattern: const [6, 3],
        color: AppColors.textSecond,
        strokeWidth: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(Icons.add_a_photo_outlined,
                size: 28.sp, color: AppColors.textSecond),
          ),
        ),
      ),
    );
  }

  // Individual Image Thumbnail with Remove Button
  Widget _buildImageThumbnail({
    required File file,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              file,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Image Option Button
  Widget _buildImageOptionButton({
    required String title,
    required String imageSrc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
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
            CommonImage(imageSrc: imageSrc, height: 28.h),
            SizedBox(height: 8.h),
            CommonText(
              text: title,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // Text Field
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

  // Dropdown
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
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(4.r),

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

  // Pricing Option Button
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
}