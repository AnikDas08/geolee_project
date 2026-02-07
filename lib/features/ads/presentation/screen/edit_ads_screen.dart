import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/features/ads/presentation/controller/update_ads_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';

class EditAdsScreen extends StatelessWidget {
  EditAdsScreen({super.key});

  final UpdateAdsController controller = Get.put(UpdateAdsController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAllNamed(AppRoutes.homeNav);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Get.offAllNamed(AppRoutes.homeNav),
            child: const Icon(Icons.arrow_back_ios),
          ),
          title: const CommonText(
            text: 'Edit Ads',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: GetBuilder<UpdateAdsController>(
            builder: (_) {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -------- IMAGE --------
                      Obx(
                            () => _buildSelectedImage(
                          imagePath: "${ApiEndPoint.imageUrl+controller.coverImagePath.value}",
                          onTap: controller.pickImage,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      _label('Ads Title'),
                      CommonTextField(
                        controller: controller.titleController,
                        hintText: 'Delicious Fast Food',
                      ),
                      SizedBox(height: 14.h),

                      _label('Description'),
                      CommonTextField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        hintText: 'Description...',
                      ),
                      SizedBox(height: 14.h),

                      _label('Focus Area'),
                      CommonTextField(
                        controller: controller.focusAreaController,
                        hintText: 'California, New York',
                      ),
                      SizedBox(height: 14.h),

                      _label('Website Link'),
                      CommonTextField(
                        controller: controller.websiteLinkController,
                        hintText: 'www.website.com',
                      ),
                      SizedBox(height: 20.h),

                      /// -------- PRICING (READ ONLY) --------
                      _label('Selected Pricing Plan'),
                      SizedBox(height: 8.h),
                      _pricingCards(),
                      SizedBox(height: 6.h),

                      CommonText(
                        text: 'Pricing plan cannot be changed',
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),

                      SizedBox(height: 16.h),

                      /// -------- DATE PICKER (FIXED) --------
                      _label('Ad Start Date'),
                      GestureDetector(
                        onTap: () => controller.selectDate(
                          context,
                          controller.adStartDateController,
                        ),
                        child: AbsorbPointer(
                          child: CommonTextField(
                            controller: controller.adStartDateController,
                            hintText: 'Select start date',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              size: 20.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      CommonButton(
                        onTap: controller.updateAds,
                        titleText: 'Update Ads',
                        buttonColor: AppColors.primaryColor,
                        titleColor: AppColors.white,
                        buttonHeight: 44.h,
                        buttonRadius: 8.r,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// -------- IMAGE (FIXED) --------
  Widget _buildSelectedImage({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: imagePath.isEmpty
              ? Border.all(color: Colors.grey.shade300)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: imagePath.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage(imageSrc: AppIcons.upload2),
              SizedBox(height: 10.h),
              CommonText(
                text: 'Upload Cover Image',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ],
          )

              : (imagePath.contains('http') || imagePath.contains('https'))
              ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          )
              : Image.file(File(imagePath), fit: BoxFit.cover),
        ),
      ),
    );
  }

  /// -------- PRICING (LOCKED) --------
  Widget _pricingCards() {
    return Obx(() {
      return Column(
        children: [
          _priceCard('weekly', '\$10 / Weekly'),
          SizedBox(height: 12.h),
          _priceCard('monthly', '\$50 / Monthly'),
        ],
      );
    });
  }

  Widget _priceCard(String value, String price) {
    final bool isSelected = controller.selectedPricingPlan.value == value;

    return Opacity(
      opacity: 0.7,
      child: Card(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              IgnorePointer(
                child: Radio<String>(
                  value: value,
                  groupValue: controller.selectedPricingPlan.value,
                  onChanged: null, // 🔒 disabled
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: CommonText(
        text: text,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
    );
  }
}