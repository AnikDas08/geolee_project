import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';

import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.notificationCount});

  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  10.width,

                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                        child: CommonImage(
                          fill: BoxFit.fill,
                          imageSrc: LocalStorage.myImage.isNotEmpty
                              ? ApiEndPoint.imageUrl + LocalStorage.myImage
                              : "",
                          size: 40,
                          defaultImage: AppImages.profileImage,
                        ),
                      ),
                    ),
                  ),
                  12.width,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: LocalStorage.myName,
                        fontSize: 16,
                        color: AppColors.textColorFirst,
                        fontWeight: FontWeight.w600,
                      ),
                      CommonText(
                        text: "Thornridge Cir. Shiloh, Hawaii",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                      child: CommonImage(
                        imageSrc: AppIcons.notification,
                        size: 26,
                      ),
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            "$notificationCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
