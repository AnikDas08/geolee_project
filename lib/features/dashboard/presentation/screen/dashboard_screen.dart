import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/ads/presentation/screen/view_ads_screen.dart';

import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../../utils/constants/app_images.dart';
import '../../../advertise/presentation/screen/provider_profile_view_screen.dart';
import '../../../profile/presentation/screen/dashboard_profile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                _buildStatsGrid(),
                SizedBox(height: 24.h),
                const CommonText(
                  text: 'My Active Ads',
                  textAlign: TextAlign.left,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorFirst,
                ),
                SizedBox(height: 16.h),
                _buildAdCard(
                  image: AppImages.banner1,
                  title: 'Delicious Fast Food',
                  description:
                      'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavour From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps.',
                  onTap: () {
                    Get.to(() => ViewAdsScreen());
                  },
                ),
                SizedBox(height: 16.h),
                _buildAdCard(
                  image: AppImages.banner2,
                  title: 'Delicious Fast Food',
                  description:
                      'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavour From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps.',
                  onTap: () {
                    Get.to(() => ViewAdsScreen());
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: (){
            print("My Role Is :===========================${LocalStorage.myRole.toString()}");
            Get.to(() => const DashBoardProfile());
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40.w,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: CommonImage(
                    imageSrc: AppImages.logo,
                    borderRadius: 12.r,
                    size: 28.w,
                    fill: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText(
                    text: 'Fast Food Company',
                    textAlign: TextAlign.left,
                    fontSize: 16,
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
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 156 / 82,
      children: const [
        _StatsCard(title: 'Active Ads', value: '05'),
        _StatsCard(title: 'Ads Reach', value: '5,960'),
        _StatsCard(title: 'Engagement', value: '95%'),
        _StatsCard(title: 'Ads Click', value: '1,560'),
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
              color: Colors.black.withOpacity(0.04),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                  ),
                  SizedBox(height: 6.h),
                  CommonText(
                    text: description,
                    textAlign: TextAlign.left,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
