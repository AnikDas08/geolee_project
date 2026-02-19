import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/component/text_field/common_text_field.dart';
import 'package:giolee78/features/profile/presentation/controller/help_support_controller.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_string.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'package:giolee78/utils/enum/enum.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const CommonText(
          text: 'Help & Support',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: _bodySection(),
    );
  }

  /// Body Section starts here
  Widget _bodySection() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            SizedBox(height: 16.h),
            _buildDescriptionField(),
            SizedBox(height: 16.h),
            Center(child: _buildAttachFileSection()),
            SizedBox(height: 24.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Name field
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          text: 'Issue Title',
          fontSize: 14,
        ),
        SizedBox(height: 8.h),
        CommonTextField(
          controller: HelpSupportController.instance.titleController,
          borderRadius: 8.r,
          hintText: 'Enter your Issue Title',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppString.thisFieldIsRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Description field
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          text: 'Description',
          fontSize: 14,
        ),
        SizedBox(height: 8.h),
        CommonTextField(
          controller: HelpSupportController.instance.messageController,
          hintText:
              'If you are having trouble to sign in with Account then you can Email us in Account Issues or Choosing Other Issue Regarding',
          textInputAction: TextInputAction.newline,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          borderRadius: 8.r,
        ),
      ],
    );
  }

  /// Attach file section
  Widget _buildAttachFileSection() {
    return GetBuilder<HelpSupportController>(
      builder: (controller) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                controller.pickImage();
              },
              borderRadius: BorderRadius.circular(4.r),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 109,
                  vertical: 17,
                ),
                decoration: ShapeDecoration(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Color(0xFFD1D5D6)),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x1E000000),
                      blurRadius: 50,
                      offset: Offset(20, 20),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CommonImage(
                      imageSrc: AppIcons.attachment,
                      width: 24,
                      height: 24,
                    ),
                    8.width,
                    const CommonText(
                      text: 'Attach File',
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
            if (controller.image != null) ...[
              SizedBox(height: 12.h),
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Stack(
                    children: [
                      Image.file(
                        controller.image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            controller.image = null;
                            controller.update();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Submit button
  Widget _buildSubmitButton() {
    return GetBuilder<HelpSupportController>(
      builder: (controller) {
        return CommonButton(
          titleText: 'Submit',
          isLoading: controller.status == Status.loading,
          onTap: () {
            controller.supportAdminRepo();
          },
        );
      },
    );
  }
}
