import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/friend/presentation/screen/view_friend_screen.dart';
import 'package:giolee78/features/friend/presentation/widgets/friend_request_card.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  // --- UPDATED DATA STRUCTURE ---
  final List<Map<String, String>> _requests = [
    {'name': 'Arlene McCoy', 'time': '2 Days Ago', 'status': 'pending'},
    {'name': 'Esther Howard', 'time': '1 Day Ago', 'status': 'pending'},
    {'name': 'Cameron Williamson', 'time': '5 Hours Ago', 'status': 'pending'},
    {'name': 'Brooklyn Simmons', 'time': '1 Hour Ago', 'status': 'pending'},
    {'name': 'Ralph Edwards', 'time': '40 Minutes Ago', 'status': 'pending'},
    {'name': 'Leslie Alexander', 'time': '10 Minutes Ago', 'status': 'pending'},
  ];

  // --- MODIFIED ACCEPT FUNCTION ---
  void _acceptRequest(int index, String name) {
    // In a real app, you would make an API call here.
    setState(() {
      // 1. Change the status instead of removing the item
      _requests[index]['status'] = 'accepted';
    });

    Get.snackbar(
      'Request Accepted',
      '$name is now your friend!',
      backgroundColor: AppColors.primaryColor.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- REJECT FUNCTION REMAINS REMOVAL ---
  void _rejectRequest(int index, String name) {
    // In a real app, you would make an API call here.
    setState(() {
      // 2. Remove the item
      _requests.removeAt(index);
    });

    Get.snackbar(
      'Request Rejected',
      'You rejected the friend request from $name.',
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        title: CommonText(
          // Only count pending requests for the title
          text: 'Friend Request (${_requests.where((r) => r['status'] == 'pending').length})',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      body: SafeArea(
        child: _requests.isEmpty
            ? Center(
          child: CommonText(
            text: 'No pending friend requests.',
            fontSize: 16,
            color: AppColors.black.withOpacity(0.6),
          ),
        )
            : ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final request = _requests[index];
            return FriendRequestCard(
              userName: request['name']!,
              timeAgo: request['time']!,
              requestStatus: request['status']!, // <--- PASS THE STATUS
              onTap: () {
                Get.to(
                      () => const ViewFriendScreen(
                      isFriend: false, isRequest: true),
                );
              },
              onAccept: request['status'] == 'pending' ? () => _acceptRequest(index, request['name']!) : () {},
              onReject: request['status'] == 'pending' ? () => _rejectRequest(index, request['name']!) : () {},
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemCount: _requests.length,
        ),
      ),
    );
  }
}