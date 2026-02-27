import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:intl/intl.dart';

import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/features/clicker/presentation/widget/app_bar.dart';
import 'package:giolee78/features/clicker/presentation/widget/common_post_card.dart';
import 'package:giolee78/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import '../../../addpost/presentation/widgets/full_screen_view_image.dart';
import '../../../friend/presentation/screen/view_friend_screen.dart';
import '../widget/webview_screen.dart';

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

  // ScrollController to detect bottom scroll for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Trigger load more when within 300px of bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!controller.isLoadingMore.value &&
          !controller.isLoading.value &&
          controller.currentPage.value < controller.totalPages.value) {
        controller.getAllPosts(isLoadMore: true);
      }
    }
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
      appBar: const CustomAppBar(notificationCount: 0),
      body: Obx(() {
        // Initial loading state (empty list)
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.getBanners();
            await controller.getAllPosts();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                if (LocalStorage.token.isNotEmpty)
                  CommonTextField(
                    controller: controller.searchController,
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search",
                    borderRadius: 20.r,
                    suffixIcon: controller.searchText.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                SizedBox(height: 16.h),

                // ── Banner Slider ───────────────────────────────────────
                if (controller.adList.isNotEmpty) ...[
                  CarouselSlider(
                    items: controller.adList.map((ad) {
                      return GestureDetector(
                        onTap: () {
                          controller.clickBanner(ad.id);
                          if (ad.websiteUrl != null &&
                              ad.websiteUrl!.isNotEmpty) {
                            Get.to(
                              () => CommonWebViewScreen(
                                url: ad.websiteUrl!,
                                title: ad.title,
                              ),
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CommonImage(
                            imageSrc: "${ApiEndPoint.imageUrl}${ad.image}",
                            height: 150.h,
                            width: double.infinity,
                            fill: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 150.h,
                      viewportFraction: 0.85,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, _) =>
                          controller.changePosition(index),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: DotsIndicator(
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
                  ),
                ],

                SizedBox(height: 16.h),

                // ── Header & Filter ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildFilterButton(context),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Posts List ──────────────────────────────────────────
                controller.filteredPosts.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredPosts.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final data = controller.filteredPosts[index];
                          final List<String> postImages = data.photos.isNotEmpty
                              ? data.photos
                                    .map((p) => ApiEndPoint.imageUrl + p)
                                    .toList()
                              : [];

                          return CommonPostCards(
                            onTapPhoto: () {
                              if (postImages.isNotEmpty) {
                                Get.to(
                                  () => FullScreenImageView(images: postImages),
                                );
                              }
                            },
                            onTapProfile: () {

                              if(LocalStorage.token.isNotEmpty)
                              Get.to(
                                () => ViewFriendScreen(
                                  userId: data.user.id,
                                  isFriend: false,
                                ),
                              );
                            },
                            clickerType: data.clickerType,
                            userName: data.user.name,
                            userAvatar:
                                "${ApiEndPoint.imageUrl}${data.user.image}",
                            timeAgo: _formatPostTime(data.createdAt),
                            location: data.address.isNotEmpty
                                ? data.address.split(',')[0]
                                : "",
                            images: postImages,
                            description: data.description,
                            isFriend: false,
                            privacyImage: data.privacy == "public"
                                ? AppIcons.public
                                : data.privacy == "friends"
                                ? AppIcons.friends
                                : AppIcons.onlyMe,
                          );
                        },
                      ),

                Obx(() {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  // Show "end of posts" message only when all pages loaded
                  if (!controller.isLoading.value &&
                      controller.filteredPosts.isNotEmpty &&
                      controller.currentPage.value >=
                          controller.totalPages.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: Text(
                          "You've reached the end",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.post_add, size: 50, color: Colors.grey.shade400),
            SizedBox(height: 10.h),
            Text(
              controller.searchText.value.isNotEmpty
                  ? "No results for '${controller.searchText.value}'"
                  : "No posts available right now",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
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
            Text(
              controller.selectedFilter,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(width: 8),
            const CommonImage(imageSrc: AppIcons.filter, height: 18, width: 18),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter by Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            ...controller.filterOptions.map((option) {
              return Obx(() {
                final isSelected = controller.selectedFilter == option;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
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
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
