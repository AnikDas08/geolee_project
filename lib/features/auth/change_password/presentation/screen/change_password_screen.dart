import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import '../controller/change_password_controller.dart';
import 'package:giolee78/utils/constants/app_string.dart';
import 'package:giolee78/utils/helpers/other_helper.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder<ChangePasswordController>(
        builder: (controller) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CommonImage(
                      imageSrc: AppIcons.changePassword,
                      size: 200,
                    ),
                    40.height,
                    const CommonText(
                      text: AppString.changePassword,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      bottom: 40,
                    ),

                    /// current Password section
                    const CommonText(
                      text: AppString.currentPassword,
                      bottom: 8,
                    ).start,
                    CommonTextField(
                      controller: controller.currentPasswordController,
                      hintText: AppString.currentPassword,
                      validator: OtherHelper.passwordValidator,
                      isPassword: true,
                    ),

                    /// New Password section
                    const CommonText(
                      text: AppString.newPassword,
                      bottom: 8,
                      top: 16,
                    ).start,
                    CommonTextField(
                      controller: controller.newPasswordController,
                      hintText: AppString.newPassword,
                      validator: OtherHelper.passwordValidator,
                      isPassword: true,
                    ),

                    /// confirm Password section
                    const CommonText(
                      text: AppString.confirmPassword,
                      bottom: 8,
                      top: 16,
                    ).start,
                    CommonTextField(
                      controller: controller.confirmPasswordController,
                      hintText: AppString.confirmPassword,
                      validator: (value) =>
                          OtherHelper.confirmPasswordValidator(
                            value,
                            controller.newPasswordController,
                          ),
                      isPassword: true,
                    ),

                    20.height,

                    /// submit Button
                    CommonButton(
                      titleText: AppString.update,
                      isLoading: controller.isLoading,
                      onTap: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        controller.changePasswordRepo();
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
