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

import '../../../friend/presentation/screen/view_friend_screen.dart';

class ClickerScreen extends StatelessWidget {
  ClickerScreen({super.key});

  final ClickerController controller = Get.put(ClickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(notificationCount: 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
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
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
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
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    CommonText(
                      text: 'All Posts',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorFirst,
                      textAlign: TextAlign.start,
                    ),
                    const Spacer(),
                    _buildFilterSection(context), // Pass context here
                  ],
                ),
              ),
              ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Get.to(() => ViewFriendScreen(isFriend: index % 2 == 0));
                    },
                    child: MyPostCards(
                      userName: 'John Doe',
                      userAvatar: AppImages.profileImage,
                      timeAgo: '2 hours ago',
                      location: 'New York, NY',
                      postImage: AppImages.postImage,
                      description: 'This is a test post.',
                      isFriend: index % 2 == 0,
                      privacyImage: AppIcons.public,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated to take BuildContext for showModalBottomSheet

  Widget _buildFilterSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFDEE2E3),
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
            // Replaced fixed-width SizedBox with Flexible to allow the text to expand
            Flexible(
              child: Obx(() => Text( // Use Obx to show the selected filter
                controller.selectedFilter,
                overflow: TextOverflow.ellipsis, // Ensures graceful handling if text is too long
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              )),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: CommonImage(imageSrc: AppIcons.filter),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the modal bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return _buildFilterContent(context);
      },
    );
  }


  // Widget to build the content inside the modal bottom sheet



  Widget _buildFilterContent(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle for visual appeal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          
              ...controller.filterOptions.map((option) {
                final bool isSelected = controller.selectedFilter == option;
          
                return InkWell(
                  onTap: () {
                    controller.changeFilter(option);
                    // Dismiss the bottom sheet after selection
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primaryColor : Colors.grey,
                          size: 24.0,
                        ),
                        const SizedBox(width: 16.0),
                        CommonText(
                          text: option,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isSelected ? AppColors.primaryColor : Colors.black,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}