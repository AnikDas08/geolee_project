import 'package:flutter/material.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../message/data/model/chat_message_model.dart';
import '../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../utils/constants/app_colors.dart';
import '../../../message/presentation/widgets/chat_bubble_message.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String chatId = Get.parameters["chatId"] ?? "";
  String name = Get.parameters["name"] ?? "";
  String image = Get.parameters["image"] ?? "";

  // ignore: unused_element
  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${ApiEndPoint.imageUrl}$imagePath';
  }

  @override
  void initState() {
    MessageController.instance.name = name;
    MessageController.instance.chatId = chatId;
    MessageController.instance.getMessageRepo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[100],

          /// App Bar
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            title: CommonText(
              text: "Chat & Offer",
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            centerTitle: true,
          ),

          /// Full Scrollable Body
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  controller: controller.scrollController,
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    children: [
                      /// Messages Section
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.isMoreLoading
                            ? controller.messages.length + 1
                            : controller.messages.length,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemBuilder: (context, index) {
                          if (index < controller.messages.length) {
                            ChatMessageModel message =
                                controller.messages[index];
                            return ChatBubbleMessage(
                              index: index,
                              image: message.image,
                              time: message.time,
                              text: message.text,
                              messageImage: message.messageImage,
                              isMe: message.isMe,
                              isUploading: message.isUploading,
                              onTap: () {},
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

          /// Bottom Navigation Bar
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.of(context).padding.bottom + 16.h,
              top: 16.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: "Write your message",
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Icon(
                              Icons.attach_file,
                              color: Colors.grey[600],
                              size: 22.sp,
                            ),
                          ),
                        ),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      onSubmitted: (p0) => controller.addNewMessage(),
                    ),
                  ),
                ),
                12.width,
                GestureDetector(
                  onTap: controller.addNewMessage,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
