import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/features/clicker/presentation/widget/app_bar.dart';
import 'package:giolee78/features/clicker/presentation/widget/my_post_card.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/constants/app_string.dart';

class ClickerScreen extends StatelessWidget {
  ClickerScreen({super.key});

  final ClickerController controller = Get.put(ClickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(notificationCount: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CommonTextField(
              prefixIcon: const Icon(Icons.search),
              hintText: AppString.searchDoctor,
              borderRadius: 20.r,
            ),
            CarouselSlider(
              items: controller.banners,
              options: CarouselOptions(
                height: 200.h,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: controller.currentPosition,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.2,
                onPageChanged: (index, reason) {
                  controller.changePosition(index);
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
            Obx(() {
              return DotsIndicator(
                dotsCount: controller.banners.length,
                position: controller.currentPosition,
                decorator: DotsDecorator(
                  activeColor: AppColors.primaryColor,
                  color: Colors.grey,
                  size: const Size.square(9.0),
                  activeSize: const Size.square(9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              );
            }),
            Row(
              children: [
                CommonText(
                  text: 'All Posts',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorFirst,
                  textAlign: TextAlign.start,
                ),
                const Spacer(),
                CommonText(
                  text: 'See All',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColorFirst,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return MyPostCard(
                  userName: 'John Doe',
                  userAvatar: AppImages.profileImage,
                  timeAgo: '2 hours ago',
                  location: 'New York, NY',
                  postImage: AppImages.postImage,
                  description: 'This is a test post.',
                  isFriend: index % 2 == 0,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
