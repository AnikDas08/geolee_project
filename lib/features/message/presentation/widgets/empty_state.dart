import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 38.sp,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Say hello 👋',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}