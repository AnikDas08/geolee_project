import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/addpost/presentation/widgets/my_post_card.dart';
import 'package:giolee78/features/profile/presentation/controller/post_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/app_icons.dart';
import '../widgets/full_screen_view_image.dart';

class MyPostScreen extends StatefulWidget {
  const MyPostScreen({super.key});

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

// Add WidgetsBindingObserver here
class _MyPostScreenState extends State<MyPostScreen> with WidgetsBindingObserver {
  final MyPostController controller = Get.put(MyPostController());

  @override
  void initState() {
    super.initState();
    // Add observer
    WidgetsBinding.instance.addObserver(this);
    controller.fetchMyPosts();
  }

  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override // Add @override annotation
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.fetchMyPosts();
    }
  }

  String _formatPostTime(DateTime postTime) {
    final now = DateTime.now();
    final difference = now.difference(postTime);
    return difference.inDays >= 1
        ? DateFormat('MMM dd, yyyy').format(postTime)
        : DateFormat('hh:mm a').format(postTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColors.black),
        ),
        centerTitle: true,
        title: const CommonText(text: 'My Post', fontSize: 18, fontWeight: FontWeight.w600),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.myPost.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.myPost.isEmpty) {
            return const Center(child: Text("No posts found."));
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchMyPosts(),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemCount: controller.myPost.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final data = controller.myPost[index];
                return MyPostCard(
                  onTapProfile: () {
                    debugPrint('Profile Tab');
                  },
                  isProfile: true,
                  onTapPhoto: () {
                    if (data.photos.isNotEmpty) {
                      Get.to(() => FullScreenImageView(
                        imageUrl: "${ApiEndPoint.imageUrl}${data.photos[0]}",
                      ));
                    }
                  },
                  clickerType: data.clickerType,
                  isMyPost: true,
                  userName: data.user.name ?? "Unknown",
                  userAvatar: "${ApiEndPoint.imageUrl}${data.user.image}",
                  timeAgo: _formatPostTime(DateTime.parse(data.createdAt.toString())),
                  location: data.address,
                  postImage: (data.photos.isNotEmpty)
                      ? "${ApiEndPoint.imageUrl}${data.photos[0]}"
                      : "",
                  description: data.description ?? "No description",
                  privacyImage: data.privacy == "public"
                      ? AppIcons.public
                      : AppIcons.onlyMe,
                  postId: data.id,
                );
              },
            ),
          );
        }),
      ),
    );
  }
}