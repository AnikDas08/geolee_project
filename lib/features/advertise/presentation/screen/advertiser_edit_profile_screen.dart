import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/advertise/presentation/controller/advertiser_edit_profile_controller.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/helpers/other_helper.dart';

class AdvertiserEditProfileScreen extends StatelessWidget {
  const AdvertiserEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertiserEditProfileController>(
      init: Get.isRegistered<AdvertiserEditProfileController>()
          ? null
          : AdvertiserEditProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          // AppBar=======================
          appBar: AppBar(
            centerTitle: true,
            title: CommonText(
              text: 'Edit Profile',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      20.height,

                      /// Profile Image
                      _buildProfileImage(controller),

                      32.height,

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel('Business Name'),
                      ),

                      6.height,

                      CommonTextField(
                        controller: controller.businessNameController,
                        validator: OtherHelper.validator,
                        hintText: 'Enter your Business Name',
                        hintTextColor: AppColors.secondaryText,
                        textColor: AppColors.black,
                      ),

                      10.height,

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel('Bio'),
                      ),

                      6.height,

                      CommonTextField(
                        controller: controller.bioController,
                        validator: OtherHelper.validator,
                        maxLines: 4,
                        hintText:
                        'Skilled professionals offering reliable, on-demand services...',
                        hintTextColor: AppColors.secondaryText,
                        textColor: AppColors.black,
                      ),

                      10.height,

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel('Phone Number'),
                      ),

                      6.height,


                      IntlPhoneField(
                        key: controller.phoneFieldKey,
                        controller: controller.phoneNumberController,


                        initialCountryCode: controller.countryIsoCode,

                        disableLengthCheck: true,

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
                          LengthLimitingTextInputFormatter(15),
                        ],

                        validator: (phone) {
                          if (phone == null || phone.number.trim().isEmpty) {
                            return "Phone number is required";
                          }
                          final length = phone.number.length;
                          if (length < 6) {
                            return "Minimum 6 digits required";
                          }
                          if (length > 15) {
                            return "Maximum 15 digits allowed";
                          }
                          return null;
                        },

                        onChanged: (phone) {
                          controller.countryCode = phone.countryCode;
                          controller.fullPhoneNumber = phone.completeNumber;
                          controller.phoneNumberOnly = phone.number;
                        },

                        onCountryChanged: (country) {

                          controller.countryCode = '+${country.dialCode}';
                          controller.countryIsoCode = country.code;
                          controller.fullPhoneNumber =
                          '+${country.dialCode}${controller.phoneNumberController.text.trim()}';
                        },
                      ),

                      10.height,

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel('Business Licence Number'),
                      ),

                      6.height,

                      CommonTextField(
                        controller: controller.businessLicenceController,
                        validator: OtherHelper.validator,
                        hintText: 'Enter Your Business Licence Number EUN',
                        hintTextColor: AppColors.secondaryText,
                        textColor: AppColors.black,
                      ),

                      10.height,

                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildLabel('Business Type'),
                      ),

                      6.height,

                      CommonTextField(
                        controller: controller.businessTypeController,
                        validator: OtherHelper.validator,
                        hintText: 'Restaurant',
                        hintTextColor: AppColors.secondaryText,
                        textColor: AppColors.black,
                      ),

                      32.height,

                      CommonButton(
                        titleText: 'Update',
                        onTap: controller.editProfileRepo,
                        isLoading: controller.isLoading,
                        buttonHeight: 56.h,
                        buttonRadius: 8.r,
                        titleSize: 16.sp,
                      ),

                      32.height,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Profile Image Widget
  Widget _buildProfileImage(AdvertiserEditProfileController controller) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3.w),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(child: _buildImage(controller)),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.getProfileImage,
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2.w),
              ),
              child: Icon(Icons.edit, color: AppColors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return CommonText(
      text: text,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      textAlign: TextAlign.start,
    );
  }

  Widget _buildImage(AdvertiserEditProfileController controller) {
    if (controller.selectedImage != null) {
      return Image.file(
        controller.selectedImage!,
        width: 100.w,
        height: 100.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildNetworkOrDefaultImage();
        },
      );
    }
    return _buildNetworkOrDefaultImage();
  }

  Widget _buildNetworkOrDefaultImage() {
    if (LocalStorage.myImage.isNotEmpty) {
      return CommonImage(
        imageSrc: ApiEndPoint.imageUrl + LocalStorage.businessLogo,
        width: 100.w,
        height: 100.h,
        fill: BoxFit.cover,
      );
    }
    return CommonImage(
      imageSrc: "assets/images/profile_image.png",
      width: 100.w,
      height: 100.h,
      fill: BoxFit.cover,
    );
  }
}