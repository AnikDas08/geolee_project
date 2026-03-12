import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:giolee78/utils/enum/enum.dart';
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
  late final ClickerController clickerController;
  late final MyFriendController friendController;

  @override
  void initState() {
    super.initState();

    clickerController = Get.isRegistered<ClickerController>()
        ? Get.find<ClickerController>()
        : Get.put(ClickerController());

    friendController = Get.isRegistered<MyFriendController>()
        ? Get.find<MyFriendController>()
        : Get.put(MyFriendController());

    // Clear previous user data
    clickerController.usersPosts.clear();
    clickerController.userData.value = null;

    clickerController.getPostsByUserId(widget.userId);
    clickerController.getUserById(widget.userId);
    friendController.checkFriendship(widget.userId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, size: 26.sp, color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (clickerController.isUserLoading.value) {
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
                Obx(
                  () => ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = clickerController.usersPosts[index];

                      final List<String> postImages = data.photos.isNotEmpty
                          ? data.photos.map((p) {
                              if (p.startsWith('http')) return p;
                              return p.startsWith('/')
                                  ? "${ApiEndPoint.imageUrl}$p"
                                  : "${ApiEndPoint.imageUrl}/$p";
                            }).toList()
                          : [];

                      return CommonPostCards(
                        onTapPhoto: () {
                          if (postImages.isNotEmpty) {
                            Get.to(
                              () => FullScreenImageView(images: postImages),
                            );
                          }
                        },
                        onTapProfile: () => Get.to(
                          () => ViewFriendScreen(
                            userId: data.user.id,
                            isFriend: false,
                          ),
                        ),
                        clickerType: data.clickerType,
                        userName: data.user.name,
                        userAvatar: "${ApiEndPoint.imageUrl}${data.user.image}",
                        timeAgo: _formatPostTime(
                          DateTime.parse(data.createdAt.toString()),
                        ),
                        location: data.address.isNotEmpty
                            ? data.address.split(',')[0]
                            : "",
                        images: postImages,
                        description: data.description,
                        isFriend:
                            friendController.getFriendStatus(widget.userId) ==
                            FriendStatus.friends,
                        privacyImage: _getPrivacyIcon(data.privacy),
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemCount: clickerController.usersPosts.length,
                  ),
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
      final user = clickerController.userData.value;

      if (clickerController.isUserLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          /// PROFILE IMAGE
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  (user != null && user.image != null && user.image!.isNotEmpty)
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

          /// ADDRESS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonImage(imageSrc: AppIcons.location, size: 12),
              SizedBox(width: 8.w),
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

          /// FRIEND ACTION BUTTON
          if (widget.userId != LocalStorage.userId)
            Obx(() {
              final status = friendController.getFriendStatus(widget.userId);
              final loading = friendController.isUserLoading(widget.userId);

              if (status == FriendStatus.friends) {
                return _buildButton(
                  title: 'Message',
                  image: AppIcons.chat2,
                  color: AppColors.primaryColor,
                  onTap: () {
                    clickerController.createOrGetChatAndGo(
                      receiverId: widget.userId,
                      name: user?.name ?? "",
                      image: user?.image ?? "",
                    );
                  },
                );
              }

              if (status == FriendStatus.requested) {
                return _buildButton(
                  title: loading ? 'Cancelling...' : 'Cancel Request',
                  image: AppIcons.friendRequest,
                  color: Colors.grey,
                  onTap: loading
                      ? () {}
                      : () =>
                            friendController.cancelFriendRequest(widget.userId),
                );
              }

              if (status == FriendStatus.received) {
                return _buildFriendRequest(widget.userId);
              }

              // FriendStatus.none
              return _buildButton(
                title: loading ? 'Sending...' : 'Add Friend',
                image: AppIcons.friendRequest,
                color: AppColors.primaryColor2,
                onTap: loading
                    ? () {}
                    : () =>
                          friendController.onTapAddFriendButton(widget.userId),
              );
            }),
        ],
      );
    });
  }

  Widget _buildButton({
    required String title,
    required String image,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _buildFriendRequest(String userId) {
    return Obx(() {
      final requestId = friendController.pendingRequestIdMap[userId] ?? "";
      final isProcessing = friendController.processingRequestIds.contains(
        requestId,
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 32.h,
            width: 90.w,
            child: CommonButton(
              onTap: isProcessing
                  ? () {}
                  : () async {
                      if (requestId.isEmpty) return;
                      await friendController.acceptFriendRequest(requestId);
                    },
              titleText: isProcessing ? '...' : 'Accept',
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
              onTap: isProcessing
                  ? () {}
                  : () async {
                      if (requestId.isEmpty) return;
                      await friendController.rejectFriendRequest(requestId);
                    },
              titleText: isProcessing ? '...' : 'Reject',
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
    });
  }

  String _getPrivacyIcon(String privacy) {
    final p = privacy.toLowerCase().trim();
    if (p == 'public') return AppIcons.public;
    if (p == 'friend' || p == 'friends') return AppIcons.friends;
    return AppIcons.onlyMe;
  }
}
