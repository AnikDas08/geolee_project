import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:intl/intl.dart';

import '../../../addpost/presentation/widgets/full_screen_view_image.dart';
import '../../../clicker/presentation/widget/common_post_card.dart';

class ViewFriendScreen extends StatefulWidget {
  final bool isFriend;
  final bool isRequest;
  final String userId;

  const ViewFriendScreen({
    super.key,
    required this.isFriend,
    required this.userId,
    this.isRequest = false,
  });

  @override
  State<ViewFriendScreen> createState() => _ViewFriendScreenState();
}

class _ViewFriendScreenState extends State<ViewFriendScreen> {
  final ClickerController controller = Get.find();

  @override
  void initState() {
    super.initState();

    // Fetch posts by user ID
    controller.getPostsByUserId(widget.userId);
    controller.getUserById(widget.userId);
    controller.checkFriendship(widget.userId);
  }

  String _formatPostTime(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inDays >= 1) {
      return DateFormat('MMM dd, yyyy').format(postTime);
    } else {
      return DateFormat('hh:mm a').format(postTime);
    }
  }

  String get friendImage {
    final user = controller.userData.value;

    if (user == null || user.image!.isEmpty) {
      return "";
    }

    return "http://10.10.7.7:5006${user.image}";
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
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isUserLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                16.height,
                CommonText(
                  text: 'User Posts',
                  fontSize: 16.sp,
                  left: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColorFirst,
                  textAlign: TextAlign.start,
                ).start,
                ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = controller.usersPosts[index];

                    final List<String> postImages = data.photos.isNotEmpty
                        ? data.photos
                        .map((photo) => ApiEndPoint.imageUrl + photo)
                        .toList()
                        : [];

                    return CommonPostCards(
                      onTapPhoto: () {
                        if (postImages.isNotEmpty) {
                          Get.to(() => FullScreenImageView(
                            images: postImages,
                          ));
                        }
                      },

                      onTapProfile: () => Get.to(() => ViewFriendScreen(
                        userId: data.user.id,
                        isFriend: false,
                      )),
                      clickerType: data.clickerType,
                      userName: data.user.name,
                      userAvatar: "${ApiEndPoint.imageUrl}${data.user.image}",
                      timeAgo: _formatPostTime(DateTime.parse(data.createdAt.toString())),
                      location: data.address.isNotEmpty
                          ? data.address.split(',')[0]
                          : "",
                      images: data.photos.isNotEmpty
                          ? data.photos
                          .map((photo) => ApiEndPoint.imageUrl + photo)
                          .toList()
                          : [],
                      description: data.description,
                      isFriend: false,
                      privacyImage: data.privacy == "public" ? AppIcons.public : AppIcons.onlyMe,
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemCount: controller.usersPosts.length,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final user = controller.userData.value;
      if (controller.isUserLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          /// PROFILE IMAGE
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: (user != null && user.image!.isNotEmpty)
                  ? NetworkImage("${ApiEndPoint.imageUrl}${user.image}")
                  : const AssetImage("assets/images/profile.png")
                        as ImageProvider,
            ),
          ),

          SizedBox(height: 12.h),

          /// NAME
          CommonText(
            text: user?.name ?? "User Name",
            fontWeight: FontWeight.w600,
            top: 16,
          ),

          /// BIO
          CommonText(
            text: user?.bio ?? "No bio available",
            fontSize: 13,
            bottom: 4,
            left: 40,
            right: 40,
            maxLines: 2,
            color: AppColors.secondaryText,
          ),

          /// DIVIDER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Divider(height: 2.h),
          ),

          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonImage(imageSrc: AppIcons.location, size: 12),
              SizedBox(width: 8.w),

              /// 👇 IMPORTANT PART
              Flexible(
                child: CommonText(
                  maxLines: 4,
                  text: user?.address ?? "Address not available",
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),


          SizedBox(height: 16.h),

          if(widget.userId!=LocalStorage.userId)

          Obx(() {
            switch (controller.friendStatus.value) {
              /// ✅ ALREADY FRIEND
              case FriendStatus.friends:
                return _buildButton(
                  title: 'Message',
                  image: AppIcons.chat2,
                  color: AppColors.primaryColor,
                  onTap: () {
                    Get.toNamed(AppRoutes.message);
                  },
                );

              /// 📤 REQUEST SENT
              case FriendStatus.requested:
                return _buildButton(
                  title: controller.isLoading.value
                      ? 'Cancelling...'
                      : 'Cancel Request',
                  image: AppIcons.friendRequest,
                  color: Colors.grey,
                  onTap: controller.isLoading.value
                      ? () {}
                      : () {
                          controller.cancelFriendRequest(widget.userId);
                        },
                );

              /// ➕ NOT FRIEND
              case FriendStatus.none:
              default:
                return _buildButton(
                  title: controller.isLoading.value
                      ? 'Sending...'
                      : 'Add Friend',
                  image: AppIcons.friendRequest,
                  color: AppColors.primaryColor2,
                  onTap: controller.isLoading.value
                      ? () {}
                      : () => controller.onTapAddFriendButton(widget.userId),
                );
            }
          }),
        ],
      );
    });
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
            CommonImage(imageSrc: image),
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

  Widget _buildFriendRequest() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 32.h,
          width: 90.w,
          child: CommonButton(
            titleText: 'Accept',
            buttonRadius: 6.r,
            titleSize: 14.sp,
            buttonHeight: 32.h,
            buttonWidth: 90.w,
          ),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          height: 32.h,
          width: 90.w,
          child: CommonButton(
            titleText: 'Reject',
            buttonColor: const Color(0xFFDEE2E3),
            titleColor: AppColors.secondaryText,
            buttonRadius: 6.r,
            titleSize: 14.sp,
            borderColor: AppColors.blueLight,
            buttonHeight: 32.h,
            buttonWidth: 90.w,
          ),
        ),
      ],
    );
  }
}
