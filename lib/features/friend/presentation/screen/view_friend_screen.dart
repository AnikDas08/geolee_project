import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/addpost/presentation/widgets/my_post_card.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:intl/intl.dart';

class ViewFriendScreen extends StatefulWidget {
  final bool isFriend;
  final bool isRequest;
  final String userId; // user id from ClickerScreen

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
    controller.getPostsByUser(widget.userId);
    controller.getUserById(widget.userId);
  }


  // Helper method - build এর বাইরে লিখুন
  String _formatPostTime(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);

    if (difference.inDays >= 7) {
      // ৭ দিনের বেশি হলে date দেখাবে
      return DateFormat('MMM dd, yyyy').format(postTime);
    } else {
      // ৭ দিনের মধ্যে হলে শুধু time দেখাবে
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
            // Loading effect while fetching posts
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.userPosts.isEmpty) {
            // Empty state if no posts
            return const Center(child: Text("No posts available"));
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = controller.userPosts[index];
                    return MyPostCard(
                      isMyPost: false,
                      userName: data.user.name,
                      userAvatar: "http://10.10.7.7:5006${data.user.image}",
                      timeAgo: _formatPostTime(DateTime.parse(data.createdAt.toString())),
                      location: data.address,
                      postImage: data.photos.isNotEmpty
                          ? "http://10.10.7.7:5006${data.photos[0]}"
                          : "",
                      description: data.description,
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemCount: controller.userPosts.length,
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
                  ? NetworkImage("http://10.10.7.7:5006${user.image}")
                  : const AssetImage("assets/images/profile.png") as ImageProvider,
            ),
          ),

          SizedBox(height: 12.h),

          /// NAME
          CommonText(
            text: user?.name ?? "User Name",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            top: 16,
          ),

          /// BIO
          CommonText(
            text: user?.bio ?? "No bio available",
            fontSize: 13,
            fontWeight: FontWeight.w400,
            bottom: 4,
            maxLines: 2,
            left: 40,
            right: 40,
            color: AppColors.secondaryText,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Divider(height: 2.h),
          ),

          SizedBox(height: 8.h),

          /// ADDRESS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage(imageSrc: AppIcons.location, size: 12),
              SizedBox(width: 8.w),
              CommonText(
                text: user?.address ?? "Address not available",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// FRIEND BUTTON
          /// FRIEND BUTTON
          Obx(() {
            // যদি ফ্রেন্ড হয়
            if (controller.friendStatus.value == FriendStatus.friends) {
              return _buildButton(
                title: 'Message',
                image: AppIcons.chat2,
                onTap: () => Get.toNamed(AppRoutes.message),
                color: AppColors.primaryColor,
              );
            }

            // যদি রিকোয়েস্ট পাঠানো হয়ে থাকে (বাটনটি ধূসর হয়ে থাকবে এবং ক্লিক কাজ করবে না)
            if (controller.friendStatus.value == FriendStatus.requested) {
              return _buildButton(
                title: 'Request Sent',
                image: AppIcons.friendRequest,
                onTap: () {}, // এখানে ফাংশন খালি রাখলে বাটনটি ডিজেবল হিসেবে কাজ করবে
                color: Colors.grey, // কালার গ্রে করে দেওয়া হলো
              );
            }

            // ডিফল্ট: অ্যাড ফ্রেন্ড
            return _buildButton(
              title: controller.isLoading.value ? 'Sending...' : 'Add Friend',
              image: AppIcons.friendRequest,
              onTap: controller.isLoading.value
                  ? () {}
                  : () => controller.onTapAddFriendButton(widget.userId),
              color: AppColors.primaryColor2,
            );
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
            onTap: null,
            titleText: 'Accept',
            buttonColor: AppColors.primaryColor,
            titleColor: AppColors.white,
            buttonRadius: 6.r,
            titleSize: 14.sp,
            borderColor: AppColors.primaryColor,
            buttonHeight: 32.h,
            buttonWidth: 90.w,
          ),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          height: 32.h,
          width: 90.w,
          child: CommonButton(
            onTap: null,
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
