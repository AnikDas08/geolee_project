import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/chat_controller.dart';
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
    return Obx(() {
      // ── Friend না হলে এই widget দেখাবে না
      if (!controller.isFriend.value) return const SizedBox.shrink();
      final double distanceKm = controller.rawDistanceKm.value;
      final double radiusKm = double.tryParse(
        Get.isRegistered<ChatController>()
            ? Get.find<ChatController>().currentRadius.value
            : LocalStorage.radius,
      ) ?? 0.0;
      final bool isOutOfRange = radiusKm > 0 && distanceKm > radiusKm;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Out of range warning banner
          if (isOutOfRange)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.location_off_rounded,
                      size: 14.sp, color: Colors.red.shade400),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'This user is out of your range. Messaging is disabled.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
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
                // ── Attachment button
                GestureDetector(
                  onTap: isOutOfRange ? null : onAttachmentTap,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: isOutOfRange
                          ? Colors.grey[200]
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.attach_file,
                      color: isOutOfRange
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // ── Text input
                Expanded(
                  child: Container(
                    constraints:
                    BoxConstraints(minHeight: 42.h, maxHeight: 120.h),
                    decoration: BoxDecoration(
                      color: isOutOfRange
                          ? Colors.grey[200]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      enabled: !isOutOfRange,
                      maxLines: null,
                      style:
                      TextStyle(fontSize: 14.sp, color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: isOutOfRange
                            ? 'Out of range to message'
                            : 'Write a message…',
                        hintStyle: TextStyle(
                            fontSize: 14.sp, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 11.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // ── Send button
                GestureDetector(
                  onTap: isOutOfRange ? null : controller.sendMessage,
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: isOutOfRange
                          ? Colors.grey[300]
                          : AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: isOutOfRange
                          ? []
                          : [
                        BoxShadow(
                          color:
                          AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: isOutOfRange
                          ? Colors.grey[500]
                          : Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// "2.5 KM" → 2.5, "500 M" → 0.5, "" → 0.0
double _parseDistanceToKm(String distanceStr) {
  if (distanceStr.isEmpty) return 0.0;
  final upper = distanceStr.toUpperCase().trim();
  if (upper.contains('KM')) {
    final numStr = upper.replaceAll('KM', '').trim();
    return double.tryParse(numStr) ?? 0.0;
  } else if (upper.contains('M')) {
    final numStr = upper.replaceAll('M', '').trim();
    final meters = double.tryParse(numStr) ?? 0.0;
    return meters / 1000;
  }
  return double.tryParse(distanceStr) ?? 0.0;
}