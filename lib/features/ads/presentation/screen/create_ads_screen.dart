import 'dart:io'; // Needed for File image display
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';

import '../controller/create_add_controller.dart';

class CreateAdsScreen extends StatelessWidget {
  const CreateAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final CreateAdsController controller = Get.put(CreateAdsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        // Since you used SizedBox(), I'll assume you don't want a back button here
        leading: const SizedBox(),
        title: const CommonText(
          text: 'Create Ads',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 12.h,
                  bottom: 16.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Image Upload Section (Wrapped in Obx) ---
                    Obx(() {
                      return _buildselectedImage(
                        context: context,
                        imagePath: controller.coverImagePath.value,
                        onTap: controller.pickImage,
                      );
                    }),
                    SizedBox(height: 16.h),

                    // --- Ads Title ---
                    _buildLabel('Ads Title'),
                    SizedBox(height: 6.h),
                    CommonTextField(
                      controller: controller.titleController, // Use controller
                      hintText: 'Delicious Fast Food',
                    ),
                    SizedBox(height: 14.h),

                    // --- Description ---
                    _buildLabel('Description'),
                    SizedBox(height: 6.h),
                    CommonTextField(
                      controller: controller.descriptionController, // Use controller
                      hintText:
                      'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavor...',
                      maxLines: 3,
                    ),
                    SizedBox(height: 14.h),

                    // --- Focus Area ---
                    _buildLabel('Focus Area'),
                    SizedBox(height: 6.h),
                    CommonTextField(
                      controller: controller.focusAreaController, // Use controller
                      hintText: 'California, New York',
                    ),
                    SizedBox(height: 14.h),

                    // --- Date Fields (Start/End) ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Date'),
                              SizedBox(height: 6.h),
                              CommonTextField(
                                controller: controller.startDateController, // Use controller
                                hintText: '01 Jan 2020',
                                //readOnly: true, // Make it read-only
                                onTap: () => controller.selectDate(context, controller.startDateController), // Add onTap for date picker
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppColors.textSecond,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('End Date'),
                              SizedBox(height: 6.h),
                              CommonTextField(
                                controller: controller.endDateController, // Use controller
                                hintText: '01 Jan 2020',
                                //readOnly: true, // Make it read-only
                                onTap: () => controller.selectDate(context, controller.endDateController), // Add onTap for date picker
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppColors.textSecond,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // --- Time Fields (Start/End) ---
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Time'),
                              SizedBox(height: 6.h),
                              CommonTextField(
                                controller: controller.startTimeController, // Use controller
                                hintText: '10:00 AM',
                                //readOnly: true, // Make it read-only
                                onTap: () => controller.selectTime(context, controller.startTimeController), // Add onTap for time picker
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: AppColors.textSecond,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('End Time'),
                              SizedBox(height: 6.h),
                              CommonTextField(
                                controller: controller.endTimeController, // Use controller
                                hintText: '10:00 PM',
                                //readOnly: true, // Make it read-only
                                onTap: () => controller.selectTime(context, controller.endTimeController), // Add onTap for time picker
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: AppColors.textSecond,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // --- Website Link ---
                    _buildLabel('Website Link'),
                    SizedBox(height: 6.h),
                    CommonTextField(
                      controller: controller.websiteLinkController, // Use controller
                      hintText: 'www.website.com/restaurant',
                    ),
                    SizedBox(height: 20.h),

                    // --- Submit Button ---
                    CommonButton(
                      onTap: () => controller.submitAd(context), // Use controller method
                      titleText: 'Submit',
                      buttonColor: AppColors.primaryColor,
                      titleColor: AppColors.white,
                      borderColor: AppColors.primaryColor,
                      buttonHeight: 44.h,
                      buttonRadius: 8.r,
                      titleSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for the upload area
  Widget _buildselectedImage({
    required BuildContext context,
    required String imagePath, // Now takes the path string
    required VoidCallback onTap,
  }) {
    // If an image is selected, display it using Image.file
    if (imagePath.isNotEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120.h,
            ),
          ),
        ),
      );
    }

    // If no image is selected, display the default upload UI
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
            CommonImage(imageSrc: AppIcons.upload2), // Use your default upload icon
            SizedBox(height: 12.h),
            CommonText(
              text: 'Upload Cover Image',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CommonText(
      text: text,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
      textAlign: TextAlign.left,
    );
  }
}