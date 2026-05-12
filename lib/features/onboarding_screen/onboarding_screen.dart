import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giolee78/services/storage/storage_keys.dart';

import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/storage/storage_services.dart';
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeLocation();
    }
  }

  Future<void> _initializeLocation() async {
    await _checkLocationStatus();
    if (isLocationEnabled) {
      await _saveCurrentLocation();
    }
  }

  Future<void> _checkLocationStatus() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final LocationPermission permission = await Geolocator.checkPermission();

      if (!mounted) return;

      setState(() {
        isLocationEnabled = serviceEnabled &&
            (permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse);
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLocationEnabled = false);
      }
    }
  }

  Future<void> _toggleLocation(bool value) async {
    if (isLoading) return;

    if (value) {
      setState(() => isLoading = true);
      await _enableLocation();
      if (mounted) setState(() => isLoading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('To revoke location access, please change it from App Settings.'),
          duration: Duration(seconds: 2),
        ),
      );
      await _checkLocationStatus();
    }
  }

  Future<void> _enableLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services (GPS) on your device.')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // যদি পারমিশন পার্মানেন্টলি ডিনাইড থাকে, তাহলে ইউজার চাইলে ম্যানুয়ালি সেটিংস থেকে অন করতে পারবে
      if (mounted) {
        _showManualPermissionDialog();
      }
    }

    await _checkLocationStatus();
    if (isLocationEnabled) {
      await _saveCurrentLocation();
    }
  }

  void _showManualPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Access"),
        content: const Text("Location permission is permanently denied. Would you like to enable it in settings?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await LocalStorage.setDouble(LocalStorageKeys.lat, position.latitude);
      await LocalStorage.setDouble(LocalStorageKeys.long, position.longitude);
    } catch (e) {
      // Fail silently for onboarding
    }
  }

  Future<void> _onGetStartedTap() async {
    Get.toNamed(AppRoutes.signIn);
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
                maxLines: 5,
                text: AppString.onboardingTitle,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              10.height,
              CommonText(
                maxLines: 5,
                text: AppString.onboardingSubText,
                fontSize: 14.sp,
              ),
              20.height,
              _buildLocationPermissionSection(),
              40.height,
              CommonButton(
                titleText: 'Get Started',
                buttonHeight: 50.h,
                buttonRadius: 10.r,
                titleSize: 18.sp,
                onTap: _onGetStartedTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPermissionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
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
                  'Location Access',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(
                  'Allow us to find the best vibes around you.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Switch.adaptive(
            value: isLocationEnabled,
            onChanged: _toggleLocation,
          ),
        ],
      ),
    );
  }
}
