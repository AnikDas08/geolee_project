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

Widget chatListItem({required ChatModel item}) {
  final bool hasUnseenMessages = item.unreadCount > 0;

  final Color backgroundColor = hasUnseenMessages
      ? const Color(0xFFFDFAF5)
      : Colors.white;

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
        /// image
        Stack(
          children: [
            CircleAvatar(
              radius: 35.sp,
              child: ClipOval(
                child: CommonImage(
                  imageSrc: item.isGroup
                      ? "${ApiEndPoint.imageUrl}${item.chatImage ?? ""}"
                      : "${ApiEndPoint.imageUrl}${item.participant.image}",
                  fill: BoxFit.fill,
                  size: 70,
                ),
              ),
            ),
            if (item.isOnline && !item.isGroup)
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
                      fontWeight: hasUnseenMessages
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 18,
                    ),
                    CommonText(
                      text: item.latestMessage.text.isNotEmpty
                          ? item.latestMessage.text
                          : "Tap to view messages",
                      fontWeight: hasUnseenMessages
                          ? FontWeight.w500
                          : FontWeight.w400,
                      fontSize: 12,
                      color: hasUnseenMessages
                          ? Colors.black87
                          : AppColors.secondaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      text: "Distance 30 km",
                      fontSize: 12,
                      color: const Color(0xFFE88D67),
                      fontWeight: FontWeight.w600,
                    ),

                  CommonText(
                    text: _formatTime(item.latestMessage.createdAt),
                    fontSize: 12,
                    color: hasUnseenMessages
                        ? const Color(0xFFE88D67)
                        : AppColors.secondaryText,
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
