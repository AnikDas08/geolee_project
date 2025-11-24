import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/route/app_routes.dart';

import '../../../../component/button/common_button.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../../utils/constants/app_images.dart';

class ChatNearbyProfileScreen extends StatelessWidget {
  const ChatNearbyProfileScreen({
    super.key,
    this.onTapProfile,
    this.onSendGreetings,
    this.greetingsController,
  });

  final VoidCallback? onTapProfile;
  final VoidCallback? onSendGreetings;
  final TextEditingController? greetingsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _ChatNearbyProfileAppBar(onTapProfile: onTapProfile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProfileHeader(),
              SizedBox(height: 24.h),
              _GreetingsInput(controller: greetingsController),
              SizedBox(height: 24.h),
              CommonButton(
                titleText: 'Send Greetings',
                buttonHeight: 48.h,
                buttonRadius: 6.r,
                onTap: (){
                  Get.toNamed(AppRoutes.homeNav);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatNearbyProfileAppBar extends StatelessWidget {
  const _ChatNearbyProfileAppBar({this.onTapProfile});

  final VoidCallback? onTapProfile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18.sp,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onTapProfile,
                icon: CommonImage(imageSrc: AppIcons.addFriend, size: 22.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40.r,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: CommonImage(
              imageSrc: AppImages.profileImage,
              size: 80.r,
              defaultImage: AppImages.profileImage,
            ),
          ),
        ),
        CommonText(
          text: 'Dianne Russell',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          top: 16,
        ),
        CommonText(
          text:
              'Exploring One City At A Time\nCapturing Stories Beyond Borders',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryText,
          maxLines: 2,
          left: 40,
          right: 40,
          top: 4,
        ),
        SizedBox(height: 8.h),
        CommonText(
          text: 'Within 400 M',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor2,
        ),

        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage(imageSrc: AppIcons.location, size: 12.r),
            SizedBox(width: 8.w),
            const CommonText(
              text: 'Thornridge Cir. Shiloh, Hawaii',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ],
    );
  }
}

class _GreetingsInput extends StatelessWidget {
  const _GreetingsInput({this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          text: 'Type Your Greetings:',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textColorFirst,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 8.h),
        CommonTextField(
          controller: controller,
          maxLines: 6,
          paddingHorizontal: 12,
          paddingVertical: 12,
          borderRadius: 8,
        ),
      ],
    );
  }
}
