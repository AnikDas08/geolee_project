import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import '../../../../utils/constants/app_images.dart';
import '../controller/my_friend_controller.dart';

class FriendRequestScreen extends StatelessWidget {
  FriendRequestScreen({super.key});

  final controller = Get.put(MyFriendController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ Filter only pending requests
        final pendingRequests = controller.requests
            .where((r) => r.status == "pending")
            .toList();


        if (pendingRequests.isEmpty) {
          return const Center(child: Text("No friend requests"));
        }

        return ListView.builder(
          itemCount: pendingRequests.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final data = pendingRequests[index];
            final friendInfo = data.sender;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image with fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: CachedNetworkImage( // Recommended over NetworkImage for better UX
                      imageUrl: "${ApiEndPoint.imageUrl}${friendInfo.image}",
                      height: 50.h,
                      width: 50.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.asset(AppImages.profileImage),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friendInfo.name ?? "Unknown",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        const CommonText(
                          text: '2 Days Ago',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF737373),
                        ),
                        SizedBox(height: 12.h),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton(
                                buttonHeight: 36.h,
                                titleText: 'Accept',
                                onTap: () => controller.acceptFriendRequest(data.id, index),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: CommonButton(
                                borderColor: Colors.transparent,
                                buttonHeight: 36.h,
                                titleText: 'Reject',
                                buttonColor: Color(0xFFDEE2E3), // Make Reject less prominent
                                titleColor:Color(0xFF737373),
                                onTap: () => controller.rejectFriendRequest(data.id, index),
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
          },
        );
      }),
    );
  }
}
