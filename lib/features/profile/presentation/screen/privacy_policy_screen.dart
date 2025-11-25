import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../component/text/common_text.dart'; // Assuming you use screenutil

// Define standard colors based on the image (Black, White, Grayish background)
class AppColor {
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF333333);
}


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard padding for the main content
    final double horizontalPadding = 20.w;

    return Scaffold(
      backgroundColor: AppColor.background,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SUMMARY
              _buildSectionTitle('SUMMARY'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'Thank You For Using Clicker Count App! We Respect Your Concerns About Privacy And Appreciate Your Trust And Confidence In Us.',
              ),
              SizedBox(height: 16.h),
              _buildBodyText(
                'Here Is A Summary Of The Information Contained In This Privacy Policy ("Privacy Policy"). This Summary Is To Help You Navigate The Privacy Policy And It Is Not A Substitute For Reading Everything!',
              ),
              SizedBox(height: 24.h),

              // 2. DOES THIS PRIVACY POLICY APPLY TO YOU?
              _buildSectionTitle('DOES THIS PRIVACY POLICY APPLY TO YOU?'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'This Privacy Policy Only Applies To You If You Are A Clicker Count App User.',
              ),
              SizedBox(height: 24.h),

              // 3. WHAT INFORMATION DO YOU NEED TO PROVIDE CLICKER COUNT APP?
              _buildSectionTitle(
                'WHAT INFORMATION DO YOU NEED TO PROVIDE CLICKER COUNT APP?',
              ),
              SizedBox(height: 8.h),
              _buildBodyText(
                'When You Register For A Clicker Count App Account, We Will Need Your Mobile Number, Email And An Alias You Can Further Define And Operate Your Profile With Additional Information. If You Use Certain Functions Available Within Clicker Count App (Such As Posting Photos To Your Clicker Count App Events) We Will Process Your Information To Provide These Functions.',
              ),
              SizedBox(height: 24.h),

              // 4. HOW DO WE USE YOUR INFORMATION?
              _buildSectionTitle('HOW DO WE USE YOUR INFORMATION?'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'We Use Your Information To Provide Clicker Count App To You, Allow You To Communicate With Other Users, Allow You To Use The Features Available On Clicker Count App, And To Improve And Operate Your Clicker Count App Experience. If You Are A Parent Or Guardian Who Has Granted Permission For Your Child To Use Clicker Count App Then We Shall Use Contact Information You Have Provided To Ensure We Can Validate Any Goods Or Queries You May Have In Relation To Your Child\'s Clicker Count App Account.',
              ),
              SizedBox(height: 24.h),

              // 5. WHO DO WE SHARE YOUR DATA WITH?
              _buildSectionTitle('WHO DO WE SHARE YOUR DATA WITH?'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'We Do Not Share Your Information With Third Parties, Except Where We Need To In Order To Provide The Service (e.g., SMS Service Providers) Or If We Are Instructed To By A Court, Authority Or Compelled By Law. We Use These Third Party Services Solely To Process Or Store Your Information For The Purposes Described In This Privacy Policy.',
              ),
              SizedBox(height: 24.h),

              // 6. WHERE DO WE PROCESS YOUR DATA?
              _buildSectionTitle('WHERE DO WE PROCESS YOUR DATA?'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'Our Servers And Associated Globally We Also Have Support, Engineering And Other Teams That Support The Provision Of Clicker Count App To You, Located Around The World (Including Singapore), Who Will Have Access To Your Information.',
              ),
              SizedBox(height: 24.h),

              // 7. HOW WILL WE NOTIFY YOU OF CHANGES?
              _buildSectionTitle('HOW WILL WE NOTIFY YOU OF CHANGES?'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'If There Are Any Significant Changes To This Privacy Policy, We Will Update It Here And Notify You Before The Change Becomes Effective.',
              ),
              SizedBox(height: 24.h),

              // 8. CONTACT US
              _buildSectionTitle('CONTACT US.'),
              SizedBox(height: 8.h),
              _buildBodyText(
                'If You Have Any Questions Or Complaints Regarding This Privacy Policy Or The Use Of Your Personal Information, Please Contact Our Data Protection Officer Via Email ',
                isPartial: true,
              ),
              CommonText(
                text: 'marketing@just-metaverse.com',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue, // To match the link color
              ),
              _buildBodyText(
                ' (Attention: Data Protection Officer).',
                isPartial: true,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
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