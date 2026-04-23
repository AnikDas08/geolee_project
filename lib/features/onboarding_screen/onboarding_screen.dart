import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:permission_handler/permission_handler.dart';

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

  //check permission every time screen is visible==============================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeLocation();
  }

  //app foreground e ele abar check + save==============================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeLocation();
    }
  }

  //initialize: check status + save if enabled==============================
  Future<void> _initializeLocation() async {
    await _checkLocationStatus();

    if (isLocationEnabled) {
      await _saveCurrentLocation();
    }
  }

  //service + permission check==============================
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

      debugPrint(
          "🔍 Location Status: Service=$serviceEnabled, Permission=$permission, Enabled=$isLocationEnabled");
    } catch (e) {
      debugPrint("❌ Location check error: $e");
      if (mounted) {
        setState(() => isLocationEnabled = false);
      }
    }
  }

  //switch toggle - always shows permission dialog==============================
  Future<void> _toggleLocation(bool value) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      if (value) {
        await _enableLocation();
      } else {
        await _disableLocation();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  //enable location - shows permission dialog==============================
  Future<void> _enableLocation() async {
    //step 1: check if service is enabled==============================
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      final bool? open = await _showLocationServiceDialog();
      if (open == true) {
        await Geolocator.openLocationSettings();
        await Future.delayed(const Duration(milliseconds: 500));
      }
      await _initializeLocation();
      return;
    }

    //step 2: check current permission==============================
    LocationPermission permission = await Geolocator.checkPermission();

    //step 3: request permission if denied==============================
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        await _checkLocationStatus();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    //step 4: if permanently denied, show settings dialog==============================
    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedDialog();
      return;
    }

    //step 5: if permission granted, save location immediately==============================
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _checkLocationStatus();

      final bool saved = await _saveCurrentLocation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved
                ? '✅ Location enabled & saved successfully'
                : '⚠️ Location enabled but failed to get coordinates'),
            backgroundColor: saved ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  //disable location (manual only)==============================
  Future<void> _disableLocation() async {
    final bool? goToSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Location'),
        content: const Text(
          'To disable location, please turn it off manually from device settings.',
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
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await _initializeLocation();
  }

  //get & save location - returns true if successful==============================
  Future<bool> _saveCurrentLocation() async {
    try {
      debugPrint("📍 Fetching current location...");

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await LocalStorage.setDouble(LocalStorageKeys.lat, position.latitude);
      await LocalStorage.setDouble(LocalStorageKeys.long, position.longitude);

      debugPrint(
          "✅ Location saved → Lat: ${position.latitude}, Long: ${position.longitude}");

      return true;
    } catch (e) {
      debugPrint("❌ Location save failed: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  //location service disabled dialog==============================
  Future<bool?> _showLocationServiceDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
          'Location services are turned off. Please enable them to continue.',
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

  //permission permanently denied dialog==============================
  Future<void> _showPermissionDeniedDialog() async {
    final bool? openSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Location permission is permanently denied. Please enable it from app settings to use this feature.',
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
      await Future.delayed(const Duration(milliseconds: 500));
      await _initializeLocation();
    }
  }

  //get started button tap handler - apple fix: cannot skip permission==============================
  Future<void> _onGetStartedTap() async {
    //check current permission status==============================
    final LocationPermission permission = await Geolocator.checkPermission();
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    final bool alreadyGranted = serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);

    if (!alreadyGranted) {
      //permission not granted, request it first - user cannot skip==============================
      await _enableLocation();

      //re-check after request==============================
      final LocationPermission newPermission =
      await Geolocator.checkPermission();
      final bool newServiceEnabled =
      await Geolocator.isLocationServiceEnabled();

      final bool nowGranted = newServiceEnabled &&
          (newPermission == LocationPermission.always ||
              newPermission == LocationPermission.whileInUse);

      if (!nowGranted) {
        //still not granted, block navigation==============================
        return;
      }
    }

    //permission granted, proceed to next screen==============================
    final String lat = LocalStorage.lat.toString();
    final String log = LocalStorage.long.toString();

    debugPrint("🚀 Navigation - Location -> Lat: $lat, Long: $log");

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
                //apple fix: get started now requests permission, cannot skip==============================
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
                //apple fix: changed from "Enable Location" to "Location Access"==============================
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