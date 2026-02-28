import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/presentation/screen/view_friend_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../services/storage/storage_services.dart';
import '../../../../utils/enum/enum.dart';
import '../controller/my_friend_controller.dart';

class MyFriendScreen extends StatelessWidget {
  const MyFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyFriendController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Get.back(),
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
        ),
      ),
      body: SafeArea(
        child: Obx(
              () => ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
               _SearchField(),

              SizedBox(height: 16.h),

              // ================= Suggested Friends =================

              const CommonText(
                text: 'Suggested Friends',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 12.h),
              if (controller.suggestedFriendList.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.suggestedFriendList.length,
                  itemBuilder: (context, index) {
                    final friend = controller.suggestedFriendList[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _SuggestedFriendCard(
                        userId: friend.id,
                        userName: friend.name,
                        avatar: "${ApiEndPoint.imageUrl}${friend.image}",
                        controller: controller,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],

              // ================= My Friends =================
              CommonText(
                text: 'Total Friend (${controller.filteredFriendsList.length})',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 12.h),

              if (controller.filteredFriendsList.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: CommonText(
                      text: controller.searchQuery.value.isNotEmpty
                          ? 'No results found'
                          : 'No friends yet',
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredFriendsList.length,
                  itemBuilder: (context, index) {
                    final data = controller.filteredFriendsList[index];
                    final friend = data.friend;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _FriendListItem(
                        friendshipId: data.id ?? "",
                        userId: friend?.id ?? "",
                        userName: friend?.name ?? "Unknown",
                        avatar:
                        "${ApiEndPoint.imageUrl}${friend?.image ?? ""}",
                        controller: controller,
                      ),
                    );
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyFriendController>(); // directly find here
    return CommonTextField(
      hintText: 'Search friends',
      paddingHorizontal: 14,
      paddingVertical: 12,
      onChanged: (value) => controller.searchQuery.value = value,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Icon(Icons.search, size: 18.sp, color: AppColors.textFiledColor),
      ),
    );
  }
}

class _SuggestedFriendCard extends StatelessWidget {
  const _SuggestedFriendCard({
    required this.userId,
    required this.userName,
    required this.controller,
    this.avatar,
  });

  final String userId;
  final String userName;
  final String? avatar;
  final MyFriendController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ViewFriendScreen(isFriend: false, userId: userId)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──
            CircleAvatar(
              radius: 26.r,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              backgroundImage: (avatar != null && avatar!.isNotEmpty)
                  ? NetworkImage(avatar!)
                  : const AssetImage(AppImages.profileImage) as ImageProvider,
            ),

            SizedBox(width: 12.w),

            // ── Name & subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: userName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 2.h),
                  CommonText(
                    text: 'People you may know',
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // ── Action Button ──
            if (userId != LocalStorage.userId)
              Obx(() {
                final status = controller.getFriendStatus(userId);
                final loading = controller.isUserLoading(userId);

                switch (status) {
                  case FriendStatus.requested:
                    return _StatusButton(
                      title: loading ? 'Cancelling...' : 'Requested',
                      icon: Icons.hourglass_top_rounded,
                      color: Colors.orange,
                      onTap: loading
                          ? () {}
                          : () => controller.cancelFriendRequest(userId),
                    );

                  case FriendStatus.friends:
                    return _StatusButton(
                      title: 'Friends',
                      icon: Icons.check_rounded,
                      color: Colors.green,
                      onTap: () {},
                    );

                  case FriendStatus.none:
                  default:
                    return _StatusButton(
                      title: loading ? 'Sending...' : 'Add Friend',
                      icon: Icons.person_add_alt_1_rounded,
                      color: AppColors.primaryColor,
                      onTap: loading
                          ? () {}
                          : () => controller.onTapAddFriendButton(userId),
                    );
                }
              }),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= Friend List Item =================
class _FriendListItem extends StatelessWidget {
  const _FriendListItem({
    required this.friendshipId,
    required this.userId,
    required this.userName,
    required this.controller,
    this.avatar,
  });

  final String friendshipId;
  final String userId;
  final String userName;
  final String? avatar;
  final MyFriendController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ViewFriendScreen(
        isFriend: true,
        userId: userId,
      )),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar with online indicator ──
            Stack(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: (avatar != null && avatar!.startsWith('http'))
                      ? NetworkImage(avatar!)
                      : const AssetImage(AppImages.profileImage) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 12.w),

            // ── Name ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: userName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 2.h),
                  CommonText(
                    text: 'Tap to view profile',
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),

            // ── Action Buttons ──
            Row(
              children: [
                // Message button
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.primaryColor,
                  onTap: () {
                    controller.createOrGetChatAndGo(
                        receiverId: userId,
                        name: userName,
                        image: avatar ?? "",
                    );


                  },
                ),


        // controller.createOrGetChatAndGo(
        //   receiverId: widget.userId,
        //   name: user?.name ?? "",
        //   image: user?.image ?? "",
        // );

                SizedBox(width: 8.w),

                // Unfriend button
                _ActionButton(
                  icon: Icons.person_remove_outlined,
                  color: Colors.redAccent,
                  onTap: () => Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_remove_outlined,
                              size: 40.sp,
                              color: Colors.redAccent,
                            ),
                            SizedBox(height: 12.h),
                            CommonText(
                              text: 'Remove Friend?',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 6.h),
                            CommonText(
                              text: 'Are you sure you want to\nremove $userName?',
                              fontSize: 13,
                              color: AppColors.secondaryText,
                              maxLines: 2,
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      controller.removeFriend(friendshipId);
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    child: const Text(
                                      'Unfriend',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable action button ──
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.sp, color: color),
      ),
    );
  }
}