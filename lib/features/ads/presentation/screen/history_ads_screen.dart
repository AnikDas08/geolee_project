import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/ads/presentation/controller/history_ads_controller.dart';
import 'package:giolee78/features/ads/presentation/screen/view_ads_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import '../../../../config/api/api_end_point.dart';

class HistoryAdsScreen extends StatelessWidget {
  const HistoryAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryAdsController>(
      init: HistoryAdsController(),
      builder: (controller) {
        final ads = controller.currentAds;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.black,
                size: 18,
              ),
            ),
            title: const CommonText(
              text: 'Ads History',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              textAlign: TextAlign.center,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(controller),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                        : ads.isEmpty
                        ? const Center(
                            child: CommonText(
                              text: "No Ads Found",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: ads.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final ad = ads[index];
                              return _HistoryAdCard(
                                imageSrc: "${ApiEndPoint.imageUrl + ad.image}",
                                title: ad.title,
                                description: ad.description,
                                onTap: () {
                                  Get.to(
                                    ViewAdsScreen(),
                                    arguments: ad.id,
                                  )?.then((value) {
                                    if (value == true) {
                                      controller.fetchAds();
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildTabs(HistoryAdsController controller) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: () => controller.changeTab(0),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: controller.selectedTabIndex == 0
                    ? AppColors.primaryColor
                    : AppColors.navBarColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CommonText(
                text: 'All Ads',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: controller.selectedTabIndex == 0
                    ? AppColors.white
                    : AppColors.black,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: () => controller.changeTab(1),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: controller.selectedTabIndex == 1
                    ? AppColors.primaryColor
                    : AppColors.navBarColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CommonText(
                text: 'Active Ads',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: controller.selectedTabIndex == 1
                    ? AppColors.white
                    : AppColors.black,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryAdCard extends StatelessWidget {
  const _HistoryAdCard({
    required this.imageSrc,
    required this.title,
    required this.description,
    this.onTap,
  });

  final String imageSrc;
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  imageSrc,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 12.h),
              CommonText(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
              SizedBox(height: 6.h),
              CommonText(
                text: description,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecond,
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
