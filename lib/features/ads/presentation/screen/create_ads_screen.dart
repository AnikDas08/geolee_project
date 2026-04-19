import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/helpers/other_helper.dart';

import '../../../../config/route/app_routes.dart';
import '../controller/create_add_controller.dart';

class CreateAdsScreen extends StatefulWidget {
  const CreateAdsScreen({super.key});

  @override
  State<CreateAdsScreen> createState() => _CreateAdsScreenState();
}

class _CreateAdsScreenState extends State<CreateAdsScreen> {
  final CreateAdsController controller = Get.put(CreateAdsController());

  @override
  void initState() {
    super.initState();
    controller.fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAllNamed(AppRoutes.homeNav);
      },
      child: GestureDetector(
        // Suggestions বন্ধ করতে outside tap detect করা
        onTap: () => controller.clearSuggestions(),
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
              text: 'Create Ads',
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
                        // --- Image Upload Section ---
                        Obx(() {
                          return _buildselectedImage(
                            context: context,
                            imagePath: controller.coverImagePath.value,
                            onTap: controller.pickImage,
                          );
                        }),
                        SizedBox(height: 4.h,),

                        CommonText(text: 'Recommended 15:7 (750 x 350 pixels )',fontSize: 10.sp,),
                        SizedBox(height: 16.h),

                        // --- Ads Title ---
                        _buildLabel('Ads Title'),
                        SizedBox(height: 6.h),
                        CommonTextField(
                          controller: controller.titleController,
                          hintText: 'Enter Ads Title',
                        ),
                        SizedBox(height: 14.h),

                        // --- Description ---
                        _buildLabel('Description'),
                        SizedBox(height: 6.h),
                        CommonTextField(
                          controller: controller.descriptionController,
                          hintText: 'Enter your Ads description',
                          maxLines: 3,
                        ),
                        SizedBox(height: 14.h),

                        // --- Focus Area with Autocomplete ---
                        _buildLabel('Focus Area'),
                        SizedBox(height: 6.h),
                        _buildFocusAreaField(),
                        SizedBox(height: 14.h),

                        // --- Website Link ---
                        _buildLabel('Website Link'),
                        SizedBox(height: 6.h),
                        CommonTextField(
                          validator: OtherHelper.urlValidator,
                          controller: controller.websiteLinkController,
                          hintText: ' e.g https//:www.website.com',
                        ),
                        SizedBox(height: 20.h),

                        // --- Pricing Plan Selection ---
                        _buildLabel('Select Pricing Plan'),
                        SizedBox(height: 10.h),
                        _buildPricingCards(controller),
                        SizedBox(height: 16.h),

                        // --- Ad Start Date ---
                        Obx(() {
                          if (controller.selectedPricingPlan.value.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Ad Start Date'),
                                SizedBox(height: 6.h),
                                CommonTextField(
                                  controller: controller.adStartDateController,
                                  hintText: 'Select start date',
                                  suffixIcon: GestureDetector(
                                    onTap: () => controller.selectDate(
                                      context,
                                      controller.adStartDateController,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primaryColor,
                                      size: 20.sp,
                                    ),
                                  ),
                                  onTap: () => controller.selectDate(
                                    context,
                                    controller.adStartDateController,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }),

                        // --- Submit Button ---
                        Obx(
                              () => CommonButton(
                            isLoading: controller.isLoading.value,
                            onTap: () => controller.createAds(),
                            titleText: 'Submit',
                            buttonHeight: 44.h,
                            buttonRadius: 8.r,
                            titleSize: 16,
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Focus Area — Autocomplete Dropdown ============================
  Widget _buildFocusAreaField() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TextField
          CommonTextField(
            controller: controller.focusAreaController,
            hintText: "Select focus area",
            onChanged: (value) {
              controller.searchPlaces(value);
            },
            suffixIcon: Obx(() {
              // Loading indicator দেখাও
              if (controller.isLoadingSuggestions.value) {
                return Padding(
                  padding: EdgeInsets.all(12.r),
                  child: SizedBox(
                    width: 12.w,
                    height: 12.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }

              if (controller.selectedLatitude.value.isNotEmpty &&
                  controller.selectedLatitude.value != '0.0') {
                return Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16.sp,
                );
              }
              return Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryColor,
                size: 20.sp,
              );
            }),
          ),

          // Suggestions Dropdown
          if (controller.placeSuggestions.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.placeSuggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  final place = controller.placeSuggestions[index];
                  return InkWell(
                    onTap: () => controller.selectPlace(place),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place['main_text'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  place['description'] ?? '',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          Obx(() {
            if (controller.selectedLatitude.value.isNotEmpty &&
                controller.selectedLatitude.value != '0.0') {
              return Padding(
                padding: EdgeInsets.only(top: 4.h, left: 4.w),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed, size: 12.sp, color: Colors.green),
                    SizedBox(width: 4.w),
                    Text(
                      'Lat: ${double.parse(controller.selectedLatitude.value).toStringAsFixed(4)}, '
                          'Lng: ${double.parse(controller.selectedLongitude.value).toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      );
    });
  }

  // Pricing Cards ===================
  Widget _buildPricingCards(CreateAdsController controller) {
    return Obx(() {
      if (controller.isPlansLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.plans.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'No pricing plans available',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => controller.fetchPlans(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: List.generate(controller.plans.length, (index) {
          final plan = controller.plans[index];
          final isSelected = controller.selectedPricingPlan.value == plan.name;

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () => controller.selectPricingPlan(plan.name),
              child: Card(
                elevation: 2,
                color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: plan.name,
                        groupValue: controller.selectedPricingPlan.value,
                        onChanged: (value) {
                          if (value != null) controller.selectPricingPlan(value);
                        },
                        activeColor: Colors.blue,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ad Price:',
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${plan.price.toStringAsFixed(2)}/${plan.name}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.sp,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildselectedImage({
    required BuildContext context,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    if (imagePath.isNotEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120.h,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CommonImage(imageSrc: AppIcons.upload2),
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
      textAlign: TextAlign.left,
    );
  }
}