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
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.777176, 90.399452),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GetBuilder<HomeController>(
          init: HomeController(),
          builder: (controller) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    /// Top Details Section
                    GetBuilder<NotificationsController>(
                      init: NotificationsController(),
                      builder: (notifController) {
                        return HomeDetails(
                          notificationCount: notifController.unreadCount,
                        );
                      },
                    ),
                    SizedBox(height: 20.h),

                    /// Google Map Section
                    _buildMapSection(controller),

                    SizedBox(height: 20.h),

                    /// Action Items List
                    _buildActionList(controller),
                  ],
                ),
              ),
            );
          },
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
            GoogleMap(
              compassEnabled: true,
              mapType: MapType.satellite,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              heatmaps: controller.heatmaps, // Added heatmap support
              onMapCreated: (GoogleMapController mapController) {
                if (!_controller.isCompleted) {
                  _controller.complete(mapController);
                }
              },
            ),

            /// Overlay Buttons
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Row(
                children: [
                  _buildOverlayButton(
                    onTap: () => Get.dialog(
                      ClickerDialog(onApply: (val) => controller.clickerCount.value = val),
                    ),
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
                    onTap: () => Get.dialog(
                      FilterDialog(onApply: controller.applyFilter),
                    ),
                    child: Row(
                      children: [
                        Text('Filter', style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
                        SizedBox(width: 4.w),
                        Icon(Icons.filter_alt, size: 16.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButton({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: child,
      ),
    );
  }

  Widget _buildActionList(HomeController controller) {
    bool isLoggedIn = LocalStorage.token != null && LocalStorage.token!.isNotEmpty;

    return Column(
      children: [
        Item(
          imageSrc: AppIcons.clicker,
          title: 'Clicker',
          onTap: () => Get.to(() => ClickerScreen(), arguments: controller),
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
            onTap: () => Get.to(() => MyPostScreen()),
          ),
          Item(
            imageSrc: AppIcons.myFriend,
            title: 'My Friend',
            onTap: () => Get.to(() => MyFriendScreen()),
          ),
          Item(
            imageSrc: AppIcons.friend,
            title: 'Friend Request',
            badgeText: controller.friendRequestsList.length.toString(),
            onTap: () => Get.to(() => FriendRequestScreen()),
          ),
        ],
      ],
    );
  }

  void _handleLocationAndNavigate() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      Get.to(() => const ChatNearbyScreen());
    } else {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
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
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      var status = await Permission.location.request();
                      if (status.isGranted) {
                        Get.to(() => const ChatNearbyScreen());
                      } else {
                        Get.snackbar('Permission Denied', 'Location is required.');
                        if (status.isPermanentlyDenied) await openAppSettings();
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
  }
}