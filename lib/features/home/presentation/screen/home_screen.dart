import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

// Project Imports
import 'package:giolee78/component/other_widgets/item.dart';
import 'package:giolee78/features/chat_nearby/presentation/screen/chat_nearby_screen.dart';
import 'package:giolee78/features/clicker/presentation/screen/clicker_screen.dart';
import 'package:giolee78/features/friend/presentation/screen/friend_request_screen.dart';
import 'package:giolee78/features/friend/presentation/screen/my_friend_screen.dart';
import 'package:giolee78/features/addpost/presentation/screen/my_post_screen.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import '../../../../services/storage/storage_services.dart';
import '../controller/home_controller.dart';
import '../widgets/clicker_main.dart';
import '../widgets/filter_main.dart';
import '../widgets/home_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Default initial position (Dhaka)
  CameraPosition get _initialPosition => CameraPosition(
    target: LatLng(
      Get.find<HomeController>().currentLatitude.value != 0.0
          ? Get.find<HomeController>().currentLatitude.value
          : 23.777176, // Fallback to Dhaka
      Get.find<HomeController>().currentLongitude.value != 0.0
          ? Get.find<HomeController>().currentLongitude.value
          : 90.399452, // Fallback to Dhaka
    ),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          Get.back();
        } catch (e) {
          debugPrint('Error on back: $e');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GetBuilder<HomeController>(
          init: HomeController(),
          builder: (controller) {
            return SafeArea(
              child: Column(
                children: [
                  // Top Details Section - Fixed
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: _buildTopDetails(),
                  ),

                  SizedBox(height: 20.h),

                  // Google Map Section - Fixed (non-scrollable parent)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: controller.isLoading
                        ? _buildLoadingMap()
                        : _buildMapSection(controller),
                  ),

                  SizedBox(height: 20.h),

                  // Action Items List - Scrollable
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        try {
                          await controller.refreshAll();
                        } catch (e) {
                          debugPrint('Error refreshing: $e');
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _buildActionList(controller),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopDetails() {
    try {
      return GetBuilder<NotificationsController>(
        init: NotificationsController(),
        builder: (notifController) {
          return HomeDetails(
            notificationCount: notifController.unreadCount,
          );
        },
      );
    } catch (e) {
      debugPrint('Error building top details: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingMap() {
    return Container(
      height: 350.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16.h),
            Text(
              'Loading map data...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(HomeController controller) {
    return Container(
      height: 350.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            // Google Map - Full touchable area
            _buildGoogleMap(controller),

            /// Overlay Buttons - Clickable
            Positioned(
              top: 16.h,
              right: 16.w,
              child: _buildOverlayButtons(controller),
            ),

            /// Heatmap Info Badge (Optional) - Non-clickable
            if (controller.heatmaps.isNotEmpty)
              Positioned(
                bottom: 16.h,
                left: 16.w,
                child: IgnorePointer(
                  child: _buildHeatmapInfoBadge(controller),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap(HomeController controller) {
    try {
      return GoogleMap(
        compassEnabled: true,
        mapType: MapType.satellite,
        initialCameraPosition: _initialPosition, // Use the getter
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        rotateGesturesEnabled: true,
        heatmaps: controller.heatmaps,
        onMapCreated: (GoogleMapController mapController) async {
          try {
            if (!_controller.isCompleted) {
              _controller.complete(mapController);

              // Move camera to current location once we have it
              if (controller.currentLatitude.value != 0.0 &&
                  controller.currentLongitude.value != 0.0) {
                await mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        controller.currentLatitude.value,
                        controller.currentLongitude.value,
                      ),
                      zoom: 14.4746,
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Error on map created: $e');
          }
        },
        onTap: (LatLng position) {
          debugPrint('Map tapped at: ${position.latitude}, ${position.longitude}');
        },
      );
    } catch (e) {
      debugPrint('Error building Google Map: $e');
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Error loading map',
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildOverlayButtons(HomeController controller) {
    try {
      return Row(
        children: [
          _buildOverlayButton(
            onTap: () {
              try {
                Get.dialog(
                  ClickerDialog(
                    onApply: (val) {
                      try {
                        controller.applyClickerFilter(val);
                      } catch (e) {
                        debugPrint('Error applying clicker filter: $e');
                      }
                    },
                  ),
                );
              } catch (e) {
                debugPrint('Error showing clicker dialog: $e');
                Get.snackbar('Error', 'Failed to open clicker selection');
              }
            },
            child: Row(
              children: [
                Obx(() => Text(
                  controller.clickerCount.value ?? 'Select Clicker',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                )),
                Icon(Icons.arrow_drop_down, size: 24.sp),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _buildOverlayButton(
            onTap: () {
              try {
                Get.dialog(
                  FilterDialog(onApply: controller.applyFilter),
                );
              } catch (e) {
                debugPrint('Error showing filter dialog: $e');
                Get.snackbar('Error', 'Failed to open filter');
              }
            },
            child: Row(
              children: [
                Text('Filter', style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
                SizedBox(width: 4.w),
                Icon(Icons.filter_alt, size: 16.sp),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error building overlay buttons: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildHeatmapInfoBadge(HomeController controller) {
    try {
      int totalPoints = 0;
      for (var heatmap in controller.heatmaps) {
        totalPoints += heatmap.data.length;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 16.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              '$totalPoints ${totalPoints == 1 ? 'location' : 'locations'}',
              style: TextStyle(fontSize: 12.sp, color: Colors.white),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building heatmap info badge: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildOverlayButton({required VoidCallback onTap, required Widget child}) {
    try {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      );
    } catch (e) {
      debugPrint('Error building overlay button: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildActionList(HomeController controller) {
    try {
      bool isLoggedIn = LocalStorage.token != null && LocalStorage.token!.isNotEmpty;

      return Column(
        children: [
          Item(
            imageSrc: AppIcons.clicker,
            title: 'Clicker',
            onTap: () {
              try {
                Get.to(() => ClickerScreen(), arguments: controller);
              } catch (e) {
                debugPrint('Error navigating to Clicker: $e');
                Get.snackbar('Error', 'Failed to open Clicker');
              }
            },
          ),
          if (isLoggedIn) ...[
            Item(
              imageSrc: AppIcons.bubbleChat,
              title: 'Chat Nearby',
              onTap: _handleLocationAndNavigate,
            ),
            Item(
              imageSrc: AppIcons.myPost,
              title: 'My Post',
              onTap: () {
                try {
                  Get.to(() => MyPostScreen());
                } catch (e) {
                  debugPrint('Error navigating to My Post: $e');
                  Get.snackbar('Error', 'Failed to open My Post');
                }
              },
            ),
            Item(
              imageSrc: AppIcons.myFriend,
              title: 'My Friend',
              onTap: () {
                try {
                  Get.to(() => MyFriendScreen());
                } catch (e) {
                  debugPrint('Error navigating to My Friend: $e');
                  Get.snackbar('Error', 'Failed to open My Friend');
                }
              },
            ),
            Item(
              imageSrc: AppIcons.friend,
              title: 'Friend Request',
              badgeText: controller.friendRequestsList.length.toString(),
              onTap: () {
                try {
                  Get.to(() => FriendRequestScreen());
                } catch (e) {
                  debugPrint('Error navigating to Friend Request: $e');
                  Get.snackbar('Error', 'Failed to open Friend Request');
                }
              },
            ),
          ],
        ],
      );
    } catch (e) {
      debugPrint('Error building action list: $e');
      return const SizedBox.shrink();
    }
  }

  void _handleLocationAndNavigate() async {
    try {
      var status = await Permission.location.status;
      if (status.isGranted) {
        Get.to(() => const ChatNearbyScreen());
      } else {
        _showConfirmationDialog();
      }
    } catch (e) {
      debugPrint('Error handling location: $e');
      Get.snackbar(
        'Permission Error',
        'Failed to check location permission',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  void _showConfirmationDialog() {
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'By Enabling Location, Your Nearby Activity May Be Visible To Others, '
                    'And Your Location Data Will Be Stored Temporarily.',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        try {
                          Get.back();
                        } catch (e) {
                          debugPrint('Error closing dialog: $e');
                        }
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          Get.back();
                          var status = await Permission.location.request();
                          if (status.isGranted) {
                            Get.to(() => const ChatNearbyScreen());
                          } else {
                            Get.snackbar('Permission Denied', 'Location is required.');
                            if (status.isPermanentlyDenied) {
                              await openAppSettings();
                            }
                          }
                        } catch (e) {
                          debugPrint('Error requesting permission: $e');
                          Get.snackbar(
                            'Error',
                            'Failed to request location permission',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.7),
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                      child: const Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing confirmation dialog: $e');
    }
  }

  @override
  void dispose() {
    try {
      // Clean up if needed
      super.dispose();
    } catch (e) {
      debugPrint('Error in dispose: $e');
    }
  }
}