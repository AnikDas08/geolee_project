import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/chat_nearby/data/nearby_friends_model.dart';
import 'package:giolee78/features/chat_nearby/presentation/controller/chat_nearby_profile_controller.dart';

import '../../../../component/button/common_button.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../../../../utils/constants/app_images.dart';

class ChatNearbyProfileScreen extends StatefulWidget {
  const ChatNearbyProfileScreen({
    super.key,
    required this.user,
    this.onTapProfile,
    this.onSendGreetings,
  });

  final NearbyChatUserModel user;
  final VoidCallback? onTapProfile;
  final VoidCallback? onSendGreetings;

  @override
  State<ChatNearbyProfileScreen> createState() =>
      _ChatNearbyProfileScreenState();
}

class _ChatNearbyProfileScreenState extends State<ChatNearbyProfileScreen> {
  late ChatNearbyProfileController controller;
  late TextEditingController greetingsController;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize controllers once
    greetingsController = TextEditingController();

    // ✅ Get or create controller with tag
    controller = Get.put(
      ChatNearbyProfileController(),
      tag: widget.user.id.toString(),
    );

    // ✅ Load data after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.fetchUserProfile(widget.user.id.toString());
        controller.checkFriendship(widget.user.id.toString());
      }
    });
  }

  @override
  void dispose() {
    // ✅ Dispose controllers to prevent memory leaks
    greetingsController.dispose();
    // Don't dispose GetX controller here - GetX manages it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => _ChatNearbyProfileAppBar(
          status: controller.friendStatus.value,
          onTapAdd: () {
            controller.addFriend(widget.user.id.toString());
          },
          onTapCancel: () {
            controller.cancelRequest(widget.user.id.toString());
          },
        )),
      ),
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          // Show error state
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    controller.error.value,
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        controller.fetchUserProfile(widget.user.id.toString()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              children: [
                _ProfileHeader(userProfile: controller.userProfile.value),
                SizedBox(height: 24.h),
                _GreetingsInput(controller: greetingsController),
                SizedBox(height: 24.h),
                Obx(() => CommonButton(
                  titleText: controller.isLoading.value
                      ? 'Sending...'
                      : 'Send Greetings',
                  buttonHeight: 48.h,
                  buttonRadius: 6.r,
                  onTap: () {
                    if (mounted) {
                      controller.sendGreeting(greetingsController);
                    }
                  },
                )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ChatNearbyProfileAppBar extends StatelessWidget {
  const _ChatNearbyProfileAppBar({
    required this.status,
    required this.onTapAdd,
    required this.onTapCancel,
  });

  final FriendStatus status;
  final VoidCallback onTapAdd;
  final VoidCallback onTapCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18.sp,
                  color: AppColors.black,
                ),
              ),
              const Spacer(),

              // Logic for the action icon
              if (status == FriendStatus.none)
                IconButton(
                  onPressed: onTapAdd,
                  icon: CommonImage(
                    imageSrc: AppIcons.addFriend,
                    size: 22.sp,
                  ),
                )
              else if (status == FriendStatus.requested)
                IconButton(
                  onPressed: onTapCancel,
                  icon: Icon(
                    Icons.person_remove_alt_1,
                    color: Colors.red,
                    size: 22.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic userProfile;

  const _ProfileHeader({this.userProfile});

  @override
  Widget build(BuildContext context) {
    final name = userProfile?['name'] ?? 'User';
    final bio = userProfile?['bio'] ?? 'No bio available';
    final imageUrl = userProfile?['image'] ?? '';
    final location = userProfile?['address'] ?? 'Location not available';
    final distance = "0";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Container(
            height: 100.h,
            width: 100.w,
            child: imageUrl.isNotEmpty
                ? CommonImage(
              imageSrc: ApiEndPoint.imageUrl + imageUrl,
              defaultImage: AppImages.profileImage,
            )
                : Image.asset(
              AppImages.profileImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        CommonText(
          text: name,
          fontWeight: FontWeight.w600,
          top: 16,
        ),
        CommonText(
          text: bio,
          fontSize: 13,
          color: AppColors.secondaryText,
          maxLines: 2,
          left: 40,
          right: 40,
          top: 4,
        ),
        SizedBox(height: 8.h),
        CommonText(
          text: 'Within $distance KM',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor2,
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage(imageSrc: AppIcons.location, size: 12.r),
              SizedBox(width: 8.w),
              CommonText(
                text: location,
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FriendActionButton extends StatelessWidget {
  final ChatNearbyProfileController controller;
  final String userId;

  const FriendActionButton({
    super.key,
    required this.controller,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.friendStatus.value) {
        case FriendStatus.none:
          return CommonButton(
            titleText: "Add Friend",
            onTap: () => controller.addFriend(userId),
          );

        case FriendStatus.requested:
          return CommonButton(
            titleText: "Requested (Cancel)",
            buttonColor: Colors.orange,
            onTap: () => controller.cancelRequest(userId),
          );

        case FriendStatus.friends:
          return CommonButton(
            titleText: "Friends",
            buttonColor: Colors.grey,
            onTap: () {},
          );
      }
    });
  }
}

class ProfileAvatar extends StatelessWidget {
  final Map<String, dynamic>? profile;

  const ProfileAvatar({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile?['image'] ?? '';
    final isPublic = profile?['privacy'] == "public";

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: SizedBox(
            height: 100.h,
            width: 100.w,
            child: imageUrl.isNotEmpty
                ? CommonImage(
              imageSrc: ApiEndPoint.imageUrl + imageUrl,
              defaultImage: AppImages.profileImage,
            )
                : Image.asset(AppImages.profileImage, fit: BoxFit.cover),
          ),
        ),

        /// 🔒 show when not public
        if (!isPublic)
          Container(
            height: 100.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock, color: Colors.white, size: 28.sp),
          ),
      ],
    );
  }
}

class _GreetingsInput extends StatelessWidget {
  const _GreetingsInput({this.controller});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          text: 'Type Your Greetings:',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textColorFirst,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 8.h),
        CommonTextField(
          controller: controller,
          maxLines: 6,
          paddingHorizontal: 12,
          paddingVertical: 12,
        ),
      ],
    );
  }
}