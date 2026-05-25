import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/ads/presentation/screen/view_ads_screen.dart';
import 'package:giolee78/features/notifications/presentation/controller/notifications_controller.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../advertise/presentation/controller/provider_profile_view_controller.dart';
import '../../../profile/presentation/screen/dashboard_profile.dart';
import '../controller/dash_board_screen_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ProviderProfileViewController _providerProfileViewController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProviderProfileViewController>()) {
      _providerProfileViewController = Get.find<ProviderProfileViewController>();
    } else {
      _providerProfileViewController = Get.put(ProviderProfileViewController());
    }
    _providerProfileViewController.getAdvertiserData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardScreenController>(
      init: DashBoardScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //===================header section===========================
                  _buildHeader(),
                  SizedBox(height: 24.h),
                  //===================stats section===========================
                  _buildStatsSection(controller),
                  SizedBox(height: 32.h),
                  //===================my active ads section===========================
                  _buildMyActiveAdsSection(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //===================header section===========================
  Widget _buildHeader() {
    return GetBuilder<ProviderProfileViewController>(
      builder: (ctrl) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //===================profile section===========================
            Expanded(
              child: GestureDetector(
                onTap: () {
                ctrl.getAdvertiserData();
                Get.to(() => const DashBoardProfile());
              },
              child: Row(
                children: [
                  //===================avatar===========================
                  Container(
                    height: 48.w,
                    width: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CommonImage(
                        imageSrc: "${ApiEndPoint.imageUrl}${ctrl.businessLogo}",
                        fill: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  //===================name & location===========================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: ctrl.businessName,
                          textAlign: TextAlign.left,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textColorFirst,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppIcons.location,
                              height: 12.w,
                              width: 12.w,
                              colorFilter: const ColorFilter.mode(
                                AppColors.secondaryText,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: CommonText(
                                // Shorten address to first 2 parts
                                text: ctrl.address.split(',').take(2).join(', '),
                                textAlign: TextAlign.left,
                                fontSize: 11,
                                color: AppColors.secondaryText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
            //===================notification bell===========================
            _buildNotificationBell(),
          ],
        
        );
      },
    );
  }

  //===================notification bell===========================
  Widget _buildNotificationBell() {
    return GetBuilder<NotificationsController>(
      init: Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : Get.put(NotificationsController()),
      builder: (notifController) {
        return Obx(() {
          return GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.notifications),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 40.w,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 20.w,
                    color: AppColors.textColorFirst,
                  ),
                ),
                //===================unread badge===========================
                if (notifController.unreadCount.value > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      height: 22.w,
                      width: 22.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: CommonText(
                          text: "${notifController.unreadCount.value}",
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  //===================stats section===========================
  Widget _buildStatsSection(DashBoardScreenController controller) {
    final data = controller.overviewData.value;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                title: 'Active Ads',
                value: data.totalActiveAds.toString(),
                icon: Icons.campaign_outlined,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatsCard(
                title: 'Ads Reach',
                value: data.totalReachCount.toString(),
                icon: Icons.visibility_outlined,
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                title: 'Engagement',
                value: '${data.engagementRate.toStringAsFixed(2)}%',
                icon: Icons.trending_up_outlined,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _StatsCard(
                title: 'Ad Clicks',
                value: data.totalClickCount.toString(),
                icon: Icons.touch_app_outlined,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  //===================my active ads section===========================
  Widget _buildMyActiveAdsSection(DashBoardScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CommonText(
              text: 'My Active Ads',
              textAlign: TextAlign.left,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorFirst,
            ),
            if (controller.activeAds.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: CommonText(
                  text: '${controller.activeAds.length}',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        //===================ads list===========================
        controller.isLoading.value
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        )
            : controller.activeAds.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.activeAds.length,
          itemBuilder: (context, index) {
            final data = controller.activeAds[index];
            return _buildAdCard(
              image: "${ApiEndPoint.imageUrl}${data.image}",
              title: data.title,
              description: data.description,
              onTap: () {
                Get.to(
                      () => const ViewAdsScreen(),
                  arguments: data.id,
                );
              },
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 12.h);
          },
        ),
      ],
    );
  }

  //===================empty state===========================
  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.background.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 48.sp,
            color: AppColors.secondaryText.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          const CommonText(
            text: "No Active Ads",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 4.h),
          const CommonText(
            text: "Start creating ads to boost your business",
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  //===================ad card===========================
  Widget _buildAdCard({
    required String image,
    required String title,
    required String description,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //===================ad image===========================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: CommonImage(
                    imageSrc: image,
                    height: 200.h,
                    width: double.infinity,
                    fill: BoxFit.cover,
                  ),
                ),
                //===================active badge===========================
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: const CommonText(
                      text: 'Active',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            //===================ad content===========================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: title,
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textColorFirst,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  CommonText(
                    text: description,
                    textAlign: TextAlign.left,
                    fontSize: 11,
                    color: AppColors.secondaryText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//===================stats card component===========================
class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //===================icon===========================
              Container(
                height: 36.h,
                width: 36.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 18.sp,
                  ),
                ),
              ),
              //===================title===========================
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: CommonText(
                    text: title,
                    textAlign: TextAlign.left,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          //===================value===========================
          Align(
            alignment: Alignment.bottomLeft,
            child: CommonText(
              text: value,
              textAlign: TextAlign.left,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textColorFirst,
            ),
          ),
        ],
      ),
    );
  }
}