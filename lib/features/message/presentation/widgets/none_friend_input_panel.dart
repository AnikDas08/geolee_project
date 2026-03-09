import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';

import '../../../../utils/constants/app_colors.dart';
import '../controller/message_controller.dart';
import 'package:giolee78/features/message/presentation/controller/chat_controller.dart';


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

class NonFriendPanel extends StatelessWidget {
  final MessageController controller;

  const NonFriendPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.friendStatusValue.value;

      final double distanceKm = controller.rawDistanceKm.value;
      final double radiusKm = double.tryParse(
        Get.isRegistered<ChatController>()
            ? Get.find<ChatController>().currentRadius.value
            : LocalStorage.radius,
      ) ?? 0.0;
      final bool isOutOfRange = radiusKm > 0 && distanceKm > radiusKm;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 15.sp, color: Colors.orange[400]),
                        SizedBox(width: 6.w),
                        Text(
                          'This user is not in your friend list',
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),

                    // ── Out of range warning banner
                    if (isOutOfRange) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.red.shade100),
                        ),
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
                    ],

                    SizedBox(height: 10.h),

                    if (status == 'received')
                      _NonFriendTile(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: Colors.green.shade600,
                        label: 'Accept Friend Request',
                        onTap: () async =>
                        await controller.acceptFriendRequest(
                            controller.pendingRequestId.value),
                      ),
                    if (status == 'received')
                      Divider(height: 1, color: Colors.grey.shade100),
                    if (status == 'received')
                      _NonFriendTile(
                        icon: Icons.remove_circle_outline_rounded,
                        iconColor: Colors.red.shade400,
                        label: 'Reject Request',
                        onTap: () async =>
                        await controller.rejectFriendRequest(
                            controller.pendingRequestId.value),
                      ),
                    if (status == 'received')
                      Divider(height: 1, color: Colors.grey.shade100),
                    if (status != 'received' && status != 'friends')
                      _NonFriendTile(
                        icon: Icons.person_add_alt_1_rounded,
                        iconColor: AppColors.primaryColor,
                        label: status == 'pending'
                            ? 'Friend Request Sent ✓'
                            : 'Add Friend',
                        disabled: status == 'pending',
                        onTap: () async => await controller
                            .sendFriendRequest(controller.otherUserId.value),
                      ),
                    if (status != 'received' && status != 'friends')
                      Divider(height: 1, color: Colors.grey.shade100),
                    _NonFriendTile(
                      icon: Icons.close_rounded,
                      iconColor: Colors.red.shade400,
                      label: 'Ignore',
                      onTap: () {
                        controller.clearAllPicks();
                        Get.back();
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _NonFriendTile(
                      icon: Icons.chat_rounded,
                      iconColor: Colors.green.shade600,
                      label: 'Continue with Chat',
                      onTap: () {
                        controller.isFriend.value = true;
                        controller.friendStatusValue.value = 'none_continued';
                      },
                    ),
                  ],
                ),
              ),

              // ── Message Input Row
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          color: isOutOfRange
                              ? Colors.grey[200]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: TextField(
                          controller: controller.messageController,
                          enabled: !isOutOfRange,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: isOutOfRange
                                ? 'Out of range to message'
                                : 'Reply',
                            hintStyle: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 13.h),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: isOutOfRange ? null : controller.sendMessage,
                      child: Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: isOutOfRange
                              ? Colors.grey[300]
                              : AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color:
                          isOutOfRange ? Colors.grey[500] : Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      );
    });
  }
}

class _NonFriendTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool disabled;
  final VoidCallback? onTap;

  const _NonFriendTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 2.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: (disabled ? Colors.grey : iconColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon,
                  size: 18.sp,
                  color: disabled ? Colors.grey[400] : iconColor),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: disabled ? Colors.grey[400] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}