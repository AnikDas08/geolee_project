import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/pop_up/common_pop_menu.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class CommonPostCards extends StatelessWidget {
  const CommonPostCards({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    this.images,
    this.description,
    required this.isFriend,
    required this.privacyImage,
    required this.clickerType,
    required this.onTapProfile,
    required this.onTapPhoto,
    this.postId, // Added this
  });

  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String location;
  final List<String>? images;
  final String? description;
  final bool isFriend;
  final String privacyImage;
  final String clickerType;
  final VoidCallback onTapProfile;
  final VoidCallback onTapPhoto;
  final String? postId; // Added this

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ── Header ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: onTapProfile,
                    child: CommonImage(
                      imageSrc: userAvatar,
                      width: 36.r,
                      height: 36.r,
                      borderRadius: 18.r,
                      fill: BoxFit.cover,
                      memCacheHeight: (36 * 3.5).toInt(),
                      memCacheWidth: (36 * 3.5).toInt(),
                      defaultImage: "assets/images/profilePlaceholder.jpg",
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              text: userName,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            if (postId != null)
                              GestureDetector(
                                onTap: () => _showReportBottomSheet(context, postId!),
                                child: Icon(
                                  Icons.more_vert,
                                  size: 20.sp,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                          ],
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
                                  SizedBox(width: 15.w),
                                  CommonImage(
                                    size: 12,
                                    imageSrc: privacyImage,
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

            /// ── Image Slider ─────────────────────────────────────
            if (images != null && images!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: _PostImageSlider(
                  images: images!,
                  onTapPhoto: onTapPhoto,
                ),
              ),

            /// ── Clicker Type ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
              child: CommonText(
                text: clickerType,
                fontSize: 12,
                color: AppColors.textColorFirst,
              ),
            ),

            /// ── Description ──────────────────────────────────────
            if (description != null && description!.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
                child: CommonText(
                  text: description!,
                  fontSize: 12,
                  color: AppColors.textColorFirst,
                  maxLines: 6,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ── Report Bottom Sheet ──────────────────────────────────
  void _showReportBottomSheet(BuildContext context, String postId) {
    final List<String> reportReasons = [
      'Sexual Content',
      'Harassment / Bullying',
      'Hate Speech',
      'Violence',
      'Gambling',
      'Spam',
      'Fake Profile',
      'Scam / Fraud',
      'Other',
    ];

    String? selectedReason;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CommonText(
                    text: "Report Post",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 10.h),
                  CommonText(
                    text: "Why are you reporting this post?",
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(height: 15.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 400.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: reportReasons.length,
                      itemBuilder: (context, index) {
                        final reason = reportReasons[index];
                        final isSelected = selectedReason == reason;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedReason = reason;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CommonText(
                                    text: reason,
                                    fontSize: 14,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  height: 20.r,
                                  width: 20.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            height: 10.r,
                                            width: 10.r,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 25.h),
                  CommonButton(
                    titleText: "Submit Report",
                    onTap: () {
                      if (selectedReason == null) {
                        Utils.errorSnackBar(
                          "Reason Required",
                          "Please select a reason for reporting.",
                        );
                        return;
                      }
                      Navigator.pop(context);
                      _submitReport(postId, selectedReason!);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ── Submit Report API Call ────────────────────────────────
  Future<void> _submitReport(String postId, String reason) async {
    try {
      debugPrint("🚩 Reporting post: $postId for reason: $reason");
      
      final response = await ApiService.post(
        "https://clicker-api.just-metaverse.com/api/v1/reports/create",
        body: {
          "post": postId, // Changed from "postId" to "post" to match common backend naming, adjust if needed
          "reason": reason,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        successPopUps(
          message: "Thank you for reporting. We will review this post shortly.",
          buttonTitle: "Done",
          onTap: () => Get.back(),
        );
      } else {
        Utils.errorSnackBar("Error", response.data['message'] ?? "Failed to submit report");
      }
    } catch (e) {
      debugPrint("❌ Report Error: $e");
      Utils.errorSnackBar("Error", "Something went wrong while reporting");
    }
  }
}

/// ================================================================
/// IMAGE SLIDER WITH DOT INDICATOR
/// ================================================================

class _PostImageSlider extends StatefulWidget {
  final List<String> images;
  final VoidCallback onTapPhoto;

  const _PostImageSlider({required this.images, required this.onTapPhoto});

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  // ✅ Fixed: ValueNotifier দিয়ে শুধু dots rebuild হবে, পুরো Column না
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

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
              onPageChanged: (index) => _currentIndex.value = index,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: widget.onTapPhoto,
                  child: RepaintBoundary(
                    child: CommonImage(
                      imageSrc: widget.images[index],
                      width: double.infinity,
                      height: 190.h,
                      fill: BoxFit.cover,
                      // ✅ Quality Fix: Height limit সরিয়ে শুধু Width limit রাখা হয়েছে যাতে Aspect Ratio ঠিক থাকে
                      memCacheWidth: 1000,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        if (widget.images.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            // ✅ Fixed: ValueListenableBuilder — শুধু dots অংশ rebuild হবে
            child: ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, currentIdx, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (index) {
                    final isActive = currentIdx == index;
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
                          colors: [
                            Color(0xFFFF0000),
                            Color(0xFFF43C3C),
                          ],
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
                );
              },
            ),
          ),
      ],
    );
  }
}