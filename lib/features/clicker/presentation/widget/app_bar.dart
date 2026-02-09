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
import '../../../../utils/constants/app_images.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.notificationCount});

  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String displayLocation = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _handleLocation();
  }

  Future<void> _handleLocation() async {
    try {
      // 1. Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        // 2. Get Position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );

        // 3. Convert to Address
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            // Priority: Locality (City) -> SubAdmin (District) -> Name
            displayLocation = place.locality ?? place.subAdministrativeArea ?? place.name ?? "Unknown";
          });
        }
      } else {
        setState(() => displayLocation = "Permission denied");
      }
    } catch (e) {
      setState(() => displayLocation = "Location unavailable");
    }
  }

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
                          imageSrc: (LocalStorage.myImage.isNotEmpty && LocalStorage.token.isNotEmpty)
                              ? ApiEndPoint.imageUrl + LocalStorage.myImage
                              : "assets/images/profile.png",
                          size: 40,
                          defaultImage: "assets/images/profile.png",
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
                        text: (LocalStorage.myName.isNotEmpty && LocalStorage.token.isNotEmpty)
                            ? LocalStorage.myName
                            : "User",
                        fontSize: 16,
                        color: AppColors.textColorFirst,
                        fontWeight: FontWeight.w600,
                      ),
                      // Dynamic Location Text
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

              /// Notification Stack
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
                  if (widget.notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: -4,
                      child: _buildNotificationBadge(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Center(
        child: Text(
          "${widget.notificationCount}",
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}