import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_string.dart';
import 'package:giolee78/utils/extensions/extension.dart';
// import 'package:geolocator/geolocator.dart'; // No longer needed for this simplified logic

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isLocationEnabled = false;
  bool isLoading = false;

  // --- MODIFIED METHOD: Synchronous toggle without geolocation calls ---
  void _toggleLocation(bool value) {
    // Set loading state temporarily if needed, though for a synchronous change, it's mostly visual.
    setState(() => isLoading = true);

    // Update the state immediately
    setState(() {
      isLocationEnabled = value;
      isLoading = false; // Stop loading immediately
    });

    // Show immediate feedback
    if (mounted) {
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location Access Enabled (Simulated)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location access has been turned off (Simulated)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // --- REMOVED unused dialog methods for simplicity ---
  // _showLocationServiceDialog()
  // _showPermissionDeniedDialog()
  // _showPermissionDeniedForeverDialog()

  @override
  Widget build(BuildContext context) {
    // Ensuring ScreenUtil is initialized (assuming external setup for a real Flutter app)
    // ScreenUtil.init(context, designSize: const Size(360, 800));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              100.height,
              // Replace CommonImage with a placeholder or simple Icon if CommonImage is unavailable
              const CommonImage(imageSrc: AppIcons.onboarding), // Placeholder for CommonImage(imageSrc: AppIcons.onboarding)
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
                onTap: () {
                  // Assuming AppRoutes.signUp exists and Get is configured
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable Location',
                  style: TextStyle(
                    color: Color(0xFF373737),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Allow us to find the best vibes around you.',
                  style: TextStyle(
                    color: Color(0xFF727272),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Using Switch.adaptive for better platform look-and-feel
          Switch.adaptive(
            value: isLocationEnabled,
            // The onChanged handler is now a simple synchronous method
            onChanged: (value) {
              if (isLoading) return; // Prevent interaction if still "loading"
              _toggleLocation(value);
            },
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