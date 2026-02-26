

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import '../../../../../../../config/route/app_routes.dart';
import '../../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/sign_in_controller.dart';

import '../../../../../../../utils/constants/app_colors.dart';
import '../../../../../../../utils/constants/app_string.dart';
import '../../../../../../../utils/helpers/other_helper.dart';
import '../widgets/do_not_account.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        actions: [

          GestureDetector(
            onTap: () {
              Get.offNamed(AppRoutes.homeNav);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: const CommonText(
                text: 'Skip',
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      /// Body Sections Starts here
      body: GetBuilder<SignInController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Log In Instruction here
                  const CommonImage(imageSrc: AppImages.logo, size: 110).center,
                  20.height,

                  /// Account Email Input here
                  const CommonText(text: AppString.email, bottom: 8),
                  CommonTextField(
                    controller: controller.emailController,
                    hintText: AppString.email,
                    validator: OtherHelper.emailValidator,
                  ),

                  /// Account Password Input here
                  const CommonText(
                    text: AppString.password,
                    bottom: 8,
                    top: 24,
                  ),
                  CommonTextField(
                    controller: controller.passwordController,
                    isPassword: true,
                    hintText: AppString.password,
                    validator: OtherHelper.passwordValidator,
                  ),

                  /// Forget Password Button here
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.forgotPassword),
                      child: const CommonText(
                        text: AppString.forgotPassword,
                        top: 10,
                        bottom: 30,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// Submit Button here
                  CommonButton(
                    titleText: AppString.login,
                    isLoading: controller.isLoading,
                    onTap: () => {
                      controller.signInUser(formKey)
                    },
                  ),
                  30.height,

                  const Center(
                    child: CommonText(
                      text: "Or Sign In With",
                      color: Colors.grey,
                    ),
                  ),

                  24.height,

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Apple Icon
                              SvgPicture.asset(
                                'assets/icons/googleicon.svg',
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(width: 10.w),

                              // Apple Text
                              Text(
                                'Google',
                                style: TextStyle(
                                  color: AppColors.textColorFirst,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.h),
                      Expanded(
                        child: Container(
                          height: 48.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Apple Icon
                              SvgPicture.asset(
                                'assets/icons/apple_fons.svg',
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(width: 10.w),

                              // Apple Text
                              Text(
                                'Apple',
                                style: TextStyle(
                                  color: AppColors.textColorFirst,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 60.h,
          child: const Column(children: [DoNotHaveAccount()]),
        ),
      ),
    );
  }
}