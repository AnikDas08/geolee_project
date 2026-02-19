import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../utils/extensions/extension.dart';
import '../controller/provider_complete_profile_controller.dart';
import '../../../../../../../utils/constants/app_colors.dart';
import '../../../../../../../utils/constants/app_string.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/image/common_image.dart';
import '../../../../../../../utils/constants/app_icons.dart';

class ProviderVerifyUser extends StatelessWidget {
  ProviderVerifyUser({super.key});

  final controller = Get.find<ServiceProviderController>();

  @override
  Widget build(BuildContext context) {

    controller.startTimer();

    return Scaffold(
      appBar: AppBar(
        title: const CommonText(
          text: AppString.otpVerify,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
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
              Center(
                child: CommonText(
                  text:
                  "${AppString.codeHasBeenSendTo} ${controller.phoneNumberController.text}",
                  fontSize: 14,
                  bottom: 40,
                  maxLines: 3,
                  color: AppColors.secondaryText,
                )),

              /// OTP field
              PinCodeTextField(
                controller: controller.otpController,
                autoDisposeControllers: false,
                cursorColor: AppColors.black,
                appContext: context,
                autoFocus: true,
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
                enableActiveFill: true,
                validator: (value) {
                  if (value != null && value.length == 6) {
                    return null;
                  } else {
                    return AppString.otpIsInValid;
                  }
                },
              ),
              SizedBox(height: 20.h),

              /// Timer or Resend OTP
              Obx(() => GestureDetector(
                onTap: controller.isResendEnabled.value
                    ? controller.resendOtp
                    : null,
                child: CommonText(
                  text: controller.isResendEnabled.value
                      ? AppString.resendCode
                      : "${AppString.resendCodeIn} ${controller.time.value}",
                  bottom: 20,
                  fontSize: 18,
                  color: controller.isResendEnabled.value
                      ? AppColors.primaryColor
                      : AppColors.textPrimary,
                ),
              )),

              SizedBox(height: 20.h),

              /// Submit Button
              CommonButton(
                titleText: AppString.verify,
                onTap: controller.verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
