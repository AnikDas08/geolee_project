import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/ads/presentation/screen/edit_ads_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../config/api/api_end_point.dart';
import '../controller/view_ads_screen_controller.dart';
import '../../data/single_ads_model.dart';

class ViewAdsScreen extends StatelessWidget {
  final bool? isFromHistory;

  const ViewAdsScreen({super.key, this.isFromHistory = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewAdsScreenController>(
      init: ViewAdsScreenController(),
      builder: (controller) {
        if (controller.isLoading) {
          return _buildSkeletonScreen();
        }

        final SingleAdvertisement? ad = controller.ad;

        if (ad == null) {
          return const Scaffold(body: Center(child: Text("No Ad Found")));
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //===================stats section===========================
                _buildStatsSection(ad),

                //===================ad image section===========================
                _buildAdImageSection(ad),

                //===================content section===========================
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(ad),
                      SizedBox(height: 24.h),
                      _buildDetailsSection(ad),
                      SizedBox(height: 32.h),
                      _buildActionButtons(controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //====================app bar===========================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(Get.context!).pop(),
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
      ),
      backgroundColor: AppColors.background,
    );
  }

  //====================stats section===========================
  Widget _buildStatsSection(SingleAdvertisement ad) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.5),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            label: 'Ad Clicks',
            value: ad.clickCount.toString(),
            icon: Icons.touch_app_outlined,
          ),
          _buildStatCard(
            label: 'Ads Reach',
            value: ad.reachCount.toString(),
            icon: Icons.visibility_outlined,
          ),
        ],
      ),
    );
  }

  //====================stat card===========================
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            CommonText(
              text: value,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 4.h),
            CommonText(
              text: label,
              fontSize: 12,
              color: AppColors.textSecond,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  //====================ad image section===========================
  Widget _buildAdImageSection(SingleAdvertisement ad) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            Image.network(
              "${ad.image.startsWith('http') ? ad.image : ApiEndPoint.imageUrl + ad.image}",
              height: 220.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  AppImages.banner2,
                  height: 220.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
            //===================status badge===========================
            Positioned(
              top: 12.w,
              right: 12.w,
              child: _buildStatusBadge(ad.status),
            ),
          ],
        ),
      ),
    );
  }

  //====================status badge===========================
  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: CommonText(
        text: status,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  //====================title section===========================
  Widget _buildTitleSection(SingleAdvertisement ad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: ad.title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.left,
          color: AppColors.black,
        ),
        SizedBox(height: 10.h),
        CommonText(
          text: ad.description,
          fontSize: 14,
          color: AppColors.textSecond,
          textAlign: TextAlign.left,

        ),
      ],
    );
  }

  //====================details section===========================
  Widget _buildDetailsSection(SingleAdvertisement ad) {
    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: ad.focusArea,
          color: Colors.blue,
        ),
        SizedBox(height: 12.h),
        _buildDetailCard(
          icon: Icons.calendar_today_outlined,
          label: 'Start Date',
          value: ad.startAt.toLocal().toString().split(' ')[0],
          color: Colors.green,
        ),
        SizedBox(height: 12.h),
        _buildDetailCard(
          icon: Icons.event_available_outlined,
          label: 'End Date',
          value: ad.endAt.toLocal().toString().split(' ')[0],
          color: Colors.orange,
        ),
        SizedBox(height: 12.h),
        _buildDetailCard(
          icon: Icons.attach_money_outlined,
          label: 'Price',
          value: 'S\$${ad.price}',
          color: AppColors.primaryColor,
          isPrice: true,
        ),
        SizedBox(height: 12.h),
        _buildDetailCard(
          icon: Icons.language_outlined,
          label: 'Website',
          value: ad.websiteUrl,
          color: Colors.purple,
          isLink: true,
        ),
      ],
    );
  }

  //====================detail card===========================
  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLink = false,
    bool isPrice = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          //===================icon section===========================
          Container(
            height: 44.h,
            width: 44.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          //===================text section===========================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonText(
                  text: label,
                  fontSize: 14,
                  color: AppColors.textSecond,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                CommonText(
                  text: value,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isPrice ? AppColors.primaryColor : AppColors.black,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //====================action buttons===========================
  Widget _buildActionButtons(ViewAdsScreenController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildOutlineButton(
            label: 'Delete Ads',
            onTap: () => _showDeleteDialog(controller),
            color: AppColors.red,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildSolidButton(
            label: 'Edit Ads',
            onTap: () {
              Get.to(EditAdsScreen(), arguments: controller.ad!.id);
            },
            color: AppColors.red,
          ),
        ),
      ],
    );
  }

  //====================outline button===========================
  Widget _buildOutlineButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: CommonText(
            text: label,
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  //====================solid button===========================
  Widget _buildSolidButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CommonText(
            text: label,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  //====================delete dialog===========================
  void _showDeleteDialog(ViewAdsScreenController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56.h,
                width: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.red,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              const CommonText(
                text: "Delete Ad?",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              CommonText(
                text: "This action cannot be undone.",
                fontSize: 13,
                color: AppColors.textSecond,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.background.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Center(
                          child: CommonText(
                            text: "Cancel",
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Get.back();
                        await controller.deleteAdsById();
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.red.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: CommonText(
                            text: "Delete",
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonScreen() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.black),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats skeleton
            Container(
              color: AppColors.background.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100.h,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 100.h,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Image skeleton
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                height: 220.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            // Details skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20.h, width: 200.w, color: Colors.grey.shade300),
                  SizedBox(height: 10.h),
                  Container(height: 14.h, width: double.infinity, color: Colors.grey.shade300),
                  SizedBox(height: 6.h),
                  Container(height: 14.h, width: 250.w, color: Colors.grey.shade300),
                  SizedBox(height: 24.h),
                  Container(height: 60.h, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12.r))),
                  SizedBox(height: 12.h),
                  Container(height: 60.h, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12.r))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}