import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../component/image/common_image.dart';

class FriendRequestCard extends StatelessWidget {
  const FriendRequestCard({
    super.key,
    required this.userName,
    required this.timeAgo,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
    required this.requestStatus, // <--- NEW REQUIRED PROPERTY
    this.avatar,
  });

  final String userName;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final String requestStatus; // <--- NEW PROPERTY
  final String? avatar;

  // Helper widget to display the actions or status
  Widget _buildActions(String status) {
    if (status == 'accepted') {
      return const CommonText(
        text: 'Friend Added', // <--- Text shown after accepting
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      );
    }

    // Default to pending actions (Accept/Reject buttons)
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 32.h,
          width: 90.w,
          child: CommonButton(
            onTap: onAccept,
            titleText: 'Accept',
            buttonRadius: 6.r,
            titleSize: 12.sp,
            buttonHeight: 32.h,
            buttonWidth: 90.w,
          ),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          height: 32.h,
          width: 90.w,
          child: CommonButton(
            onTap: onReject,
            titleText: 'Reject',
            buttonColor: AppColors.white,
            titleColor: AppColors.secondaryText,
            buttonRadius: 6.r,
            titleSize: 12.sp,
            borderColor: AppColors.blueLight,
            buttonHeight: 32.h,
            buttonWidth: 90.w,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: CommonImage(
                  imageSrc: avatar ?? AppImages.profileImage,
                  size: 60.r,
                  fill: BoxFit.cover,
                  borderRadius: 60.r,
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: userName,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 8.h),
                  CommonText(
                    text: timeAgo,
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 12.h),
                  // <--- ACTIONS/STATUS RENDERED HERE
                  _buildActions(requestStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}