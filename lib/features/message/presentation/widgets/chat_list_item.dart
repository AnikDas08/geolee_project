import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../component/image/common_image.dart';
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


String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return "Just Now";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} Min Ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} Hour Ago";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} Day Ago";
  } else {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}

String _formatDistance(double? km) {
  if (km == null) return '';
  if (km < 1) return '${(km * 1000).toStringAsFixed(0)} M';
  return '${km.toStringAsFixed(1)} KM';
}

Widget chatListItem({
  required ChatModel item,
  bool isFriend = true,
  VoidCallback? onJoinTap,
}) {
  final bool hasUnseenMessages = item.unreadCount > 0;
  final String distanceText = _formatDistance(item.distanceInKm);
  final bool showDistance = !item.isGroup && distanceText.isNotEmpty;

  final Color bgColor = isFriend
      ? item.isGroup?Colors.white: const Color(0xFFFEF3E6)
      : Colors.white;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color:item.isGroup?Colors.white:const Color(0xFFFCD8B0)
      ),

    ),
    child: Row(
      children: [
        // ─── Avatar ─────────────────────────────────
        CircleAvatar(
          radius: 28.sp,
          backgroundColor: Colors.grey[200],
          child: ClipOval(
            child: CommonImage(
              imageSrc: item.isGroup
                  ? "${ApiEndPoint.imageUrl}${item.chatImage ?? ""}"
                  : "${ApiEndPoint.imageUrl}${item.participant.image}",
              fill: BoxFit.cover,
              size: 56,
            ),
          ),
        ),

        12.width,

        // ─── Name + Message ──────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.isGroup
                    ? (item.chatName ?? "Unnamed Group")
                    : item.participant.fullName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                item.latestMessage.text.isNotEmpty
                    ? item.latestMessage.text
                    : "Tap to view messages",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        8.width,

        if (item.isGroup && !item.amIAParticipant)
          GestureDetector(
            onTap: onJoinTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                item.joinRequestStatus?.toLowerCase() == "pending"
                    ? "Cancel Request"
                    : "Join",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              if (showDistance && !isFriend)
                Text(
                  'Distance: $distanceText',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFFF48201),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              SizedBox(height: 3.h),

              Text(
                 formatTimeAgo(item.updatedAt),
                // _formatTime(item.latestMessage.createdAt),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF797C7B),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}