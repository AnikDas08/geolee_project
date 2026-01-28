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

class ViewFriendScreen extends StatelessWidget {
  final bool isFriend;
  final bool isRequest;
  const ViewFriendScreen({
    super.key,
    required this.isFriend,
    this.isRequest = false,
  });




  @override
  Widget build(BuildContext context) {
    final ClickerController controller=Get.put(ClickerController());
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              16.height,
              CommonText(
                text: 'Dianne’s Post',
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
                  // Later: read posts from Riverpod and pass here
                  final data=controller.banners[index];
                  return MyPostCard(
                    userName: 'Dianne Russell',
                    userAvatar: AppImages.profileImage,
                    timeAgo: '6 Min Ago',
                    location: 'Mohakhali Dhaka',
                    postImage: index == 0
                        ? AppImages.postImage
                        : AppImages.postImage,
                    description:
                        'Take A Break And Enjoy The Beauty Of Nature.\n'
                        'A Peaceful Park, Fresh Air, And The Perfect Spot To Unwind.\n'
                        'Whether You’re Looking To Relax Or Take A Walk, This Serene Green Space Has It All.',
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemCount: controller.banners.length, // later: posts.length
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final ClickerController controller = Get.find();
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50.sp,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: CommonImage(
                imageSrc: "assets/images/profile_image.png",
                size: 100,
                defaultImage: AppImages.profileImage,
              ),
            ),
          ),
        ),

        /// User Name here
        CommonText(
          text: "John Doe",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          top: 16,
        ),
        CommonText(
          text: "Exploring one city at a time Capturing stories beyond borders",
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage(imageSrc: AppIcons.location, size: 12),
            SizedBox(width: 8.w),
            CommonText(
              text: 'Thornridge Cir. Shiloh, Hawaii',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
              textAlign: TextAlign.start,
            ),
          ],
        ),

        SizedBox(height: 16.h),

        isRequest
            ? _buildFriendRequest()
            : isFriend
            ? GestureDetector(
          onTap: (){
            Get.toNamed(AppRoutes.message);
          },
              child: _buildButton(
                  title: 'Message',
                  image: AppIcons.chat2,
                  onTap: () {},
                  color: AppColors.primaryColor,
                ),
            )
            : _buildButton(
                title: 'Add Friend',
                image: AppIcons.friendRequest,
                onTap: () {},
                color: AppColors.primaryColor2,
              ),
      ],
    );
  }

  Widget _buildButton({
    required String title,
    required String image,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 7,
            children: [
              CommonImage(imageSrc: image),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white /* Text-White */,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
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
            buttonColor: Color(0xFFDEE2E3),
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
