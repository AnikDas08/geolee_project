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
import '../screen/ad_detail_screen.dart';
import 'package:giolee78/utils/debouncer.dart';

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

  final ScrollController _scrollController = ScrollController();
  final debouncer = Debouncer(milliseconds: 400);
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // controller.getAllPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Trigger load more when within 300px of bottom==============================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (isLoadingMore) return;

    debouncer.run(() {
      if (!_scrollController.hasClients) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        if (!controller.isLoadingMore.value &&
            !controller.isLoading.value &&
            controller.currentPage.value < controller.totalPages.value) {
          isLoadingMore = true;
          controller.getAllPosts(isLoadMore: true).then((_) {
            isLoadingMore = false;
          });
        }
      }
    });
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
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async {
            await controller.getBanners();
            await controller.getAllPosts();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              // Search & Suggestions
              if (LocalStorage.token.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        CommonTextField(
                          controller: controller.searchController,
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search Location",
                          borderRadius: 20.r,
                          suffixIcon: controller.searchText.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.searchText.value = '';
                                    controller.locationSuggestions.clear();
                                    controller.getAllPosts(); // fresh load
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Suggestions dropdown=================================
                        Obx(() {
                          if (controller.locationSuggestions.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            margin: EdgeInsets.only(top: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.locationSuggestions.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final suggestion =
                                    controller.locationSuggestions[index];
                                return ListTile(
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                  ),
                                  title: Text(
                                    suggestion,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  onTap: () {
                                    controller.onLocationSelected(suggestion);
                                    FocusScope.of(context).unfocus();
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // ── Banner Slider ==============================================
              if (LocalStorage.token.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.only(top: 16.h),
                  sliver: SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.adList.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
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
                                  } else {
                                    Get.to(() => AdDetailScreen(ad: ad));
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: CommonImage(
                                    imageSrc: ad.image,
                                    height: 150.h,
                                    width: double.infinity,
                                    fill: BoxFit.cover,
                                    memCacheWidth: 800,
                                    memCacheHeight: (150 * 2.5).toInt(),
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
                      );
                    }),
                  ),
                ),

              // ── Header & Filter=============================================
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                sliver: SliverToBoxAdapter(
                  child: Row(
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
                ),
              ),

              // ── Posts List==================================================
              Builder(
                builder: (context) {
                  final postsWithImages = controller.filteredPosts
                      .where((data) => data.photos.isNotEmpty)
                      .toList();

                  if (postsWithImages.isEmpty) {
                    return SliverToBoxAdapter(child: _buildEmptyState());
                  }

                  final int itemCount = LocalStorage.token.isEmpty
                      ? postsWithImages.length.clamp(0, 20)
                      : postsWithImages.length;

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final data = postsWithImages[index];
                        final List<String> postImages = data.photos.isNotEmpty
                            ? data.photos.map((p) {
                                if (p.startsWith('http')) return p;
                                return p.startsWith('/')
                                    ? "${ApiEndPoint.imageUrl}$p"
                                    : "${ApiEndPoint.imageUrl}/$p";
                              }).toList()
                            : [];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: CommonPostCards(
                            onTapPhoto: () {
                              if (postImages.isNotEmpty) {
                                Get.to(
                                  () => FullScreenImageView(images: postImages),
                                );
                              }
                            },
                            onTapProfile: () {
                              if (LocalStorage.token.isNotEmpty) {
                                Get.to(
                                  () => ViewFriendScreen(
                                    userId: data.user.id,
                                    isFriend: false,
                                  ),
                                );
                              }
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
                          ),
                        );
                      }, childCount: itemCount),
                    ),
                  );
                },
              ),

              // ── Footer Indicators ==========================================
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

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
              ),

              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
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
