import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/helpers/other_helper.dart';
import 'dart:io'; // Import for File
import '../controller/provider_complete_profile_controller.dart';

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
                child: Stack(
                  children: [
                    Obx(() {
                      return CircleAvatar(
                        radius: 50.sp,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: controller.profileImagePath.value.isEmpty
                              ? CommonImage(

                            imageSrc: "assets/images/profilePlaceholder.jpg",
                            size: 100,
                            defaultImage: "assets/images/profilePlaceholder.jpg",
                          )
                              : Image.file(
                            File(controller.profileImagePath.value),
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.pickImage();
                        },
                        child: CircleAvatar(
                          radius: 18.sp,
                          backgroundColor: AppColors.primaryColor,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      validator: OtherHelper.phoneNumberValidator,
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
                  ],
                ),
              ),

              // Experience TextField
              const SizedBox(height: 20),

              // Confirm Button
              Obx(() => CommonButton(
                isLoading: controller.isLoading.value,
                titleText: "Confirm",
                buttonHeight: 40,
                onTap: () {
                  controller.completeAdvertiserInfo();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}