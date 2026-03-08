import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/constants/app_colors.dart';
import '../controller/message_controller.dart';

class FriendInputArea extends StatelessWidget {
  final MessageController controller;
  final VoidCallback onAttachmentTap;

  const FriendInputArea({
    super.key,
    required this.controller,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 10.h,
        bottom: MediaQuery.of(context).padding.bottom + 12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onAttachmentTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                  color: Colors.grey[100], shape: BoxShape.circle),
              child: Icon(Icons.attach_file,
                  color: Colors.grey[600], size: 22.sp),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 42.h, maxHeight: 120.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: TextField(
                controller: controller.messageController,
                maxLines: null,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Write a message…',
                  hintStyle:
                  TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 11.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }
}