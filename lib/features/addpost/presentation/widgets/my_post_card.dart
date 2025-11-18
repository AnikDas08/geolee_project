import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class MyPostCard extends StatelessWidget {
  const MyPostCard({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    required this.postImage,
    required this.description,
  });

  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String location;
  final String postImage;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: CommonImage(
                      imageSrc: userAvatar,
                      size: 36.r,
                      fill: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: userName,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12.sp,
                            color: AppColors.secondaryText,
                          ),
                          SizedBox(width: 4.w),
                          CommonText(
                            text: timeAgo,
                            fontSize: 11,
                            color: AppColors.secondaryText,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            width: 3.r,
                            height: 3.r,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: AppColors.secondaryText,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: CommonText(
                              text: location,
                              fontSize: 11,
                              color: AppColors.secondaryText,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                /// More + options icon group
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCircleIcon(icon: Icons.more_horiz, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),

          /// Image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CommonImage(
                imageSrc: postImage,
                width: double.infinity,
                height: 190.h,
                fill: BoxFit.cover,
                borderRadius: 10.r,
              ),
            ),
          ),

          /// Description
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            child: CommonText(
              text: description,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textColorFirst,
              textAlign: TextAlign.start,
              maxLines: 6,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.secondaryText),
      ),
    );
  }
}
