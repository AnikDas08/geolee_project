import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/extensions/extension.dart';

import '../controller/provider_profile_view_controller.dart';


class ProviderProfileViewScreen extends StatelessWidget {
  const ProviderProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProviderProfileViewController>(
      init: ProviderProfileViewController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.w),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                  size: 20.sp,
                ),
              ),
            ),
            leadingWidth: 50.w,
          ),
          body: SafeArea(
            child: controller.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
                : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    20.height,

                    /// Profile Image
                    _buildProfileImage(controller),

                    16.height,

                    /// Name
                    CommonText(
                      text:controller.businessName,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),

                    32.height,

                    /// About Section
                    _buildAboutSection(controller),

                    24.height,

                    /// Profile Details
                    _buildProfileDetails(controller),

                    32.height,

                    /// Edit Profile Button
                    _buildEditProfileButton(controller),

                    32.height,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Profile Image Widget
  Widget _buildProfileImage(ProviderProfileViewController controller) {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 4.w),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: controller.userImage.isNotEmpty
            ? CommonImage(
          imageSrc: ApiEndPoint.imageUrl + controller.businessLogo,
          width: 120.w,
          height: 120.h,
          fill: BoxFit.cover,
        )
            : CommonImage(
          imageSrc: AppImages.profile,
          width: 120.w,
          height: 120.h,
          fill: BoxFit.cover,
        ),
      ),
    );
  }

  /// About Section Widget - Fixed to show label and content separately
  Widget _buildAboutSection(ProviderProfileViewController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        CommonText(
          text: 'Bio',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.start,
        ),
        8.height,
        // Content (bio)
        CommonText(
          text: controller.advertiserBion,
          fontSize: 14.sp,
          color: AppColors.secondaryText,
          textAlign: TextAlign.start,
          maxLines: 10,
        ),
      ],
    );
  }

  /// Profile Details Widget
  Widget _buildProfileDetails(ProviderProfileViewController controller) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        color: Colors.white
      ),
      child: Column(
        children: [
          // Uncomment if mobile is available in the API
          // _buildDetailRow('Mobile', controller.mobile),
          // 16.height,
          _buildDetailRow('E-mail', controller.userEmail),
          16.height,
          _buildDetailRow('Phone Number', controller.phone),
          16.height,
          _buildDetailRow('Business License Number', controller.businessLicenceNumber),
          16.height,
          _buildDetailRow('Business Type', controller.businessType),
          16.height,
          _buildDetailRow('Address', controller.address,)
            ],
      ),
    );
  }

  /// Detail Row Widget
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(
          text: label,
          fontSize: 14.sp,
          textAlign: TextAlign.start,
        ),
        Flexible(
          child: CommonText(
            text: value.isNotEmpty ? value : 'Not Set',
            fontSize: 14.sp,
            color: AppColors.secondaryText,
            textAlign: TextAlign.end,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  /// Edit Profile Button Widget
  Widget _buildEditProfileButton(ProviderProfileViewController controller) {
    return CommonButton(
      titleText: 'Edit Profile',
      onTap: controller.navigateToEditProfile,
      buttonHeight: 56.h,
      buttonRadius: 8.r,
      titleSize: 16.sp,
    );
  }
}