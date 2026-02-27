import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// Note: Assuming AppColors, CommonText, CommonImage exist in your project structure
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import '../controller/frients_pending.dart';

class PendingRequestScreen extends StatelessWidget {
  const PendingRequestScreen({super.key});

  Widget _tile({
    required PendingRequest request,
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
              CircleAvatar(
                radius: 20.r,
                child: Icon(Icons.person),
              ),
              SizedBox(width: 12.w),
              CommonText(
                text: "User ID: ${request.userId}",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),

          Row(
            children: [
              GestureDetector(
                onTap: onAccept,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Icon(Icons.check, color: Colors.green),
                ),
              ),
              GestureDetector(
                onTap: onReject,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PendingRequestController>(
      init: PendingRequestController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text("Pending Request")),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.pendingRequests.isEmpty) {
              return const Center(child: Text("No pending requests"));
            }

            return ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: controller.pendingRequests.length,
              itemBuilder: (_, index) {
                final request = controller.pendingRequests[index];

                return _tile(
                  request: request,
                  onAccept: () => controller.onAcceptRequest(request),
                  onReject: () => controller.onRejectRequest(request),
                );
              },
            );
          }),
        );
      },
    );
  }
}