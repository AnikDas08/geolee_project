import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/constants/app_colors.dart';
import '../controller/message_controller.dart';

class PickedFilePreview extends StatelessWidget {
  final MessageController controller;

  const PickedFilePreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.hasPickedImage && !controller.hasPickedFile) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
      child: Row(
        children: [
          if (controller.hasPickedImage && controller.pickedImagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: controller.pickedFileType == 'media'
                      ? Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.videocam_rounded,
                        color: AppColors.primaryColor, size: 28.sp),
                  )
                      : Image.file(
                    File(controller.pickedImagePath!),
                    width: 56.w,
                    height: 56.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56.w,
                      height: 56.w,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_rounded),
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: controller.clearPickedImage,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 12.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          if (controller.hasPickedFile && controller.pickedFileName != null)
            Expanded(
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file_rounded,
                        color: AppColors.primaryColor, size: 24.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.pickedFileName ?? '',
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(controller.getPickedFileSize(),
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.clearPickedFile,
                      child: Icon(Icons.close_rounded,
                          size: 18.sp, color: Colors.red.shade300),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}