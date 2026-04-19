import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../controller/sign_up_controller.dart';

class AddLocation extends StatefulWidget {
  const AddLocation({super.key});

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final SignUpController controller = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          text: 'Add Location',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.left,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map Widget - Full Screen
          GoogleMap(
            initialCameraPosition: controller.initialCameraPosition.value,
            onMapCreated: controller.onMapCreated,
            markers: controller.markers,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: true,
          ),

          // Center Pin Marker
          Center(
            child: Icon(
              Icons.location_on,
              size: 48.sp,
              color: AppColors.primaryColor,
            ),
          ),

          // Bottom Confirmation Button
          Positioned(
            bottom: 24.h,
            left: 20.w,
            right: 20.w,
            child: CommonButton(
              titleText: 'Apply',
              onTap: () => controller.confirmLocation(),
              buttonHeight: 48.h,
              titleSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
