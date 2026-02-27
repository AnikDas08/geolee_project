import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/helpers/other_helper.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:io'; // Import for File
import '../controller/provider_complete_profile_controller.dart';

class ServiceProviderInfoScreen extends StatefulWidget {
  const ServiceProviderInfoScreen({super.key});

  @override
  State<ServiceProviderInfoScreen> createState() =>
      _ServiceProviderInfoScreenState();
}

class _ServiceProviderInfoScreenState extends State<ServiceProviderInfoScreen> {
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
                              ? const CommonImage(
                                  imageSrc:
                                      "assets/images/profilePlaceholder.jpg",
                                  size: 100,
                                  defaultImage:
                                      "assets/images/profilePlaceholder.jpg",
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
                      validator: OtherHelper.validator,
                    ),

                    const SizedBox(height: 20),

                    // Bio Field
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
                      validator: OtherHelper.validator,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      controller: controller.phoneNumberController,
                      initialCountryCode: 'SG',
                      disableLengthCheck: true,

                      // আমরা নিজেই length control করবো
                      decoration: InputDecoration(
                        hintText: '8123 4567',
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),

                      keyboardType: TextInputType.phone,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15), // 👉 max 15 digit
                      ],

                      validator: (phone) {
                        if (phone == null || phone.number.trim().isEmpty) {
                          return "Phone number is required";
                        }

                        final length = phone.number.length;

                        if (length < 8) {
                          return "Minimum 8 digits required";
                        }

                        if (length > 15) {
                          return "Maximum 15 digits allowed";
                        }

                        if (!phone.isValidNumber()) {
                          return "Invalid phone number";
                        }

                        return null;
                      },

                      onChanged: (phone) {
                        controller.countryCode = phone.countryCode;
                        controller.fullPhoneNumber = phone.completeNumber;
                      },

                      onCountryChanged: (country) {
                        controller.countryCode = '+${country.dialCode}';
                      },
                    ),
                    SizedBox(height: 4),

                    const Text(
                      '• Minimum 10 digits, Maximum 15 digits \n• Optional + sign at the beginning',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Business License Number (UEN)',
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
                      validator: OtherHelper.validator,
                    ),
                    const SizedBox(height: 20),
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
                      validator: OtherHelper.validator,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              Obx(
                () => CommonButton(
                  isLoading: controller.isLoading.value,
                  titleText: "Confirm",
                  buttonHeight: 50,
                  onTap: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.completeAdvertiserInfo();
                    } else {
                      debugPrint("Form validation failed");
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
