import 'package:flutter/material.dart';
import 'package:giolee78/config/route/app_routes.dart';
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              CommonText(
                text: "Select Attachment",
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                ),
                title: CommonText(text: "Choose from Gallery", fontSize: 16.sp),
                onTap: () async {
                  Get.back();
                  await MessageController.instance.pickImageFromGallery();
                },
              ),
              SizedBox(height: 10.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                ),
                title: CommonText(text: "Take Photo", fontSize: 16.sp),
                onTap: () async {
                  Get.back();
                  await MessageController.instance.pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
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
                      /// Banner Section - Only show if post is not null
                      InkWell(
                        /*onTap: () => OfferDialog.show(
                      Get.context!,
                      budget: controller.price,
                      serviceDate: DateTime.now(),
                      serviceTime: "",
                      onSubmit: () {},
                    ),*/
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.viewMessageScreen,
                            arguments: controller.postId,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.r),
                                ),
                                child: Image.network(
                                  ApiEndPoint.imageUrl +
                                      controller.serviceImage,
                                  height: 171.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 171.h,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50.sp,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 171.h,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CommonText(
                                            text: controller.serviceTitle,
                                            fontSize: 14.sp,
                                            color: AppColors.textColorFirst,
                                            textAlign: TextAlign.start,
                                            fontWeight: FontWeight.w600,
                                            maxLines: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        CommonText(
                                          text: "\$${controller.price.toInt()}",
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                    6.height,
                                    CommonText(
                                      text: "California, Fresno",
                                      fontSize: 12.sp,
                                      color: AppColors.textColorFirst,
                                    ),
                                    12.height,
                                    GestureDetector(
                                      /*onTap: () => OfferDialog.show(
                                    Get.context!,
                                    budget: controller.price,
                                    serviceDate: DateTime.now(),
                                    serviceTime: "",
                                    onSubmit: () {},
                                  ),*/
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.viewMessageScreen,
                                          arguments: controller.postId,
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: CommonText(
                                          text:
                                              controller.clientStatus ==
                                                  "RUNNING"
                                              ? "Running"
                                              : controller.clientStatus ==
                                                    "COMPLETED"
                                              ? "Completed"
                                              : controller.clientStatus ==
                                                    "REJECTED"
                                              ? "Rejected"
                                              : "Custom Offer",
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    10.height,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

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
                          onTap: _showAttachmentOptions,
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
