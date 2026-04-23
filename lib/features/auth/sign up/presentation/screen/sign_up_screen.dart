import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final controller = Get.put(SignUpController());
  @override
  Widget build(BuildContext context) {

    final signUpFormKey = GlobalKey<FormState>();
    return Scaffold(

      appBar: AppBar(leading: const SizedBox()),

      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: signUpFormKey,
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

                  10.height,

                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: controller.isAgreed,
                          activeColor: AppColors.primaryColor,
                          onChanged: (value) => controller.toggleAgreement(value),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with ",
                            style: TextStyle(fontSize: 14.sp, color: Colors.black),
                            children: [
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () async {
                                    final url = Uri.parse("https://clicker1380.just-metaverse.com/public/privacy-policy");
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                                  child: Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  20.height,

                  /// Submit Button Here
                  CommonButton(
                    titleText: AppString.signUp,
                    isLoading: controller.isLoading,
                    onTap: () {
                      if (!controller.isAgreed) {
                        Utils.errorSnackBar("Agreement Required", "Please agree to the Terms & Conditions");
                        return;
                      }
                      controller.signUpUser(signUpFormKey);
                    },
                  ),
                  const SizedBox(height: 20),

                  const CommonText(
                    text: "Or Sign Up With",
                    color: Colors.grey,
                  ),

                  24.height,

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.signInWithGoogle(),
                          child: Container(
                            height: 48.h,
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color: Color(
                                    0xFFD1D5D6,
                                  ) /* Disable-Color */,
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
                      ),
                      if (Platform.isIOS) ...[
                        SizedBox(width: 12.h),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              controller.signInWithApple();
                            },
                            child: Container(
                              height: 48.h,
                              width: double.infinity,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Color(
                                      0xFFD1D5D6,
                                    ) /* Disable-Color */,
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
                        ),
                      ],
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
