import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/text/common_text.dart';
import '../../data/model/notification_model.dart';
import '../../../../../utils/extensions/extension.dart';
import '../../../../../utils/constants/app_colors.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({super.key, required this.item, required this.onTap});

  final NotificationModel item;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Sender Profile Image
            if (item.sender != null)
              Container(
                width: 40.w,
                height: 40.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: const Color(0xFFDEE2E3) /* Disable */,
                    ),
                  ),
                ),
              ),

            /// Notification Content
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /// Notification Title
                  Expanded(
                    child: CommonText(
                      text: item.text,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.start,
                      maxLines: 3,
                    ),
                  ),

                  /// Read Status Indicator
                  CommonText(
                    text: item.createdAt.checkTime,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                    color: AppColors.black.withOpacity(0.6),
                    maxLines: 1,
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
