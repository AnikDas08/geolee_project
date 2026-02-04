import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/addpost/presentation/screen/edit_post.dart';
import 'package:giolee78/features/profile/presentation/controller/post_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

import 'confirm_delete_dialog.dart';

// Define an enum for the actions
enum PostAction { edit, delete, privacy }

class MyPostCard extends StatelessWidget {
  const MyPostCard({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    required this.postImage,
    required this.description,
    this.isMyPost = false,
    required this.clickerType,
    required this.privacyImage,
    required this.onTapProfile,
    required this.onTapPhoto,
    required this.isProfile,
    required this.postId,
  });

  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String location;
  final String postImage;
  final String description;
  final bool isMyPost;
  final String clickerType;
  final String privacyImage;
  final VoidCallback onTapProfile;
  final VoidCallback onTapPhoto;
  final bool isProfile;
  final String postId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [

                      InkWell(
                        onTap: isProfile ? onTapProfile : () {
                          debugPrint('Already Profile');
                        },
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: CommonImage(
                              imageSrc: userAvatar,
                              size: 36.r,
                              fill: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: userName,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12.sp,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 4.w),
                                CommonText(
                                  text: timeAgo,
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(width: 6.w),
                                Container(
                                  width: 3.r,
                                  height: 3.r,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondaryText,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12.sp,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 4.w),
                                CommonText(
                                  text: location,
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(width: 8.w),

                                CommonImage(imageSrc: privacyImage),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ),

                if (isMyPost) _buildPopupMenuButton(context),
              ],
            ),
          ),

          /// Image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: InkWell(
                onTap: onTapPhoto,
                child: CommonImage(
                  imageSrc: postImage,
                  width: double.infinity,
                  height: 190.h,
                  fill: BoxFit.cover,
                  borderRadius: 10.r,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CommonText(
              text: clickerType,
              fontSize: 12,
              textAlign: TextAlign.start,
              fontWeight: FontWeight.w800,
            ),
          ),

          /// Description
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            child: CommonText(
              text: description,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textColorFirst,
              textAlign: TextAlign.start,
              maxLines: 6,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 Helper method to build the PopupMenuButton
  Widget _buildPopupMenuButton(BuildContext context) {
    final MyPostController myPostController = Get.put(MyPostController());

    return PopupMenuButton<PostAction>(
      color: Colors.white,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 24.sp,
        color: AppColors.secondaryText,
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          PostAction.edit,
          Icons.edit_outlined,
          "Edit Post",
              () {
            Navigator.pop(context);
            Get.to(EditPost(postId: postId.toString(),));
          },
        ),
        _buildPopupMenuItem(
          PostAction.delete,
          Icons.delete_outline,
          "Delete Post",
              () {
            Navigator.pop(context);
            showDeletePostDialog(context, onConfirmDelete: () {
              myPostController.deletePost(postId.toString());
            });
          },
        ),
        _buildPopupMenuItem(
          PostAction.privacy,
          Icons.lock_outline,
          "Change Privacy",
              () {
            Navigator.pop(context);
          },
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      elevation: 4,
      padding: EdgeInsets.zero,
    );
  }


  PopupMenuItem<PostAction> _buildPopupMenuItem(
    PostAction value,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return PopupMenuItem<PostAction>(
      value: value,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.black),
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCircleIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.secondaryText),
      ),
    );
  }
}
