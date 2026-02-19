import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// Note: Assuming AppColors, CommonText, CommonImage exist in your project structure
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import '../controller/frients_pending.dart';

class PendingRequestScreen extends StatelessWidget {
  const PendingRequestScreen({super.key});

  // Reusable list tile for pending requests
  Widget _PendingRequestTile({
    required User user,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Row(
           children: [
             // Mock Avatar (replace with CommonImage)
             CircleAvatar(
               radius: 20.r,
               backgroundImage: NetworkImage(user.avatarUrl),
               backgroundColor: AppColors.secondaryText.withOpacity(0.1),
             ),
             SizedBox(width: 12.w),
             CommonText(
               text: user.name,
               fontSize: 16.sp,
               fontWeight: FontWeight.w500,
             ),
           ],
         ),

         // Accept Icon (Green Check)
         Row(
           children: [
             GestureDetector(
               onTap: onAccept,
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 10.w),
                 child: Icon(
                   Icons.check,
                   size: 24.sp,
                   color: Colors.green.shade600,
                 ),
               ),
             ),
             // Reject Icon (Red X)
             GestureDetector(
               onTap: onReject,
               child: Padding(
                 padding: EdgeInsets.only(left: 10.w),
                 child: Icon(
                   Icons.close,
                   size: 24.sp,
                   color: Colors.red.shade600,
                 ),
               ),
             ),
           ],
         ),

       ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PendingRequestController>(
      init: PendingRequestController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18.sp,
                color: AppColors.black,
              ),
            ),
            centerTitle: true,
            title: const CommonText(
              text: 'Pending Request',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.pendingRequests.isEmpty) {
              return Center(
                child: CommonText(
                  text: 'No pending requests.',
                  fontSize: 16.sp,
                  color: AppColors.secondaryText,
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: controller.pendingRequests.length,
              itemBuilder: (context, index) {
                final user = controller.pendingRequests[index];
                return _PendingRequestTile(
                  user: user,
                  onAccept: () => controller.onAcceptRequest(user),
                  onReject: () => controller.onRejectRequest(user),
                );
              },
            );
          }),
        );
      },
    );
  }
}