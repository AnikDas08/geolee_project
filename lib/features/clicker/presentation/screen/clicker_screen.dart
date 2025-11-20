import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/features/clicker/presentation/widget/app_bar.dart';
import 'package:giolee78/features/clicker/presentation/widget/my_post_card.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
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
              hintText: AppString.search,
              borderRadius: 20.r,
            ),
            CarouselSlider(
              items: controller.banners,
              options: CarouselOptions(
                height: 150.h,
                aspectRatio: 16 / 9,
                viewportFraction: 0.5,
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
                _buildFilterSection(),
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
                  privacyImage: AppIcons.public,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFDEE2E3) /* Disable */,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          SizedBox(
            width: 53,
            child: Text(
              'All',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: CommonImage(imageSrc: AppIcons.filter),
          ),
        ],
      ),
    );
  }
}
