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

class _MyPostScreenState extends State<MyPostScreen>
    with WidgetsBindingObserver {
  final MyPostController controller = Get.put(MyPostController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);


    scrollController.addListener(() {
      if (!controller.isLoadMore.value &&
          controller.hasMore &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
        controller.fetchMyPosts(loadMore: true);
      }
    });
  }

  @override
  void didPopNext() {
    controller.fetchMyPosts();
  }

  @override
  void dispose() {
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  String _removeNumbersFromLocation(String address) {
    final String firstPart = address.split(',')[0].trim();
    final String cleaned = firstPart.replaceAll(RegExp(r'[0-9]'), '');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
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
        ),
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
              controller: scrollController,

              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),

              itemCount: controller.myPost.length + 1,

              separatorBuilder: (_, __) => SizedBox(height: 12.h),

              itemBuilder: (context, index) {
                if (index == controller.myPost.length) {
                  return controller.isLoadMore.value
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const SizedBox();
                }

                final data = controller.myPost[index];

                final List<String> postImages = data.photos.isNotEmpty
                    ? data.photos
                    .map((photo) => ApiEndPoint.imageUrl + photo)
                    .toList()
                    : [];

                return MyPostCard(
                  onTapProfile: () {
                    debugPrint('Profile Tab');
                  },

                  isProfile: true,

                  onTapPhoto: () {
                    if (postImages.isNotEmpty) {
                      Get.to(() => FullScreenImageView(images: postImages));
                    }
                  },

                  clickerType: data.clickerType,

                  isMyPost: true,

                  userName: data.user.name ?? "Unknown",

                  userAvatar: "${ApiEndPoint.imageUrl}${data.user.image}",

                  timeAgo: _formatPostTime(
                    DateTime.parse(data.createdAt.toString()),
                  ),

                  location: data.address.isNotEmpty
                      ? _removeNumbersFromLocation(data.address)
                      : "",

                  images: postImages,

                  description: data.description ?? "No description",

                  privacyImage: data.privacy == "public"
                      ? AppIcons.public
                      : data.privacy == "friends"
                      ? AppIcons.friends
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