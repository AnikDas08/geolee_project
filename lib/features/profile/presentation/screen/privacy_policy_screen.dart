import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../component/text/common_text.dart';
import '../controller/terms_of_services_controller.dart'; // Assuming you use screenutil

// Define standard colors based on the image (Black, White, Grayish background)
class AppColor {
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF333333);
}


class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {

  final controller = TermsOfServicesController.instance;
  @override
  Widget build(BuildContext context) {
    // Standard padding for the main content
    final double horizontalPadding = 20.w;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CommonText(
          text: 'Privacy Policy',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.black,
        ),
        backgroundColor: AppColor.white,
        // The image shows a default iOS-style back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              SizedBox(height: 24.h),

              Html(
                data: controller.privacyPolicyHtmlContent.value,
                style: {
                  "body": Style(
                    fontSize: FontSize(14),
                    color: AppColor.textBody,
                    lineHeight: LineHeight(1.5),
                  ),
                  "h1": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                  "h2": Style(
                    fontSize: FontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // Helper method for Section Titles (Bold, Uppercase, Black)
  Widget _buildSectionTitle(String text) {
    return CommonText(
      text: text,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColor.black,
      maxLines: 2,
      textAlign: TextAlign.start,
    );
  }

  // Helper method for Body Text (Normal weight, slightly lighter color)
  Widget _buildBodyText(String text, {bool isPartial = false}) {
    // If it's a partial text, we wrap it in a RichText to flow with the email link
    if (isPartial) {
      return Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: AppColor.textBody,
            height: 1.5,
          ),
        ),
      );
    }

    return CommonText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
      maxLines: 10,
      textAlign: TextAlign.start,
    );
  }
}