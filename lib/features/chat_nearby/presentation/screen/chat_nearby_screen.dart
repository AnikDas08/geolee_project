import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/chat_nearby/presentation/screen/chat_nearby_profile_screen.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ChatNearbyScreen extends StatelessWidget {
  const ChatNearbyScreen({super.key});

  static const List<_NearbyUser> _users = [
    _NearbyUser(name: 'Arlene McCoy'),
    _NearbyUser(name: 'Cameron Williamson'),
    _NearbyUser(name: 'Brooklyn Simmons'),
    _NearbyUser(name: 'Kathryn Murphy'),
    _NearbyUser(name: 'Bessie Cooper'),
    _NearbyUser(name: 'Floyd Miles'),
    _NearbyUser(name: 'Theresa Webb'),
    _NearbyUser(name: 'Cody Fisher'),
    _NearbyUser(name: 'Annette Black'),
    _NearbyUser(name: 'Annette Black'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _ChatNearbyAppBar(),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemBuilder: (context, index) {
          final user = _users[index];
          return _NearbyUserCard(user: user);
        },
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: _users.length,
      ),
    );
  }
}

class _ChatNearbyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Get.back();
                },
              ),
              const Expanded(
                child: Center(
                  child: CommonText(
                    text: 'Chat Nearby',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorFirst,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyUserCard extends StatelessWidget {
  const _NearbyUserCard({required this.user});

  final _NearbyUser user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const ChatNearbyProfileScreen());
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.white, size: 20),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: user.name,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  SizedBox(height: 4.h),
                  CommonText(
                    text: 'Within 400 M',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor2,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyUser {
  const _NearbyUser({required this.name});

  final String name;
}
