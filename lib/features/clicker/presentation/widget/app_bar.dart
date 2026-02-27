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

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.notificationCount});

  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  // Use same initial state as HomeDetails
  String displayLocation = "Fetching location...";
  bool loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndAddress();
  }

  /// Same location logic as HomeDetails
  Future<void> _getCurrentLocationAndAddress() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateLocationText("GPS Disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateLocationText("Permission Denied");
          return;
        }
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          final Placemark place = placemarks[0];

          // Same Priority list: Road -> Area -> City -> State -> Country
          final List<String?> potentialFields = [
            place.thoroughfare,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ];

          final List<String> finalParts = [];

          // Stop at 3 fields to keep it consistent
          for (var field in potentialFields) {
            if (field != null && field.isNotEmpty) {
              finalParts.add(field);
            }
            if (finalParts.length == 3) break;
          }

          setState(() {
            displayLocation = finalParts.isNotEmpty
                ? finalParts.join(", ")
                : "Location Found";
            loadingLocation = false;
          });
        }
      } catch (e) {
        _updateLocationText("Address unavailable");
      }
    } catch (e) {
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
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: CommonImage(
                            fill: BoxFit.cover,
                            imageSrc: (LocalStorage.myImage.isNotEmpty && LocalStorage.token.isNotEmpty)
                                ? ApiEndPoint.imageUrl + LocalStorage.myImage
                                : "assets/images/profile.png",
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: (LocalStorage.myName.isNotEmpty && LocalStorage.token.isNotEmpty)
                                ? LocalStorage.myName
                                : "Guest User",
                            color: AppColors.textColorFirst,
                            fontWeight: FontWeight.w600,
                          ),
                          Text(
                            displayLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// Notification Stack
              if(LocalStorage.token.isNotEmpty)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                      child: const CommonImage(
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
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}