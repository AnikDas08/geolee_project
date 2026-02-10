import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 

import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';

import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/controller/my_profile_controller.dart';

class HomeDetails extends StatefulWidget {
  const HomeDetails({super.key, required this.notificationCount});

  final int notificationCount;

  @override
  State<HomeDetails> createState() => _HomeDetailsState();
}

class _HomeDetailsState extends State<HomeDetails> {
  String displayLocation = "Fetching location...";
  bool loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndAddress();
  }

  Future<void> _getCurrentLocationAndAddress() async {
    try {
      // 1. Check if Service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateLocationText("GPS Disabled");
        return;
      }

      // 2. Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateLocationText("Permission Denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateLocationText("Settings Blocked");
        return;
      }

      // 3. Get Position with Timeout (Crucial for preventing infinite loading)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      // 4. Reverse Geocoding with Try-Catch
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          setState(() {
            displayLocation = placemarks[0].locality ?? "Unknown";
            loadingLocation = false;
          });
        }
      } catch (e) {
        _updateLocationText("Address unavailable");
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      _updateLocationText("Location Error");
    }
  }

  void _updateLocationText(String text) {
    if (mounted) {
      setState(() {
        displayLocation = text;
        loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyProfileController>(
      init: MyProfileController(),
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (LocalStorage.token.isNotEmpty) {
                      Get.toNamed(AppRoutes.profile);
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: CommonImage(
                        fill: BoxFit.cover,
                        imageSrc: controller.userImage.isNotEmpty && LocalStorage.token.isNotEmpty
                            ? ApiEndPoint.imageUrl + controller.userImage
                            : "assets/images/profile.png",
                        size: 40,
                        defaultImage: "assets/images/profile.png",
                      ),
                    ),
                  ),
                ),
                12.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: controller.userName,
                      fontSize: 16,
                      color: AppColors.textColorFirst,
                      fontWeight: FontWeight.w600,
                    ),
                    Row(
                      children: [
                        CommonImage(imageSrc: AppIcons.location, size: 14),
                        8.width,
                        CommonText(
                          text: displayLocation,
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

            /// Notification Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.notifications),
                    child: CommonImage(imageSrc: AppIcons.notification, size: 28),
                  ),
                ),
                if (widget.notificationCount > 0)
                  Positioned(
                    right: 4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        "${widget.notificationCount}",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }
    );
  }
}
