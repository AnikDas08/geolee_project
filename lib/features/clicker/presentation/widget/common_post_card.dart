import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class CommonPostCards extends StatelessWidget {
  const CommonPostCards({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    required this.images,
    required this.description,
    required this.isFriend,
    required this.privacyImage,
    required this.clickerType,
    required this.onTapProfile,
    required this.onTapPhoto,
  });

  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String location;
  final List<String> images;
  final String description;
  final bool isFriend;
  final String privacyImage;
  final String clickerType;
  final VoidCallback onTapProfile;
  final VoidCallback onTapPhoto;

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
          /// ================= Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                InkWell(
                  onTap: onTapProfile,
                  child: CircleAvatar(
                    radius: 18.r,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.network(
                        userAvatar,
                        width: 36.r,
                        height: 36.r,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: userName,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                            child: Row(
                              children: [
                                CommonText(
                                  text: location,
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 30.w),
                                Expanded(
                                  child: CommonImage(
                                    size: 12,
                                    imageSrc: privacyImage,
                                  ),
                                ),
                              ],
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

          /// ================= Image Slider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: _PostImageSlider(images: images, onTapPhoto: onTapPhoto),
          ),

          /// ================= Clicker Type
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
            child: CommonText(
              text: clickerType,
              fontSize: 12,
              color: AppColors.textColorFirst,
            ),
          ),

          /// ================= Description
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
            child: CommonText(
              text: description,
              fontSize: 12,
              color: AppColors.textColorFirst,
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// IMAGE SLIDER WITH DOT INDICATOR
/// =======================================================

class _PostImageSlider extends StatefulWidget {
  final List<String> images;
  final VoidCallback onTapPhoto;

  const _PostImageSlider({required this.images, required this.onTapPhoto});

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            height: 190.h,
            child: PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: widget.onTapPhoto,
                  child: CommonImage(
                    imageSrc: widget.images[index],
                    width: double.infinity,
                    height: 190.h,
                    fill: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),

        /// ================= Dot Indicator
        /// ================= Dot Indicator
        if (widget.images.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final isActive = currentIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 6.h,
                  width: isActive ? 26.w : 8.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFFFF0000), Color(0xFFF43C3C)],
                          )
                        : null,
                    color: isActive
                        ? null
                        : Colors.grey.withValues(alpha: 0.35),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF66666),

                              blurRadius: 6.r,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
