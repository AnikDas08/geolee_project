import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/advertise/presentation/screen/verify_user.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import '../controller/provider_info_controller.dart';

class ServiceProviderInfoScreen extends StatelessWidget {
  ServiceProviderInfoScreen({super.key});

  final ServiceProviderController controller = Get.put(
    ServiceProviderController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Advertise With Us',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50.sp,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: CommonImage(
                      imageSrc: ApiEndPoint.imageUrl + LocalStorage.myImage,
                      size: 100,
                      defaultImage: AppImages.profileImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category Dropdown
              const Text(
                'Business Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: controller.businessNameController,
                hintText: 'Business Name',
              ),

              const SizedBox(height: 20),

              // Experience TextField
              const Text(
                'Bio',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: controller.bioController,
                hintText: 'Bio',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Experience TextField
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: controller.phoneNumberController,
                hintText: 'Phone Number',
              ),
              const SizedBox(height: 20),

              const Text(
                'Business License Number ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: controller.businessLicenseNumberController,
                hintText: 'Business License Number',
              ),
              const SizedBox(height: 20),

              // Sub Category Dropdown
              const Text(
                'Business Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CommonTextField(
                controller: controller.businessTypeController,
                hintText: 'Business Type',
              ),
              const SizedBox(height: 20),

              // Experience TextField
              const SizedBox(height: 20),

              // Confirm Button
              CommonButton(
                titleText: "Confirm",
                buttonHeight: 40,
                onTap: () {
                  Get.to(() => const VerifyUser());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
