import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/utils/log/app_log.dart';
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
import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();
  late final MyFriendController myFriendController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<MyFriendController>()) {
      myFriendController = Get.find<MyFriendController>();
    } else {
      myFriendController = Get.put(MyFriendController());
    }
  }

  Future<void> onMyLocationVisibility() async {
    try {
      debugPrint('🔄 onMyLocationVisibility() called...');
      final response = await ApiService.patch(
        ApiEndPoint.updateProfile,
        body: {
          "isLocationVisible": true,
        },
      );
      if (response.statusCode == 200) {
        appLog("Location Visibility On");
        debugPrint('✅ Profile location updated successfully');
      } else {
        debugPrint('⚠️ Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      myFriendController.fetchFriendRequests();
    }
  }

  CameraPosition get _initialPosition => CameraPosition(
    target: LatLng(
      LocalStorage.lat != 0.0 ? LocalStorage.lat : 1.3521,
      LocalStorage.long != 0.0 ? LocalStorage.long : 103.8198,
    ),
    zoom: 14.0,
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
          return HomeDetails(notificationCount: notifController.unreadCount);
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
            const CircularProgressIndicator(color: AppColors.primaryColor),
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            Obx(() {
              controller.heatmaps.length;
              controller.markerList.length;

              return GoogleMap(
                mapType: MapType.satellite,
                initialCameraPosition: _initialPosition,
                myLocationEnabled: true,
                heatmaps: controller.heatmaps,
                markers: Set<Marker>.from(controller.markerList),
                onMapCreated: (GoogleMapController mapController) async {
                  try {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(mapController);

                      if (!controller.mapController.isCompleted) {
                        controller.mapController.complete(mapController);
                      }

                      final double lat =
                      controller.currentLatitude.value != 0.0
                          ? controller.currentLatitude.value
                          : LocalStorage.lat != 0.0
                          ? LocalStorage.lat
                          : 1.3521;
                      final double lng =
                      controller.currentLongitude.value != 0.0
                          ? controller.currentLongitude.value
                          : LocalStorage.long != 0.0
                          ? LocalStorage.long
                          : 103.8198;

                      await mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: LatLng(lat, lng), zoom: 14.0),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error on map created: $e');
                  }
                },
                onTap: (LatLng position) {
                  debugPrint(
                      'Map tapped: ${position.latitude}, ${position.longitude}');
                },
              );
            }),
            Positioned(
              top: 16.h,
              right: 16.w,
              child: _buildOverlayButtons(controller),
            ),
            if (controller.heatmaps.isNotEmpty)
              Positioned(
                bottom: 16.h,
                left: 16.w,
                child:
                IgnorePointer(child: _buildHeatmapInfoBadge(controller)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButtons(HomeController controller) {
    try {
      return Row(
        children: [
          _buildOverlayButton(
            onTap: () {
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
            },
            child: Row(
              children: [
                Obx(
                      () => Text(
                    controller.clickerCount.value ?? 'Select Clicker',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 24.sp),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _buildOverlayButton(
            onTap: () {
              Get.dialog(FilterDialog(onApply: controller.applyFilter));
            },
            child: Obx(
                  () => Row(
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
                  Text(
                    'Filter',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.filter_alt, size: 16.sp),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error building overlay buttons: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildOverlayButton({
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

  Widget _buildHeatmapInfoBadge(HomeController controller) {
    try {
      int totalPoints = 0;
      for (var heatmap in controller.heatmaps) {
        totalPoints += heatmap.data.length;
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
              '$totalPoints ${totalPoints == 1 ? 'location' : 'Total Post'}',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
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
              try {
                Get.to(() => const ClickerScreen(), arguments: controller);
              } catch (e) {
                Get.snackbar('Error', 'Failed to open Clicker');
              }
            },
          ),
          GetX<HomeController>(
            builder: (controller) {
              final isNearby = controller.isNearbyActive.value;
              return Item(
                imageSrc: AppIcons.bubbleChat,
                title: 'Chat Nearby',
                trailing: isLoggedIn && isNearby
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _NearbyActiveDot(),
                    SizedBox(width: 5.w),
                    Text(
                      'ON',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                )
                    : null,
                onTap: () {
                  if (isLoggedIn) {
                    _handleLocationAndNavigate();
                  } else {
                    _showRegistrationDialog();
                  }
                },
              );
            },
          ),
          Item(
            imageSrc: AppIcons.myPost,
            title: 'My Post',
            onTap: () {
              if (isLoggedIn) {
                try {
                  Get.to(() => const MyPostScreen());
                } catch (e) {
                  Get.snackbar('Error', 'Failed to open My Post');
                }
              } else {
                _showRegistrationDialog();
              }
            },
          ),
          Item(
            imageSrc: AppIcons.myFriend,
            title: 'My Friend',
            onTap: () {
              if (isLoggedIn) {
                try {
                  Get.to(() => const MyFriendScreen());
                } catch (e) {
                  Get.snackbar('Error', 'Failed to open My Friend');
                }
              } else {
                _showRegistrationDialog();
              }
            },
          ),
          GetX<MyFriendController>(
            builder: (myFriendController) {
              final requests = myFriendController.requests;
              requests.length;

              final pendingRequests = isLoggedIn
                  ? requests.where((r) => r.status == "pending").toList()
                  : [];

              return Item(
                imageSrc: AppIcons.friend,
                title: 'Friend Request',
                badgeText: pendingRequests.isEmpty
                    ? null
                    : pendingRequests.length.toString(),
                onTap: () {
                  if (isLoggedIn) {
                    try {
                      Get.to(() => FriendRequestScreen());
                    } catch (e) {
                      Get.snackbar('Error', 'Failed to open Friend Request');
                    }
                  } else {
                    _showRegistrationDialog();
                  }
                },
              );
            },
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error building action list: $e');
      return const SizedBox.shrink();
    }
  }

  Future<void> _handleLocationAndNavigate() async {
    try {
      _showConfirmationDialog();
    } catch (e) {
      debugPrint('Error handling location: $e');
    }
  }

  void _showConfirmationDialog() {
    try {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'By Enabling Location, Your Nearby Activity May Be Visible To Others, '
                    'And Your Location Data Will Be Stored Temporarily.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      // ✅ FIX: async function extracted to avoid dialog context issues
                      onPressed: () => _onConfirmLocation(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
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

  // ✅ FIX: Extracted to separate method — এটাই মূল সমস্যার সমাধান
  // আগে inline async lambda ছিল, Get.back() এর পর context হারিয়ে যেত
  // এখন named method হওয়ায় proper await chain কাজ করে
  Future<void> _onConfirmLocation() async {
    try {
      // ✅ Step 1: Dialog বন্ধ করো
      Get.back();

      // ✅ Step 2: Loading দেখাও
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
        barrierDismissible: false,
      );

      // ✅ Step 3: Permission check
      var status = await Permission.location.status;
      debugPrint('📍 Initial permission status: $status');

      if (!status.isGranted) {
        status = await Permission.location.request();
        debugPrint('📍 After request permission status: $status');
      }

      if (status.isGranted) {
        // ✅ Step 4: GPS service check
        final bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          Get.back(); // loading dismiss
          Get.snackbar(
            'GPS Disabled',
            'Please enable GPS/Location services',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.7),
            colorText: Colors.white,
          );
          return;
        }

        // ✅ Step 5: Current position নাও
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // ✅ Step 6: Loading dismiss
        Get.back();

        // ✅ Step 7: Location save করো
        LocalStorage.lat = position.latitude;
        LocalStorage.long = position.longitude;

        // ✅ Step 8: Nearby active করো
        Get.find<HomeController>().isNearbyActive.value = true;

        // ✅ Step 9: API call — এখন সঠিকভাবে await হবে
        debugPrint('🔄 Calling onMyLocationVisibility...');
        await onMyLocationVisibility();
        debugPrint('✅ onMyLocationVisibility done');

        // ✅ Step 10: Navigate
        Get.to(() => const ChatNearbyScreen());
      } else {
        // ❌ Permission denied
        Get.back(); // loading dismiss
        debugPrint('❌ Permission denied: $status');
        Get.snackbar(
          'Permission Denied',
          'Location permission is required.',
          snackPosition: SnackPosition.BOTTOM,
        );
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _onConfirmLocation: $e');
      // Loading dismiss (safety)
      try {
        Get.back();
      } catch (_) {}
      Get.snackbar(
        'Error',
        'Failed to request location permission',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  void _showRegistrationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Registration required',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Please sign up to use this feature',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        actions: [
          Center(
            child: CommonButton(
              onTap: () {
                Get.offAllNamed(AppRoutes.signIn);
              },
              titleText: "Ok",
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

// Pulsing green dot
class _NearbyActiveDot extends StatefulWidget {
  const _NearbyActiveDot();

  @override
  State<_NearbyActiveDot> createState() => _NearbyActiveDotState();
}

class _NearbyActiveDotState extends State<_NearbyActiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF22C55E),
            const Color(0xFF86EFAC),
            _anim.value,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E)
                  .withOpacity(0.4 + (_anim.value * 0.3)),
              blurRadius: 4 + (_anim.value * 4),
              spreadRadius: _anim.value * 2,
            ),
          ],
        ),
      ),
    );
  }
}