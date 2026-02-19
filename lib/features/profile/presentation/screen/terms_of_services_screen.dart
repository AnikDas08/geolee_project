
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/profile/presentation/screen/privacy_policy_screen.dart';

import '../../../../component/text/common_text.dart';
import '../controller/terms_of_services_controller.dart';

class TermsOfServicesScreen extends StatefulWidget {
  const TermsOfServicesScreen({super.key});

  @override
  State<TermsOfServicesScreen> createState() => _TermsOfServicesScreenState();
}

class _TermsOfServicesScreenState extends State<TermsOfServicesScreen> {
  final controller = TermsOfServicesController.instance;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 20.w;

    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const CommonText(
          text: 'Terms & Condition',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColor.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColor.black, size: 20.sp),
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
              /// TITLE
              const Center(
                child: CommonText(
                  text: 'Welcome To Clicker Count App!',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),

              SizedBox(height: 24.h),

              /// 🔥 HTML CONTENT
              Html(
                data: controller.termsAndConditionHtmlContent.value,
                style: {
                  "body": Style(
                    fontSize: FontSize(14),
                    color: AppColor.textBody,
                    lineHeight: const LineHeight(1.5),
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
}
