import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import '../controller/frients_pending.dart';

class GroupUserPendingRequestScreen extends StatelessWidget {
  const GroupUserPendingRequestScreen({super.key});

  Widget _PendingRequestUserListTile({
    required PendingRequest request,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {}, // optional: tap on whole tile
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User Avatar + Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundImage: request.userImage.isNotEmpty
                          ? NetworkImage(request.userImage)
                          : null,
                      child: request.userImage.isEmpty
                          ? Icon(Icons.person, size: 24.r, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: request.userName,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 4.h),
                        CommonText(
                          text: request.status.capitalizeFirst ?? "",
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),

                // Accept / Reject Buttons
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAccept,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.green, size: 20.r),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: onReject,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.red, size: 20.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            if (controller.isLoading.value && controller.pendingRequests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.pendingRequests.isEmpty) {
              return const Center(child: Text("No pending requests"));
            }
            return ListView.builder(
              controller: controller.scrollController,
              padding: EdgeInsets.all(10.w),
              itemCount: controller.pendingRequests.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (_, index) {
                if (index < controller.pendingRequests.length) {
                  final request = controller.pendingRequests[index];

                  return _PendingRequestUserListTile(
                    request: request,
                    onAccept: () => controller.onAcceptRequest(request),
                    onReject: () => controller.onRejectRequest(request),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          }),
        );
      },
    );
  }
}
