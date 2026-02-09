import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/features/clicker/presentation/widget/app_bar.dart';
import 'package:giolee78/features/clicker/presentation/widget/my_post_card.dart';
import 'package:giolee78/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:intl/intl.dart';
import '../../../addpost/presentation/widgets/full_screen_view_image.dart';
import '../../../friend/presentation/screen/view_friend_screen.dart';

class ClickerScreen extends StatefulWidget {
  const ClickerScreen({super.key});

  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> {
  final ClickerController controller = Get.put(ClickerController());
  final NotificationsController notificationsController = Get.put(
    NotificationsController(),
  );

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
      appBar: CustomAppBar(
        notificationCount: notificationsController.unreadCount,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getBanners();
            await controller.getAllPosts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Search bar
                CommonTextField(
                  controller: controller.searchController,
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search",
                  borderRadius: 20.r,
                  suffixIcon: controller.searchText.value.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.searchController.clear(),
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Dynamic Banner Slider
                if (controller.adList.isNotEmpty) ...[
                  CarouselSlider(
                    items: controller.adList.map((ad) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CommonImage(
                          imageSrc: "${ApiEndPoint.imageUrl}${ad.image}",
                          height: 150.h,
                          width: double.infinity,
                          fill: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 150.h,
                      viewportFraction: 0.8,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, _) => controller.changePosition(index),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DotsIndicator(
                    dotsCount: controller.adList.length,
                    position: controller.currentPosition,
                    decorator: DotsDecorator(
                      activeColor: AppColors.primaryColor,
                      color: Colors.grey.shade300,
                      size: const Size.square(8.0),
                      activeSize: const Size(18.0, 8.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Header & Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Posts',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    _buildFilterButton(context),
                  ],
                ),
                const SizedBox(height: 16),

                // Posts List
                controller.filteredPosts.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredPosts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = controller.filteredPosts[index];
                    return GestureDetector(
                      onTap: ()=>ViewFriendScreen(
                      userId: data.user.id,
                      isFriend: false, // Friendship state handled in controller
                    ),
                      child: MyPostCards(
                        onTapPhoto: () {
                          if (data.photos.isNotEmpty) {
                            Get.to(() => FullScreenImageView(
                              imageUrl: "${ApiEndPoint.imageUrl}${data.photos[0]}",
                            ));
                          }
                        },
                        onTapProfile: () => Get.to(() => ViewFriendScreen(
                          userId: data.user.id,
                          isFriend: false, // Friendship state handled in controller
                        )),
                        clickerType: data.clickerType,
                        userName: data.user.name,
                        userAvatar: "${ApiEndPoint.imageUrl}${data.user.image}",
                        timeAgo: _formatPostTime(DateTime.parse(data.createdAt.toString())),
                        location: data.address,
                        postImage: data.photos.isNotEmpty ? "${ApiEndPoint.imageUrl}${data.photos[0]}" : "",
                        description: data.description,
                        isFriend: false,
                        privacyImage: data.privacy == "public" ? AppIcons.public : AppIcons.onlyMe,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Text(
          controller.searchText.value.isNotEmpty
              ? "No posts found for '${controller.searchText.value}'"
              : "No posts available",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDEE2E3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Obx(() => Text(controller.selectedFilter)),
            const SizedBox(width: 8),
            CommonImage(imageSrc: AppIcons.filter, height: 20, width: 20),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.filterOptions.map((option) {
            return Obx(() {
              final isSelected = controller.selectedFilter == option;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.primaryColor : Colors.grey,
                ),
                title: Text(option),
                onTap: () {
                  controller.changeFilter(option);
                  Get.back();
                },
              );
            });
          }).toList(),
        ),
      ),
    );
  }
}