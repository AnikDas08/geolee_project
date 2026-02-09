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
        // Loading indicator while fetching all posts
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search bar with clear button
              CommonTextField(
                controller: controller.searchController,
                prefixIcon: const Icon(Icons.search),
                hintText: "Search",
                borderRadius: 20.r,
                suffixIcon: Obx(
                  () => controller.searchText.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),

              CarouselSlider(
                items: controller.banners,
                options: CarouselOptions(
                  height: 150.h,
                  viewportFraction: 0.6,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    controller.changePosition(index);
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Dots Indicator
              Obx(() {
                return DotsIndicator(
                  dotsCount: controller.banners.length,
                  position: controller.currentPosition.toInt(),
                  decorator: DotsDecorator(
                    activeColor: AppColors.primaryColor,
                    color: Colors.grey,
                    size: const Size.square(8.0),
                    activeSize: const Size.square(8.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Filter button and title
              Row(
                children: [
                  const Text(
                    'All Posts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  _buildFilterButton(context),
                ],
              ),
              const SizedBox(height: 16),

              // Posts list or empty state
              controller.filteredPosts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Center(
                        child: Text(
                          controller.searchText.value.isNotEmpty
                              ? "No posts found for '${controller.searchText.value}'"
                              : "No posts available",
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredPosts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final data = controller.filteredPosts[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => ViewFriendScreen(
                                userId: data.user.id,
                                isFriend: index % 2 == 0,
                              ),
                            );
                          },
                          child: MyPostCards(
                            onTapPhoto: () {
                              if (data.photos.isNotEmpty) {
                                Get.to(
                                  () => FullScreenImageView(
                                    imageUrl:
                                        "${ApiEndPoint.imageUrl}${data.photos[0]}",
                                  ),
                                );
                              }
                            },
                            onTapProfile: () {
                              Get.to(
                                () => ViewFriendScreen(
                                  userId: data.user.id,
                                  isFriend: index % 2 == 0,
                                ),
                              );
                            },
                            clickerType: data.clickerType,
                            userName: data.user.name,
                            userAvatar:
                                "${ApiEndPoint.imageUrl}${data.user.image}",
                            timeAgo: _formatPostTime(
                              DateTime.parse(data.createdAt.toString()),
                            ),
                            location: data.address,
                            postImage: data.photos.isNotEmpty
                                ? "${ApiEndPoint.imageUrl}${data.photos[0]}"
                                : "",
                            description: data.description,
                            isFriend: index % 2 == 0,
                            privacyImage: data.privacy == "public"
                                ? AppIcons.public
                                : AppIcons.onlyMe,
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFDEE2E3), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Text(
                controller.selectedFilter,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              height: 20,
              child: CommonImage(imageSrc: AppIcons.filter),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet for filter options
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.filterOptions.map((option) {
              final isSelected = controller.selectedFilter == option;
              return InkWell(
                onTap: () {
                  controller.changeFilter(option); // Apply filter
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        option,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        });
      },
    );
  }
}
