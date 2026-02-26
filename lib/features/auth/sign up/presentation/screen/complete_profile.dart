import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/image/common_image.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_images.dart';
import '../controller/sign_up_controller.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final SignUpController controller = Get.find<SignUpController>();

  /// Helper function to convert string to Title Case (First letter capital only)
  String toTitleCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
          text: 'Complete Your Profile',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
          textAlign: TextAlign.left,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Center(
                child: GetBuilder<SignUpController>(
                  builder: (controller) {
                    return Stack(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: controller.image != null
                                ? CommonImage(
                              imageSrc: controller.image!,
                              fill: BoxFit.cover,
                            )
                                : const CommonImage(
                              imageSrc: AppImages.profile,
                              fill: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => controller.openGallery(),
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),

              _buildPrivacyDropdown().center,

              SizedBox(height: 32.h),

              // Bio Field
              const CommonText(
                text: 'Bio',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
                bottom: 8,
              ),
              CommonTextField(
                controller: controller.bioController,
                hintText: 'Type...',
                hintTextColor: Colors.grey,
                textColor: AppColors.black,
                maxLines: 2,
              ),

              // Date of Birth Field
              CommonText(
                text: 'Age',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
                bottom: 8,
                top: 8.h,
              ),
              CommonTextField(
                controller: controller.ageController,
                hintText: 'Type your age',
                hintTextColor: AppColors.grey,
                textColor: AppColors.black,
              ),

              SizedBox(height: 20.h),

              // Gender Field
              CommonText(
                text: 'Gender',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
                bottom: 8,
                top: 8.h,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedGender,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.secondaryText,
                    size: 24.sp,
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  items: controller.genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      // Display with title case (First letter capital)
                      child: Text(toTitleCase(gender)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedGender = newValue;
                      controller.update();
                    }
                  },
                  hint: Text(
                    "Select Gender",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Confirm Button
              CommonButton(
                titleText: 'Confirm',
                onTap: () {
                  controller.updateProfile();
                },
                buttonHeight: 48.h,
                titleSize: 16,
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Container(
            width: 10,
            height: 10,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: const Stack(),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Public',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF373737),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          Container(
            transform: Matrix4.identity()
              ..translate(0.0)
              ..rotateZ(-1.57),
            width: 29.01,
            height: 16,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: const Stack(),
          ),
        ],
      ),
    );
  }
}