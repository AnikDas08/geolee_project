import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/ads/presentation/screen/edit_ads_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class ViewAdsScreen extends StatelessWidget {
  final bool? isFromHistory;
  const ViewAdsScreen({super.key, this.isFromHistory = false});
  void showDeletePostDialog(
      BuildContext context,

      ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Text changed to 'delete this post'
          title: Text(
            textAlign: TextAlign.center,
            'Are you sure you want to delete this post?',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 'No' Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('No', style: TextStyle(color: Colors.black54)),
                  ),
                ),

                const SizedBox(width: 12),

                // 'Yes' Button (Confirmation)
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar('Success', 'Post deleted successfully');
                    Get.offNamed(AppRoutes.homeNav);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        );
      },
    );
  }


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
          child: Column(
            children: [
              if (isFromHistory == true) _buildStatsGrid(),
              Container(
                // ... (Container content remains the same)
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
                      if (isFromHistory == false)
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton(
                                // 3. The corrected call to the dialog function
                                onTap: () {
                                  showDeletePostDialog(context,);
                                },
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
            ],
          ),
        ),
      ),
    );
  }

  // ... (Other helper methods _buildInfoRow, _buildStatsGrid, _StatsCard)
  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isLink = false,
  }) {
    // ... (implementation)
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

  Widget _buildStatsGrid() {
    // ... (implementation)
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 156 / 82,
      children: const [
        _StatsCard(title: 'Ads Click', value: '1,560'),
        _StatsCard(title: 'Ads Reach', value: '5,960'),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatsCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white /* White-BG */,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          CommonText(
            text: title,
            textAlign: TextAlign.left,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 4.h),
          CommonText(
            text: value,
            textAlign: TextAlign.left,
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorFirst,
          ),
        ],
      ),
    );
  }
}