import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/pop_up/common_pop_menu.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';

class CreateAdsScreen extends StatelessWidget {
  const CreateAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: SizedBox(),
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
                    _buildselectedImage(
                      context: context,
                      title: 'Upload Cover Image',
                      imageSrc: AppIcons.upload2,
                      onTap: () {},
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Ads Title'),
                    SizedBox(height: 6.h),
                    const CommonTextField(hintText: 'Delicious Fast Food'),
                    SizedBox(height: 14.h),
                    _buildLabel('Description'),
                    SizedBox(height: 6.h),
                    const CommonTextField(
                      hintText:
                          'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavor From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps',
                      maxLines: 3,
                    ),
                    SizedBox(height: 14.h),
                    _buildLabel('Focus Area'),
                    SizedBox(height: 6.h),
                    const CommonTextField(hintText: 'California, New York'),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Date'),
                              SizedBox(height: 6.h),
                              const CommonTextField(
                                hintText: '01 Jan 2020',
                                suffixIcon: Icon(
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
                              const CommonTextField(
                                hintText: '01 Jan 2020',
                                suffixIcon: Icon(
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Time'),
                              SizedBox(height: 6.h),
                              const CommonTextField(
                                hintText: '01 Jan 2020',
                                suffixIcon: Icon(
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
                              const CommonTextField(
                                hintText: '01 Jan 2020',
                                suffixIcon: Icon(
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
                    _buildLabel('Website Link'),
                    SizedBox(height: 6.h),
                    const CommonTextField(
                      hintText: 'www.website.com/restaurant',
                    ),
                    SizedBox(height: 20.h),
                    CommonButton(
                      onTap: () {
                        successPopUps(
                          message:
                              'Your Asd Submit successful. Please wait for admin approval before your ad goes live.',
                          onTap: () {
                            Get.back();
                          },
                          buttonTitle: 'Done',
                        );
                      },
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
