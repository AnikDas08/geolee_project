import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
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
              const _SearchField(),
              SizedBox(height: 16.h),

              /// ================= Suggested Friends =================
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

              /// ================= My Friends =================
              CommonText(
                text: 'Total Friend (${controller.myFriendsList.length})',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 12.h),

              if (controller.myFriendsList.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const Center(
                    child: CommonText(
                      text: 'No friends yet',
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.myFriendsList.length,
                  itemBuilder: (context, index) {
                    final data = controller.myFriendsList[index];
                    final friend = data.friend;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _FriendListItem(
                        friendshipId: data.id ?? "",        // 🔥 relation id (unfriend এর জন্য)
                        userId: friend?.id ?? "",           // 🔥 actual user id (view screen এর জন্য)
                        userName: friend?.name ?? "Unknown",
                        avatar: "${ApiEndPoint.imageUrl}${friend?.image ?? ""}",
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

/// ================= Search =================
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      hintText: 'Search friends...',
      paddingHorizontal: 14,
      paddingVertical: 12,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Icon(Icons.search, size: 18.sp, color: AppColors.textFiledColor),
      ),
    );
  }
}

/// ================= Suggested Friend Card =================
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundImage: (avatar != null && avatar!.isNotEmpty)
                      ? NetworkImage(avatar!)
                      : const AssetImage(AppImages.profileImage) as ImageProvider,
                ),
                SizedBox(width: 12.w),
                CommonText(
                  text: userName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),

            if (userId != LocalStorage.userId)
              Obx(() {
                final status = controller.getFriendStatus(userId);
                final loading = controller.isUserLoading(userId);

                switch (status) {
                  case FriendStatus.requested:
                    return _buildButton(
                      title: loading ? 'Cancelling...' : 'Cancel Request',
                      color: Colors.grey,
                      onTap: loading
                          ? () {}
                          : () => controller.cancelFriendRequest(userId),
                      image: '',
                    );

                  case FriendStatus.friends:
                    return _buildButton(
                      title: 'Friends',
                      color: Colors.green,
                      onTap: () {},
                      image: '',
                    );

                  case FriendStatus.none:
                  default:
                    return _buildButton(
                      title: loading ? 'Sending...' : 'Add Friend',
                      color: AppColors.primaryColor,
                      onTap: loading
                          ? () {}
                          : () => controller.onTapAddFriendButton(userId),
                      image: '',
                    );
                }
              }),
          ],
        ),
      ),
    );
  }
}

Widget _buildButton({
  required String title,
  required String image,
  required VoidCallback onTap, // This was being passed but ignored
  required Color color,
}) {
  return GestureDetector(
    onTap: onTap, // <--- Add this!
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        ],
      ),
    ),
  );
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundImage:
                  (avatar != null && avatar!.startsWith('http'))
                      ? NetworkImage(avatar!)
                      : const AssetImage(AppImages.profileImage) as ImageProvider,
                ),
                SizedBox(width: 12.w),
                CommonText(
                  text: userName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.message),
                  child: Icon(Icons.chat_bubble_outline, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        child: Padding(
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Remove Friend?"),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => Get.back(),
                                      child: const Text("Cancel"),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.removeFriend(friendshipId);
                                        Get.back();
                                      },
                                      child: const Text("Unfriend"),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.close, size: 20.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
