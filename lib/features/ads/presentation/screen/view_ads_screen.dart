import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/ads/data/add_history_model.dart';
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final SingleAdvertisement? ad = controller.ad;

        if (ad == null) {
          return const Scaffold(
            body: Center(
              child: Text("No Ad Found"),
            ),
          );
        }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    
                    SizedBox(
                      height: 78.h,
                      width: 170.w,
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              CommonText(text: "Adc Click"),
                              CommonText(text: "5210"),
                            ],
                          ),
                        ),
                      ),
                    )
                    
                    
                    
                    
                  ],
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    "${ad.image.startsWith('http') ? ad.image : ApiEndPoint.imageUrl + ad.image}",
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppImages.banner2,
                        height: 200.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                CommonText(
                  text: ad.title,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8.h),
                CommonText(
                  text: ad.description,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecond,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(label: 'Location:', value: ad.focusArea),
                _buildInfoRow(label: 'Status:', value: ad.status),
                _buildInfoRow(label: 'Start Date:', value: ad.startAt.toLocal().toString().split(' ')[0]),
                _buildInfoRow(label: 'End Date:', value: ad.endAt.toLocal().toString().split(' ')[0]),
                _buildInfoRow(label: 'Price:', value: "\$${ad.price}"),
                _buildInfoRow(label: 'Website:', value: ad.websiteUrl, isLink: true),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
      child: Row(
        children: [
          CommonText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: CommonText(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isLink ? AppColors.primaryColor : AppColors.textSecond,
            ),
          ),
        ],
      ),
    );
  }
}
