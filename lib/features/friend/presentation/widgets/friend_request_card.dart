import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class FriendRequestCard extends StatelessWidget {
  const FriendRequestCard({
    super.key,
    required this.userName,
    required this.timeAgo,
    required this.onTap,
    this.avatar,
  });

  final String userName;
  final String timeAgo;
  final VoidCallback onTap;
  final String? avatar;

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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: AppColors.black,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.h),
                  CommonText(
                    text: timeAgo,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 32.h,
                        width: 90.w,
                        child: CommonButton(
                          onTap: null,
                          titleText: 'Accept',
                          buttonColor: AppColors.primaryColor,
                          titleColor: AppColors.white,
                          buttonRadius: 6.r,
                          titleSize: 12.sp,
                          borderColor: AppColors.primaryColor,
                          buttonHeight: 32.h,
                          buttonWidth: 90.w,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 32.h,
                        width: 90.w,
                        child: CommonButton(
                          onTap: null,
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
