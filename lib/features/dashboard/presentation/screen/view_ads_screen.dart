import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/dashboard/presentation/screen/edit_ads_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class ViewAdsScreen extends StatelessWidget {
  const ViewAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 18,
          ),
        ),
        title: const CommonText(
          text: 'View Ads',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      AppImages.banner2,
                      height: 140.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const CommonText(
                    text: 'Delicious Fruit Food',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 8.h),
                  const CommonText(
                    text:
                        'Seafood Treat Carnival. Enjoy Delicious Sea Food, Wholesome Every Bite! Seafood Pasta, Grilled Prawns, Atlas Burgers, And Crispy Wings To Endless Flavors And Tasty Bites.',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecond,
                    textAlign: TextAlign.left,
                    maxLines: 6,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    label: 'Location:',
                    value: 'California Main Park',
                  ),
                  _buildInfoRow(label: 'Status:', value: 'Active'),
                  _buildInfoRow(label: 'Start Date:', value: '28 Sep 2025'),
                  _buildInfoRow(label: 'End Date:', value: '30 Nov 2025'),
                  _buildInfoRow(label: 'Start Time:', value: '10:00 am'),
                  _buildInfoRow(label: 'End Time:', value: '10:00 pm'),
                  _buildInfoRow(
                    label: 'Website:',
                    value: 'www.seafoodheaven.sea-site.com',
                    isLink: true,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          onTap: null,
                          titleText: 'Delete Post',
                          buttonColor: AppColors.white,
                          titleColor: AppColors.primaryColor,
                          borderColor: AppColors.primaryColor,
                          borderWidth: 1,
                          buttonHeight: 44.h,
                          buttonRadius: 8.r,
                          titleSize: 14,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CommonButton(
                          onTap: () {
                            Get.to(() => const EditAdsScreen());
                          },
                          titleText: 'Edit Post',
                          buttonColor: AppColors.primaryColor,
                          titleColor: AppColors.white,
                          borderColor: AppColors.primaryColor,
                          borderWidth: 1,
                          buttonHeight: 44.h,
                          buttonRadius: 8.r,
                          titleSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            textAlign: TextAlign.left,
            maxLines: 1,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: CommonText(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isLink ? AppColors.primaryColor : AppColors.textSecond,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
