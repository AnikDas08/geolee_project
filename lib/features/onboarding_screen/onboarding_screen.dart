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

  /// 🔁 Check permission every time screen is visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures we check permission every time we navigate to this screen
    _initializeLocation();
  }

  /// 🔁 App foreground এ এলে আবার check + save
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeLocation();
    }
  }

  /// 🚀 Initialize: Check status + Save if enabled
  Future<void> _initializeLocation() async {
    await _checkLocationStatus();

    // যদি location enabled থাকে, তাহলে save করো
    if (isLocationEnabled) {
      await _saveCurrentLocation();
    }
  }

  /// 📍 Service + Permission check
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

      debugPrint("🔍 Location Status: Service=$serviceEnabled, Permission=$permission, Enabled=$isLocationEnabled");
    } catch (e) {
      debugPrint("❌ Location check error: $e");
      if (mounted) {
        setState(() => isLocationEnabled = false);
      }
    }
  }

  /// 🔄 Switch toggle - Always shows permission dialog
  Future<void> _toggleLocation(bool value) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      if (value) {
        // Turning ON - Request permission
        await _enableLocation();
      } else {
        // Turning OFF - Guide user to settings
        await _disableLocation();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// ✅ Enable location - Shows permission dialog
  Future<void> _enableLocation() async {
    // Step 1: Check if service is enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      final bool? open = await _showLocationServiceDialog();
      if (open == true) {
        await Geolocator.openLocationSettings();
        // Wait a bit for user to enable location
        await Future.delayed(const Duration(milliseconds: 500));
      }
      await _initializeLocation(); // Re-check and save if enabled
      return;
    }

    // Step 2: Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    // Step 3: Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // User denied permission
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

    // Step 4: If permanently denied, show settings dialog
    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDeniedDialog();
      return;
    }

    // Step 5: If permission granted, save location immediately
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {

      await _checkLocationStatus(); // Update toggle state

      // 🔥 SAVE LOCATION immediately after enabling
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

  /// ❌ Disable (manual only)
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
      // Wait for user to return
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await _initializeLocation(); // Re-check status
  }

  /// 📍 Get & save location - Returns true if successful
  Future<bool> _saveCurrentLocation() async {
    try {
      debugPrint("📍 Fetching current location...");

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Add timeout
      );

      // Save as double to SharedPreferences to keep type consistent
      await LocalStorage.setDouble(LocalStorageKeys.lat, position.latitude);
      await LocalStorage.setDouble(LocalStorageKeys.long, position.longitude);

      debugPrint(
        "✅ Location saved → Lat: ${position.latitude}, Long: ${position.longitude}",
      );

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

  /// Dialogs
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
      // Wait for user to return from settings
      await Future.delayed(const Duration(milliseconds: 500));
      await _initializeLocation(); // Re-check and save if enabled
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
              ),
              10.height,
              CommonText(
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
                onTap: () async {
                  // Get current saved location
                  final String lat = LocalStorage.lat.toString();
                  final String log = LocalStorage.long.toString();

                  debugPrint("🚀 Navigation - Location -> Lat: $lat, Long: $log");

                  Get.toNamed(AppRoutes.signUp);
                },
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
                  'Enable Location',
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