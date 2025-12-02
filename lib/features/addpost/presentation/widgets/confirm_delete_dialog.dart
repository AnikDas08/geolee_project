import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/constants/app_colors.dart';

void showDeletePostDialog(BuildContext context, {required VoidCallback onConfirmDelete, String? title}) {
  String? title = "Are you sure you want to\nDelete This Post?";
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // --- Close Icon ---
              GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
              ),

              SizedBox(height: 5.h),

              // --- Content Text ---
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // --- Buttons Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 'No' Button (Dismiss)
                  _buildDialogButton(
                    title: "No",
                    backgroundColor: Colors.grey,
                    textColor: AppColors.textSecond,
                    onTap: () => Navigator.of(dialogContext).pop(),
                  ),

                  SizedBox(width: 15.w),

                  // 'Yes' Button (Confirm Action)
                  _buildDialogButton(
                    title: "Yes",
                    backgroundColor: AppColors.primaryColor,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.of(dialogContext).pop(); // Close dialog first
                      onConfirmDelete(); // Execute the actual delete logic
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      );
    },
  );
}

// Helper Widget for the dialog buttons
Widget _buildDialogButton({
  required String title,
  required Color backgroundColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    ),
  );
}