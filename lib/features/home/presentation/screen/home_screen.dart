import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/other_widgets/item.dart';
import 'package:giolee78/features/chat_nearby/presentation/screen/chat_nearby_screen.dart';
import 'package:giolee78/features/clicker/presentation/screen/clicker_screen.dart';
import 'package:giolee78/features/friend/presentation/screen/friend_request_screen.dart';
import 'package:giolee78/features/friend/presentation/screen/my_friend_screen.dart';
import 'package:giolee78/features/addpost/presentation/screen/my_post_screen.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/notifications/presentation/controller/notifications_controller.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/home_controller.dart';
import '../widgets/clicker_main.dart';
import '../widgets/filter_main.dart';
import '../widgets/home_details.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeController = Get.find<HomeNavController>();

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.777176, 90.399452),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.4220, -122.0840),
    tilt: 59.440717697143555,
    zoom: 14.151926040649414,
  );


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("My Role Is :=========================== ${LocalStorage.myRole.toString()}");
  }
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GetBuilder<NotificationsController>(
                                init: NotificationsController(),
                                builder: (controller) {
                                  return HomeDetails(
                                    notificationCount: controller.unreadCount,
                                  );
                                }),
                            SizedBox(height: 20.h),

                            /// ✅ Google Map Section
                            Container(
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
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        _controller.complete(controller);
                                      },
                                    ),

                                    /// Clicker & Filter buttons overlay
                                    Positioned(
                                      top: 16.h,
                                      right: 16.w,
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          /// Clicker Button
                                          GestureDetector(
                                            onTap: () {
                                              Get.dialog(
                                                ClickerDialog(
                                                  onApply: (selectedClicker) {
                                                    controller.clickerCount.value =
                                                        selectedClicker;
                                                  },
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color:
                                                Colors.white.withOpacity(0.9),
                                                borderRadius:
                                                BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                children: [
                                                  Obx(() => Text(
                                                    controller.clickerCount
                                                        .value ??
                                                        'Select Clicker',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  )),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(Icons.arrow_drop_down,
                                                      size: 24.sp,
                                                      color: Colors.black87),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),

                                          /// Filter Button
                                          GestureDetector(
                                            onTap: () {
                                              Get.dialog(
                                                FilterDialog(
                                                  onApply:
                                                      (period, start, end) {
                                                    controller.applyFilter(
                                                        period, start, end);
                                                  },
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 8.h),
                                              decoration: BoxDecoration(
                                                color:
                                                Colors.white.withOpacity(0.9),
                                                borderRadius:
                                                BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Filter',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(Icons.filter_alt,
                                                      size: 16.sp,
                                                      color: Colors.black87),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),
                            Column(
                              children: [
                                Item(
                                  imageSrc: AppIcons.clicker,
                                  title: 'Clicker',
                                  onTap: () {
                                    Get.to(() => ClickerScreen());
                                  },
                                ),
                                Item(
                                  imageSrc: AppIcons.bubbleChat,
                                  title: 'Chat Nearby',
                                  onTap: () {
                                    _showConfirmationDialog();
                                  },
                                ),
                                Item(
                                  imageSrc: AppIcons.myPost,
                                  title: 'My Post',
                                  onTap: () {
                                    Get.to(() => MyPostScreen());
                                  },
                                ),
                                Item(
                                  imageSrc: AppIcons.myFriend,
                                  title: 'My Friend',
                                  onTap: () {
                                    Get.to(() => MyFriendScreen());
                                  },
                                ),

                                   Item(
                                      imageSrc: AppIcons.friend,
                                      title: 'Friend Request',
                                      onTap: () {
                                        Get.to(() => FriendRequestScreen());
                                      },

                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )));
  }

  void _showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        title: null,
        actions: null,
        contentPadding: const EdgeInsets.all(20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'By Enabling Location, Your Nearby Activity May Be Visible To Others, And Your Location Data Will Be Stored Temporarily. You Can Remove This Data Anytime By Selecting Clear Location From The Top-Right Menu.',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(Get.context!);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDEE2E3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Back',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(Get.context!);
                      Get.snackbar(
                        'Location Enabled',
                        'Navigating to the Chat Nearby Page...',
                        backgroundColor: AppColors.primaryColor,
                        colorText: Colors.white,
                      );
                      Get.to(() => const ChatNearbyScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
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
