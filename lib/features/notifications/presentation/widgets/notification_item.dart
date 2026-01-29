import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../component/text/common_text.dart';
import '../../data/model/notification_model.dart';
import '../../../../../utils/extensions/extension.dart';
import '../../../../../utils/constants/app_colors.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final NotificationModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isUnread = item.read == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: isUnread ? AppColors.primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔵 Unread Dot
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 8,
                  height: 8,
                  margin:  EdgeInsets.only(right: 8),
                  decoration:  BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // /// Sender Avatar (optional)
            // if (item.sender != null)
              Container(
                width: 40.w,
                height: 40.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryText.withOpacity(0.2),
                ),
                child: const Icon(Icons.person, size: 20),
              ),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: item.title,
                    fontSize: 14.sp,
                    fontWeight:
                    isUnread ? FontWeight.w600 : FontWeight.w400,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                  ),  CommonText(
                    text: item.message,
                    fontSize: 14.sp,
                    fontWeight:
                    isUnread ? FontWeight.w600 : FontWeight.w400,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                  ),
                  6.height,
                  CommonText(
                    text: item.createdAt.checkTime,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
