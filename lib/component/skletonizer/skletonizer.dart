import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
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
            /// ── Header ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  // Avatar circle
                  _SkeletonBox(width: 36.r, height: 36.r, isCircle: true),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 130.w, height: 12.h),
                      SizedBox(height: 6.h),
                      _SkeletonBox(width: 180.w, height: 10.h),
                    ],
                  ),
                ],
              ),
            ),

            /// ── Image Area ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: _SkeletonBox(
                width: double.infinity,
                height: 190.h,
                radius: 10.r,
              ),
            ),

            /// ── Clicker Type ─────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
              child: _SkeletonBox(width: 80.w, height: 10.h),
            ),

            /// ── Description Lines ────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 4.h),
              child: _SkeletonBox(width: double.infinity, height: 10.h),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 4.h),
              child: _SkeletonBox(width: 250.w, height: 10.h),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 16.h),
              child: _SkeletonBox(width: 180.w, height: 10.h),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Reusable skeleton box ───────────────────────────────
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double? radius;
  final bool isCircle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(radius ?? 6.r),
      ),
    );
  }
}