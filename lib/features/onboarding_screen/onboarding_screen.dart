import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_string.dart';
import 'package:giolee78/utils/extensions/extension.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  bool isLocationEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 🔁 App background → foreground এ এলে আবার location check
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationStatus();
    }
  }

  /// 📍 Location status check (Service + Permission দুটোই)
  Future<void> _checkLocationStatus() async {
    try {
      // ✅ 1. Check করুন Location Service ON আছে কিনা
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      // ✅ 2. Check করুন Permission granted আছে কিনা
      LocationPermission permission = await Geolocator.checkPermission();

      if (!mounted) return;

      setState(() {
        // Service ON + Permission granted = Location Enabled
        isLocationEnabled = serviceEnabled &&
            (permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse);
      });
    } catch (e) {
      debugPrint("Location check error: $e");
      if (!mounted) return;
      setState(() => isLocationEnabled = false);
    }
  }

  /// 🔄 Location enable/disable করার logic
  Future<void> _toggleLocation(bool value) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      if (value) {
        // ✅ Location enable করতে চাচ্ছে
        await _enableLocation();
      } else {
        // ❌ Location disable করতে চাচ্ছে
        await _disableLocation();
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Location Enable করার process
  Future<void> _enableLocation() async {
    // 1️⃣ Location Service check করুন
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Service OFF থাকলে settings এ পাঠান
      bool? opened = await _showLocationServiceDialog();
      if (opened == true) {
        await Geolocator.openLocationSettings();
      }
      await _checkLocationStatus();
      return;
    }

    // 2️⃣ Permission check করুন
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Permission request করুন
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permanently denied - Settings এ পাঠান
      await _showPermissionDeniedDialog();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // ✅ Success! Location enabled
      await _checkLocationStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location enabled successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// ❌ Location Disable করার process
  Future<void> _disableLocation() async {
    // Android/iOS এ programmatically location OFF করা যায় না
    // User কে inform করুন
    bool? goToSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Location'),
        content: const Text(
          'To disable location, please turn it off manually from your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (goToSettings == true) {
      await Geolocator.openLocationSettings();
      await _checkLocationStatus();
    } else {
      // User cancel করলে switch আবার ON করুন
      await _checkLocationStatus();
    }
  }

  /// 📢 Location Service dialog
  Future<bool?> _showLocationServiceDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
          'Location services are disabled. Please enable them in your device settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// 📢 Permission denied dialog
  Future<void> _showPermissionDeniedDialog() async {
    bool? openSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location permission has been permanently denied. Please enable it from app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (openSettings == true) {
      await openAppSettings();
      await _checkLocationStatus();
    } else {
      await _checkLocationStatus();
    }
  }

  /// 📍 Get Current Location (Optional - for testing)
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              100.height,
              const CommonImage(imageSrc: AppIcons.onboarding),
              60.height,
              CommonText(
                text: AppString.onboardingTitle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                maxLines: 3,
              ),
              CommonText(
                text: AppString.onboardingSubText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                left: 10.w,
                right: 10.w,
                bottom: 20.h,
                maxLines: 3,
              ),
              _buildLocationPermissionSection(),
              40.height,
              CommonButton(
                titleText: 'Get Started',
                buttonHeight: 50.h,
                buttonRadius: 10.r,
                titleSize: 18.sp,
                onTap: () async {
                  // ✅ Optional: Location enable না থাকলে warning দিন
                  if (!isLocationEnabled) {
                    bool? proceed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Location Required'),
                        content: const Text(
                          'For the best experience, please enable location services.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Continue Anyway'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Enable Location'),
                          ),
                        ],
                      ),
                    );

                    if (proceed == false) {
                      await _enableLocation();
                      return;
                    }
                  }

                  // Navigate to next screen
                  Get.toNamed(AppRoutes.signUp);
                },
              ),
              20.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPermissionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Location',
                  style: TextStyle(
                    color: Color(0xFF373737),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Allow us to find the best vibes around you.',
                  style: TextStyle(
                    color: Color(0xFF727272),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // ✅ Loading indicator বা Switch
          isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Switch.adaptive(
            value: isLocationEnabled,
            onChanged: _toggleLocation,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4CAF50),
            inactiveThumbColor: const Color(0xFF727272),
            inactiveTrackColor: const Color(0xFFDEE2E3),
          ),
        ],
      ),
    );
  }
}