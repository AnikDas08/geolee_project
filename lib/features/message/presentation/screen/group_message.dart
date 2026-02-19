import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../controller/group_message_controller.dart';

class GroupMessageScreen extends StatelessWidget {
  const GroupMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments ?? {};
    final String groupName = arguments['groupName'] ?? 'Sports Club';
    final int memberCount = arguments['memberCount'] ?? 24;

    return GetBuilder<GroupMessageController>(
      init: GroupMessageController()..initializeGroup(groupName, memberCount),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: controller.groupName,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      CommonText(
                        text: '${controller.memberCount} Member',
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Get.toNamed(AppRoutes.groupSetting);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              /// Messages List
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageItem(message);
                  },
                ),
              ),

              /// Message Input Area
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: SafeArea(
                  child: Row(
                    children: [
                      /// Attachment Button
                      GestureDetector(
                        onTap: controller.pickAndSendImage,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.attach_file,
                            color: Colors.grey[600],
                            size: 24.sp,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      /// Text Input Field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: TextField(
                            controller: controller.messageController,
                            decoration: InputDecoration(
                              hintText: 'Write your message',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => controller.sendMessage(),
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      /// Send Button
                      GestureDetector(
                        onTap: controller.sendMessage,
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(GroupMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: message.isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!message.isCurrentUser)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Sender Avatar
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: message.senderImage.isNotEmpty
                      ? NetworkImage(message.senderImage)
                      : null,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  child: message.senderImage.isEmpty
                      ? Text(
                    message.senderName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Sender Name
                      CommonText(
                        text: message.senderName,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        bottom: 4.h,
                      ),

                      /// Message Bubble
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: message.isImage
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(message.imageUrl!),
                            width: 200.w,
                            fit: BoxFit.cover,
                          ),
                        )
                            : CommonText(
                          text: message.message,
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),

                      /// Timestamp
                      Padding(
                        padding: EdgeInsets.only(top: 4.h, left: 4.w),
                        child: CommonText(
                          text: _formatTime(message.timestamp),
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// Message Bubble (Current User)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                  child: message.isImage
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      File(message.imageUrl!),
                      width: 200.w,
                      fit: BoxFit.cover,
                    ),
                  )
                      : CommonText(
                    text: message.message,
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),

                /// Timestamp
                Padding(
                  padding: EdgeInsets.only(top: 4.h, right: 4.w),
                  child: CommonText(
                    text: _formatTime(message.timestamp),
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return DateFormat('h:mm a').format(time);
    } else if (difference.inHours < 24) {
      return DateFormat('h:mm a').format(time);
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }
}