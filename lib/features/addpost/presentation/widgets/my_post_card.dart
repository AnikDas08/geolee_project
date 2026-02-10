import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/addpost/presentation/screen/edit_post.dart';
import 'package:giolee78/features/profile/presentation/controller/post_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'confirm_delete_dialog.dart';

// Enum for post actions
enum PostAction { edit, delete, privacy }

class MyPostCard extends StatefulWidget {
  const MyPostCard({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    required this.images,
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
  final List<String> images;
  final String description;
  final bool isMyPost;
  final String clickerType;
  final String privacyImage;
  final VoidCallback onTapProfile;
  final VoidCallback onTapPhoto;
  final bool isProfile;
  final String postId;

  @override
  State<MyPostCard> createState() => _MyPostCardState();
}

class _MyPostCardState extends State<MyPostCard> {
  int currentIndex = 0;
  late final MyPostController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyPostController());
  }

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
                        onTap: widget.isProfile
                            ? widget.onTapProfile
                            : () => debugPrint('Already Profile'),
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: CommonImage(
                              imageSrc: widget.userAvatar,
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
                              text: widget.userName,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                                  text: widget.timeAgo,
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CommonText(
                                          text: widget.location,
                                          fontSize: 11,
                                          color: AppColors.secondaryText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      CommonImage(imageSrc: widget.privacyImage),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isMyPost) _buildPopupMenuButton(context),
              ],
            ),
          ),

          /// Image Slider with dot indicator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: _PostImageSlider(
              images: widget.images,
              onTapPhoto: widget.onTapPhoto,
              currentIndex: currentIndex,
              onPageChanged: (index) => setState(() => currentIndex = index),
            ),
          ),

          /// Clicker type
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
            child: CommonText(
              text: widget.clickerType,
              fontSize: 12,
            ),
          ),

          /// Description
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
            child: CommonText(
              text: widget.description,
              fontSize: 12,
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuButton(BuildContext context) {
    final MyPostController myPostController = Get.put(MyPostController());

    return PopupMenuButton<PostAction>(
      color: Colors.white,
      icon: Icon(Icons.more_vert_rounded,
          size: 24.sp, color: AppColors.secondaryText),
      itemBuilder: (context) => [
        _popupItem(
          PostAction.edit,
          Icons.edit_outlined,
          "Edit Post",
              () {
            Navigator.pop(context);
            Get.to(EditPost(postId: widget.postId))?.then((value) {
              if (value == true) myPostController.fetchMyPosts();
            });
          },
        ),
        _popupItem(
          PostAction.delete,
          Icons.delete_outline,
          "Delete Post",
              () {
            Navigator.pop(context);
            showDeletePostDialog(
              context,
              onConfirmDelete: () => myPostController.deletePost(widget.postId),
            );
          },
        ),
      ],
    );
  }

  PopupMenuItem<PostAction> _popupItem(

      PostAction value, IconData icon, String title, VoidCallback onTap) {
    return PopupMenuItem<PostAction>(
      value: value,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 10.w),
            Text(title),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// IMAGE SLIDER WITH DOT INDICATOR
/// =======================================================
class _PostImageSlider extends StatelessWidget {
  final List<String> images;
  final VoidCallback onTapPhoto;
  final int currentIndex;
  final Function(int) onPageChanged;

  const _PostImageSlider({
    required this.images,
    required this.onTapPhoto,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            height: 190.h,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) => InkWell(
                onTap: onTapPhoto,
                child: CommonImage(
                  imageSrc: images[index],
                  width: double.infinity,
                  height: 190.h,
                  fill: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: currentIndex == index ? 8.r : 6.r,
                  height: currentIndex == index ? 8.r : 6.r,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.primaryColor
                        : AppColors.secondaryText.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
