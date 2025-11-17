import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/home/presentation/widgets/friend_request_card.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class FriendRequestScreen extends StatelessWidget {
  const FriendRequestScreen({super.key});

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
        title: const CommonText(
          text: 'Friend Request',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return const FriendRequestCard(
              userName: 'Arlene McCoy',
              timeAgo: '2 Days Ago',
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemCount: 6,
        ),
      ),
    );
  }
}
