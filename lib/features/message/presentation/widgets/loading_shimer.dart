
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/features/message/presentation/widgets/shimerBox.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 9,
      itemBuilder: (_, i) {
        final isMe = i % 3 == 0;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                ShimmerBox(width: 26.w, height: 26.w, radius: 13.r),
                SizedBox(width: 8.w),
              ],
              ShimmerBox(
                width: (80 + (i * 23) % 130).toDouble().w,
                height: 38.h,
                radius: 16.r,
              ),
            ],
          ),
        );
      },
    );
  }
}