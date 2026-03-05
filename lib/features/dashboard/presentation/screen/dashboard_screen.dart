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
                  _buildHeader(),
                  SizedBox(height: 20.h),
                  _buildStatsGrid(controller),
                  SizedBox(height: 24.h),
                  const CommonText(
                    text: 'My Active Ads',
                    textAlign: TextAlign.left,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                  ),
                  SizedBox(height: 16.h),
                  controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.activeAds.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No active ads found"),
                    ),
                  )
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
                      return SizedBox(height: 8.h);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return GetBuilder<ProviderProfileViewController>(
      builder: (ctrl) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ Profile section
            GestureDetector(
              onTap: () {
                ctrl.getAdvertiserData();
                Get.to(() => const DashBoardProfile());
              },
              child: Row(
                children: [
                  Container(
                    height: 40.w,
                    width: 40.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: ClipOval(
                      child: CommonImage(
                        imageSrc: "${ApiEndPoint.imageUrl}${ctrl.businessLogo}",
                        fill: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: ctrl.businessName,
                        textAlign: TextAlign.left,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColorFirst,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.location,
                            height: 14.w,
                            width: 14.w,
                          ),
                          SizedBox(width: 4.w),
                          const CommonText(
                            text: 'Thomridge Cir. Shiloh, Hawaii',
                            textAlign: TextAlign.left,
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //Notification bell with badge==================================

            GetBuilder<NotificationsController>(
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
                          height: 34.w,
                          width: 34.w,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            size: 20.w,
                            color: AppColors.textColorFirst,
                          ),
                        ),
                        // ✅ Badge
                        if (notifController.unreadCount.value > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${notifController.unreadCount.value}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(DashBoardScreenController controller) {
    final data = controller.overviewData.value;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 156 / 82,
      children: [
        _StatsCard(title: 'Active Ads', value: data.totalActiveAds.toString()),
        _StatsCard(title: 'Ads Reach', value: data.totalReachCount.toString()),
        _StatsCard(
          title: 'Engagement',
          value: '${data.engagementRate.toStringAsFixed(2)}%',
        ),
        _StatsCard(title: 'Ads Click', value: data.totalClickCount.toString()),
      ],
    );
  }

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
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: CommonImage(
                imageSrc: image,
                height: 140.h,
                width: double.infinity,
                fill: BoxFit.fill,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: title,
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                  ),
                  SizedBox(height: 6.h),
                  CommonText(
                    text: description,
                    textAlign: TextAlign.left,
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    maxLines: 3,
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

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatsCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(
            text: title,
            textAlign: TextAlign.left,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 4.h),
          CommonText(
            text: value,
            textAlign: TextAlign.left,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textColorFirst,
          ),
        ],
      ),
    );
  }
}