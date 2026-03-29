import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/features/message/presentation/widgets/video_player_bubble.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../data/model/chat_message.dart';

class BubbleContent extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String Function(String?) getImageUrl;
  final void Function(String url) onImageTap;

  const BubbleContent({
    required this.message,
    required this.isMe,
    required this.getImageUrl,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isImage) {
      final url = getImageUrl(message.imageUrl ?? '');
      return GestureDetector(
        onTap: () => onImageTap(url),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 18.r),
          ),
          child: Image.network(
            url,
            width: 220.w,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    width: 220.w,
                    height: 160.h,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                        color: AppColors.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
            errorBuilder: (_, __, ___) => Container(
              width: 220.w,
              height: 120.h,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey[400],
                    size: 32.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Image unavailable',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (message.type == 'media') {
      final url = message.fileUrl ?? '';
      if (url.isEmpty) {
        return Container(
          width: 240.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                color: Colors.grey[400],
                size: 28.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                'Video unavailable',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        );
      }
      return VideoPlayerBubble(videoUrl: url, isMe: isMe);
    }

    if (message.type == 'document') {
      return Container(
        constraints: BoxConstraints(maxWidth: 240.w, minWidth: 140.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 18.r),
          ),
          border: Border.all(
            color: isMe
                ? AppColors.primaryColor.withValues(alpha: 0.2)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.insert_drive_file_rounded,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                message.message.isNotEmpty ? message.message : 'Document',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 260.w, minWidth: 40.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFEEEEE) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
          bottomRight: Radius.circular(isMe ? 4.r : 18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        message.message,

        style: TextStyle(

          fontSize: 14.sp,
          height: 1.45,
          color: Colors.black87,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
