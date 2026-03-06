import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:intl/intl.dart';
import '../controller/my_friend_controller.dart';

class FriendRequestScreen extends StatelessWidget {
  FriendRequestScreen({super.key});

  final controller = Get.find<MyFriendController>();

  // ✅ createdAt (UTC) → local time → readable string
  String _formatRequestTime(DateTime createdAt) {
    final DateTime localTime = createdAt.toLocal();
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(localTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      // ৭ দিনের বেশি হলে actual date দেখাও
      return DateFormat('dd MMM yyyy').format(localTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingRequests = controller.requests
            .where((r) => r.status == "pending")
            .toList();

        if (pendingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline_rounded,
                    size: 52.sp, color: Colors.grey[300]),
                SizedBox(height: 12.h),
                Text(
                  'No friend requests',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: pendingRequests.length,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemBuilder: (context, index) {
            final data = pendingRequests[index];
            final sender = data.sender;

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
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
                  // ── Profile image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: CachedNetworkImage(
                      imageUrl: "${ApiEndPoint.imageUrl}${sender.image}",
                      height: 52.h,
                      width: 52.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.person_rounded,
                            color: Colors.grey[400], size: 28.sp),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.person_rounded,
                            color: Colors.grey[400], size: 28.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // ── Info + buttons
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + time row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                sender.name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // ✅ Local time
                            Text(
                              _formatRequestTime(data.createdAt),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        // Bio
                        if (sender.bio.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            sender.bio,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Address
                        if (sender.address.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 12.sp, color: Colors.grey[400]),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  sender.address,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        SizedBox(height: 12.h),

                        // ── Accept / Reject buttons
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton(
                                buttonHeight: 36.h,
                                titleText: 'Accept',
                                onTap: () => controller.acceptFriendRequest(
                                  data.id,
                                  index,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: CommonButton(
                                borderColor: Colors.transparent,
                                buttonHeight: 36.h,
                                titleText: 'Reject',
                                buttonColor: const Color(0xFFDEE2E3),
                                titleColor: const Color(0xFF737373),
                                onTap: () => controller.rejectFriendRequest(
                                  data.id,
                                  index,
                                ),
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