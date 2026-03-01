import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../controller/sign_up_controller.dart';
import '../../../../../../../utils/constants/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../../../utils/constants/app_string.dart';

class VerifyUser extends StatefulWidget {
  const VerifyUser({super.key});

  @override
  State<VerifyUser> createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    final controller = Get.find<SignUpController>();
    controller.startTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CommonText(
          text: AppString.otpVerify,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: AppColors.primaryColor,
        ),
      ),
      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const CommonImage(imageSrc: AppIcons.enterotp, size: 250),
                    20.height,
                    const CommonText(
                      text: AppString.otpVerify,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                      bottom: 8,
                    ),

                    /// instruction how to get OTP
                    Center(
                      child: CommonText(
                        text:
                        "${AppString.codeHasBeenSendTo} ${controller.emailController.text}",
                        fontSize: 14,
                        bottom: 40,
                        maxLines: 3,
                        color: AppColors.secondaryText,
                      ),
                    ),


                    Flexible(
                      flex: 0,
                      child: PinCodeTextField(
                        controller: controller.otpController,
                        autoDisposeControllers: false,
                        cursorColor: AppColors.primaryColor,
                        appContext: (context),
                        autoFocus: true,
                        textStyle: const TextStyle(color: AppColors.primaryColor),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(16.r),
                          fieldHeight: 60.h,
                          fieldWidth: 60.w,
                          activeFillColor: AppColors.transparent,
                          selectedFillColor: AppColors.transparent,
                          inactiveFillColor: AppColors.transparent,
                          borderWidth: 0.5.w,
                          selectedColor: AppColors.primaryColor,
                          activeColor: AppColors.primaryColor,
                          inactiveColor: AppColors.black,
                        ),
                        length: 6,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.disabled,
                        enableActiveFill: true,
                        validator: (value) {
                          if (value != null && value.length == 6) {
                            return null;
                          } else {
                            return AppString.otpIsInValid;
                          }
                        },
                      ),
                    ),

                    /// Show Timer
                    if (controller.time != "00:00" && controller.time.isNotEmpty)
                      CommonText(
                        text: "Resend code in ${controller.time}",
                        fontSize: 14,
                        bottom: 20,
                        color: AppColors.secondaryText,
                      ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CommonText(
                          text: "Didn't receive the code?",
                          bottom: 40,
                          maxLines: 3,
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: controller.isResendingOtp || controller.time != "00:00"
                              ? null
                              : () {
                            controller.resendOtp();
                          },
                          child: controller.isResendingOtp
                              ? const SizedBox(
                            width: 60,
                            height: 20,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : CommonText(
                            text: "Resend",
                            bottom: 40,
                            fontWeight: FontWeight.w700,
                            maxLines: 3,
                            color: controller.time == "00:00"
                                ? AppColors.primaryColor
                                : AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),

                    ///  Submit Button here
                    CommonButton(
                      titleText: AppString.verify,
                      isLoading: controller.isLoadingVerify,
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          controller.verifyOtpRepo();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}