import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/features/home/presentation/widgets/my_post_card.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class MyPostScreen extends StatelessWidget {
  const MyPostScreen({super.key});

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
        title: const CommonText(
          text: 'My Post',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            // Later: read posts from Riverpod and pass here
            return MyPostCard(
              userName: 'Dianne Russell',
              userAvatar: AppImages.profileImage,
              timeAgo: '6 Min Ago',
              location: 'Thornridge Cir, Shiloh, Hawaii',
              postImage: index == 0 ? AppImages.postImage : AppImages.postImage,
              description:
                  'Take A Break And Enjoy The Beauty Of Nature.\n'
                  'A Peaceful Park, Fresh Air, And The Perfect Spot To Unwind.\n'
                  'Whether You’re Looking To Relax Or Take A Walk, This Serene Green Space Has It All.',
            );
          },
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemCount: 2, // later: posts.length
        ),
      ),
    );
  }
}
