import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import '../../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../controller/sign_up_controller.dart';
import '../../../../../../../utils/constants/app_string.dart';
import '../widget/already_accunt_rich_text.dart';
import '../widget/sign_up_all_filed.dart';

class SignUpScreen extends StatelessWidget {
   SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Section Starts Here
      appBar: AppBar(leading: const SizedBox()),

      /// Body Section Starts Here
      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /// Sign UP Instructions here
                  const CommonText(
                    text: AppString.createYourAccount,
                    fontSize: 32,
                    bottom: 20,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),

                  /// All Text Filed here
                  SignUpAllField(controller: controller),

                  16.height,

                  /// Submit Button Here
                  CommonButton(
                    titleText: AppString.signUp,
                    isLoading: controller.isLoading,
                    onTap: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      controller.signUpUser();
                    },
                  ),
                  const SizedBox(height: 20),

                  const CommonText(text: "Or Sign Up With", color: Colors.grey),

                  24.height,

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.h,
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Color(0xFFD1D5D6) /* Disable-Color */,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Color(0xFFD1D5D6) /* Disable-Color */,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                  const SizedBox(height: 1),

                  ///  Sign In Instruction here
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 60.h,
          child: const Column(children: [AlreadyAccountRichText()]),
        ),
      ),
    );
  }
}
