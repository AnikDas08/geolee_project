import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class MyFriendScreen extends StatelessWidget {
  const MyFriendScreen({super.key});

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
          text: 'My Friend',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            _SearchField(),
            SizedBox(height: 16.h),
            // Suggested friends with "Add" button
            _SuggestedFriendCard(
              userName: 'Arlene McCoy',
              avatar: AppImages.profileImage,
            ),
            SizedBox(height: 10.h),
            _SuggestedFriendCard(
              userName: 'Arlene McCoy',
              avatar: AppImages.profileImage,
            ),
            SizedBox(height: 20.h),
            const CommonText(
              text: 'Total Friend (150)',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 12.h),
            // Friend list
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _FriendListItem(
                  userName: 'Arlene McCoy',
                  avatar: AppImages.profileImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      hintText: 'Arlene',
      borderRadius: 8,
      paddingHorizontal: 14,
      paddingVertical: 12,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Icon(Icons.search, size: 18.sp, color: AppColors.textFiledColor),
      ),
    );
  }
}

class _SuggestedFriendCard extends StatelessWidget {
  const _SuggestedFriendCard({required this.userName, this.avatar});

  final String userName;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundImage: AssetImage(avatar ?? AppImages.profileImage),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CommonText(
              text: userName,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              textAlign: TextAlign.start,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            height: 32.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: const CommonText(
              text: 'Add',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendListItem extends StatelessWidget {
  const _FriendListItem({required this.userName, this.avatar});

  final String userName;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundImage: AssetImage(avatar ?? AppImages.profileImage),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CommonText(
              text: userName,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              textAlign: TextAlign.start,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 12.w),
          Icon(
            Icons.chat_bubble_outline,
            size: 20.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(width: 16.w),
          Icon(Icons.close, size: 20.sp, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}
