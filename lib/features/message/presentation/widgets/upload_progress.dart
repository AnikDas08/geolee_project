import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/constants/app_colors.dart';

class UploadProgress extends StatelessWidget {
  const UploadProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Sending…',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}