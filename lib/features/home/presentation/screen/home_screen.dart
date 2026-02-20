import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:giolee78/component/other_widgets/item.dart';
import 'package:giolee78/features/chat_nearby/presentation/screen/chat_nearby_screen.dart';
import 'package:giolee78/features/clicker/presentation/screen/clicker_screen.dart';
import 'package:giolee78/features/friend/presentation/screen/friend_request_screen.dart';
import 'package:giolee78/features/friend/presentation/screen/my_friend_screen.dart';
import 'package:giolee78/features/addpost/presentation/screen/my_post_screen.dart';
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
  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();

  // ✅ late — initState এ sequential init করবো
  late final HomeController homeController;
  late final MyFriendController myFriendController;
  late final NotificationsController notifController;

  bool _controllersReady = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    // ✅ HomeController আগে
    homeController = Get.put(HomeController());

    // ✅ বাকিগুলো 500ms delay — OOM fix
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      myFriendController = Get.put(MyFriendController());
      notifController = Get.put(NotificationsController());
      setState(() => _controllersReady = true);
    });
  }

  CameraPosition get _initialPosition => CameraPosition(
    target: LatLng(
      homeController.currentLatitude.value != 0.0
          ? homeController.currentLatitude.value
          : (LocalStorage.lat ?? 23.8103),
      homeController.currentLongitude.value != 0.0
          ? homeController.currentLongitude.value
          : (LocalStorage.long ?? 90.4125),
    ),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try { Get.back(); } catch (e) { debugPrint('Back error: $e'); }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GetBuilder<HomeController>(
          builder: (controller) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: _buildTopDetails(),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: controller.isLoading
                        ? _buildLoadingMap()
                        : _buildMapSection(controller),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        try {
                          await controller.refreshAll();
                          if (_controllersReady) {
                            await notifController.refresh();
                          }
                        } catch (e) {
                          debugPrint('Refresh error: $e');
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
    if (!_controllersReady) {
      return const HomeDetails(notificationCount: 0);
    }
    return Obx(() => HomeDetails(
      notificationCount: notifController.unreadCount.value,
    ));
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
            const CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16.h),
            Text('Loading map data...',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(HomeController controller) {
    return Container(
      height: 350.h,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [

            Obx(() {
              final _ = controller.mapRefreshTrigger.value;
              return GoogleMap(
                mapType: MapType.satellite,
                initialCameraPosition: _initialPosition,
                myLocationEnabled: true,
                heatmaps: controller.heatmaps.toSet(),
                markers: Set<Marker>.from(controller.markerList),
                onMapCreated: (GoogleMapController mapCtrl) async {
                  try {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(mapCtrl);
                    }
                    if (!controller.mapController.isCompleted) {
                      controller.mapController.complete(mapCtrl);
                    }
                    if (controller.currentLatitude.value != 0.0 &&
                        controller.currentLongitude.value != 0.0) {
                      await mapCtrl.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                          target: LatLng(
                            controller.currentLatitude.value,
                            controller.currentLongitude.value,
                          ),
                          zoom: 14.4746,
                        )),
                      );
                    }
                  } catch (e) {
                    debugPrint('Map created error: $e');
                  }
                },
                onTap: (_) {},
              );
            }),

            // ─── Overlay Buttons ───
            Positioned(
              top: 16.h,
              right: 16.w,
              child: _buildOverlayButtons(controller),
            ),

            // ─── Heatmap Badge ───
            Obx(() => controller.heatmaps.isNotEmpty
                ? Positioned(
              bottom: 16.h,
              left: 16.w,
              child: IgnorePointer(
                child: _buildHeatmapBadge(controller),
              ),
            )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButtons(HomeController controller) {
    return Row(
      children: [
        // ─── Clicker ───
        _overlayButton(
          onTap: () => Get.dialog(ClickerDialog(
            onApply: (val) {
              try { controller.applyClickerFilter(val); }
              catch (e) { debugPrint('Clicker filter error: $e'); }
            },
          )),
          child: Row(
            children: [
              Obx(() => Text(
                controller.clickerCount.value ?? 'All',
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
              )),
              Icon(Icons.arrow_drop_down, size: 24.sp),
            ],
          ),
        ),

        SizedBox(width: 8.w),

        // ─── Date Filter ───
        _overlayButton(
          onTap: () =>
              Get.dialog(FilterDialog(onApply: controller.applyFilter)),
          child: Obx(() => Row(
            children: [
              if (controller.isDateFilterActive.value)
                Container(
                  width: 8.w,
                  height: 8.h,
                  margin: EdgeInsets.only(right: 4.w),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              Text('Filter',
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.black87)),
              SizedBox(width: 4.w),
              Icon(Icons.filter_alt, size: 16.sp),
            ],
          )),
        ),
      ],
    );
  }

  Widget _buildHeatmapBadge(HomeController controller) {
    try {
      int total = 0;
      for (var h in controller.heatmaps) {
        total += h.data.length;
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 16.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              '$total ${total == 1 ? 'location' : 'Total Posts'}',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ],
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _overlayButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
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
  }

  Widget _buildActionList(HomeController controller) {
    try {
      final bool isLoggedIn = LocalStorage.token.isNotEmpty;

      return Column(
        children: [
          Item(
            imageSrc: AppIcons.clicker,
            title: 'Clicker',
            onTap: () {
              try { Get.to(() => const ClickerScreen(), arguments: controller); }
              catch (e) { Get.snackbar('Error', 'Failed to open Clicker'); }
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
                try { Get.to(() => const MyPostScreen()); }
                catch (e) { Get.snackbar('Error', 'Failed to open My Post'); }
              },
            ),
            Item(
              imageSrc: AppIcons.myFriend,
              title: 'My Friend',
              onTap: () {
                try { Get.to(() => const MyFriendScreen()); }
                catch (e) { Get.snackbar('Error', 'Failed to open My Friend'); }
              },
            ),

            // ✅ reactive badge — controllers ready হলেই দেখাবে
            if (_controllersReady)
              Obx(() {
                final pending = myFriendController.requests
                    .where((r) => r.status == "pending")
                    .toList();
                return Item(
                  imageSrc: AppIcons.friend,
                  title: 'Friend Request',
                  badgeText:
                  pending.isEmpty ? null : pending.length.toString(),
                  onTap: () {
                    try { Get.to(() => FriendRequestScreen()); }
                    catch (e) { Get.snackbar('Error', 'Failed to open Friend Request'); }
                  },
                );
              })
            else
              Item(
                imageSrc: AppIcons.friend,
                title: 'Friend Request',
                onTap: () => Get.to(() => FriendRequestScreen()),
              ),
          ],
        ],
      );
    } catch (e) {
      debugPrint('Action list error: $e');
      return const SizedBox.shrink();
    }
  }

  Future<void> _handleLocationAndNavigate() async {
    try {
      _showConfirmationDialog();
    } catch (e) {
      debugPrint('Location navigate error: $e');
    }
  }

  void _showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'By Enabling Location, Your Nearby Activity May Be Visible '
                  'To Others, And Your Location Data Will Be Stored Temporarily.',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        Get.back();
                        Get.dialog(
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.blue)),
                          barrierDismissible: false,
                        );

                        var status = await Permission.location.status;
                        if (!status.isGranted) {
                          status = await Permission.location.request();
                        }

                        if (status.isGranted) {
                          final bool serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                            Get.back();
                            Get.snackbar('GPS Disabled',
                                'Please enable GPS/Location services',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange.withOpacity(0.7),
                                colorText: Colors.white);
                            return;
                          }
                          final Position position =
                          await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.medium,
                          );
                          Get.back();
                          LocalStorage.lat = position.latitude;
                          LocalStorage.long = position.longitude;
                          Get.to(() => const ChatNearbyScreen());
                        } else {
                          Get.back();
                          Get.snackbar('Permission Denied',
                              'Location permission is required.');
                          if (status.isPermanentlyDenied) {
                            await openAppSettings();
                          }
                        }
                      } catch (e) {
                        debugPrint('Permission error: $e');
                        Get.back();
                        Get.snackbar('Error', 'Failed to get location',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.7),
                            colorText: Colors.white);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor),
                    child: const Text('OK',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      super.dispose();
    } catch (e) {
      debugPrint('Dispose error: $e');
    }
  }
}