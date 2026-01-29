import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/addpost/presentation/widgets/my_post_card.dart';
import 'package:giolee78/features/profile/presentation/controller/post_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:intl/intl.dart';


class MyPostScreen extends StatefulWidget {
  const MyPostScreen({super.key});

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
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

  final MyPostController controller=MyPostController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchMyPosts();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyPostController>(
      builder: (controller) {
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
                final data=controller.myPost[index];
                return MyPostCard(
                  isMyPost:true,
                  userName: data.user!.name??"Not Foound",
                  userAvatar: "http://10.10.7.7:5006${data.user!.image}",
                  timeAgo: _formatPostTime(DateTime.parse(data.createdAt.toString())),
                  location: data.address,
                  postImage: data.photos!=null
                      ? "http://10.10.7.7:5006${data.photos[0]}"
                      : "",
                  description: data.description??"Not Found",
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemCount: controller.myPost.length, // later: posts.length
            ),
          ),
        );
      }
    );
  }
}
