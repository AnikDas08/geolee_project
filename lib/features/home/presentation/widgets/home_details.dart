import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';

import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_images.dart';

class HomeDetails extends StatefulWidget {
  const HomeDetails({super.key, required this.notificationCount});

  final int notificationCount;

  @override
  State<HomeDetails> createState() => _HomeDetailsState();
}

class _HomeDetailsState extends State<HomeDetails> {
  double? lat;
  double? lng;
  bool loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => loadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        lat = position.latitude;
        lng = position.longitude;
        loadingLocation = false;
      });
    } catch (e) {
      loadingLocation = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: CircleAvatar(
                radius: 20,
                child: ClipOval(
                  child: CommonImage(
                    fill: BoxFit.fill,
                    imageSrc: LocalStorage.myImage != null &&
                        LocalStorage.myImage!.isNotEmpty
                        ? ApiEndPoint.imageUrl + LocalStorage.myImage!
                        : "",
                    size: 40,
                    defaultImage: AppImages.profileImage,
                  ),
                ),
              ),
            ),
            12.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: LocalStorage.myName,
                  fontSize: 16,
                  color: AppColors.textColorFirst,
                  fontWeight: FontWeight.w600,
                ),
                Row(
                  children: [
                    CommonImage(imageSrc: AppIcons.location),
                    8.width,
                    CommonText(
                      text: loadingLocation
                          ? "Fetching location..."
                          : lat != null && lng != null
                          ? "${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}"
                          : "Location unavailable",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        /// 🔔 Notification
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.notifications),
                child: CommonImage(
                  imageSrc: AppIcons.notification,
                  size: 28,
                ),
              ),
            ),
            if (widget.notificationCount > 0)
              Positioned(
                right: 4,
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
                      "${widget.notificationCount}",
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
    );
  }
}
