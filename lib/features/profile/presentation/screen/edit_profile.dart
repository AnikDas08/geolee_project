import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/profile/presentation/controller/profile_controller.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:giolee78/features/profile/presentation/widgets/edit_profile_all_filed.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,

          /// App Bar
          appBar: AppBar(
            centerTitle: true,
            title: CommonText(
              text: 'Edit Profile',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),

          //dlk
          /// Body
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

                      //kljdklf
                      /// All Form Fields
                      EditProfileAllFiled(controller: controller),

                      32.height,

                      /// Update Button
                      CommonButton(
                        titleText: 'Update',
                        onTap: controller.editProfileRepo,
                        isLoading: controller.isLoading,
                        buttonColor: AppColors.primaryColor,
                        titleColor: AppColors.white,
                        buttonHeight: 56.h,
                        buttonRadius: 8.r,
                        titleSize: 16.sp,
                        titleWeight: FontWeight.w600,
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
  Widget _buildProfileImage(ProfileController controller) {
    // --- FIX: Check for both null and empty path before using Image.file ---
    final bool hasSelectedImage = controller.image != null && controller.image!.isNotEmpty;

    // Determine the default/network image source
    String networkImageUrl = LocalStorage.myImage.isNotEmpty
        ? ApiEndPoint.imageUrl + LocalStorage.myImage
        : "assets/images/profile_image.png";

    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3.w),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipOval(
            child: hasSelectedImage
                ? Image.file(
              // Safe to use File() here
              File(controller.image!),
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
            )
                : networkImageUrl.startsWith('assets')
                ? CommonImage(
              imageSrc: networkImageUrl,
              width: 100.w,
              height: 100.h,
              fill: BoxFit.cover,
            )
            // Assuming CommonImage or Image.network handles network URLs
                : CommonImage(
              imageSrc: networkImageUrl, // This assumes CommonImage supports network image
              width: 100.w,
              height: 100.h,
              fill: BoxFit.cover,
            ),
          ),
        ),

        /// Edit Icon
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
}