import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../data/model/chat_list_model.dart';
import '../../../../../utils/extensions/extension.dart';
import '../../../../../utils/constants/app_colors.dart';

String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 7) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  } else if (difference.inDays >= 1) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[dateTime.weekday - 1];
  } else {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

/// [isFriend] — true হলে normal background, false হলে white (not-friend indicator)
Widget chatListItem({required ChatModel item, bool isFriend = true}) {
  final bool hasUnseenMessages = item.unreadCount > 0;

  // যদি friend না হয় → সাদা, friend হলে → unseen check করে color
  final Color backgroundColor = !isFriend
      ? Colors.white
      : hasUnseenMessages
      ? const Color(0xFFFDFAF5)
      : Colors.white;

  // friend না হলে name ও message একটু dim করা
  final Color nameColor = !isFriend ? Colors.grey[500]! : Colors.black;
  final Color messageColor = !isFriend
      ? Colors.grey[400]!
      : hasUnseenMessages
      ? Colors.black87
      : AppColors.secondaryText;

  return Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: ShapeDecoration(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadows: const [
        BoxShadow(
          color: Color(0x11000000),
          blurRadius: 2,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        /// Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 35.sp,
              child: ClipOval(
                child: ColorFiltered(
                  // friend না হলে avatar grayscale
                  colorFilter: !isFriend
                      ? const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ])
                      : const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply),
                  child: CommonImage(
                    imageSrc: item.isGroup
                        ? "${ApiEndPoint.imageUrl}${item.chatImage ?? ""}"
                        : "${ApiEndPoint.imageUrl}${item.participant.image}",
                    fill: BoxFit.fill,
                    size: 70,
                  ),
                ),
              ),
            ),
            if (item.isOnline && !item.isGroup && isFriend)
              Positioned(
                bottom: 6,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF0FE16D),
                    shape: OvalBorder(),
                  ),
                ),
              ),
          ],
        ),

        12.width,

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: item.isGroup
                          ? (item.chatName ?? "Unnamed Group")
                          : item.participant.fullName,
                      fontWeight: hasUnseenMessages && isFriend
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 18,
                      color: nameColor,
                    ),
                    CommonText(
                      text: item.latestMessage.text.isNotEmpty
                          ? item.latestMessage.text
                          : "Tap to view messages",
                      fontWeight: hasUnseenMessages && isFriend
                          ? FontWeight.w500
                          : FontWeight.w400,
                      fontSize: 12,
                      color: messageColor,
                    ),
                  ],
                ),
              ),

              12.width,

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!item.isGroup)
                    CommonText(
                      text: _formatTime(item.latestMessage.createdAt),
                      fontSize: 12,
                      color: hasUnseenMessages && isFriend
                          ? const Color(0xFFE88D67)
                          : AppColors.secondaryText,
                    ),
                  // friend না হলে ছোট "Not friend" badge
                  if (!isFriend)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Not friend",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}