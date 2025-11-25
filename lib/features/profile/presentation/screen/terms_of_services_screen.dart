import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../component/text/common_text.dart';

// --- Shared Helper Definitions (Mimicking your project's components) ---
class AppColor {
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textBody = Color(0xFF333333);
  static const Color redError = Color(0xFFF44336); // Red color for the welcome text
}


// --- TermsAndConditionsScreen Class ---

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = 20.w;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: CommonText(
          text: 'Terms & Condition',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.black,
        ),
        backgroundColor: AppColor.white,
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
              // --- Welcome Heading (Red, Bold, Center-Aligned) ---
              Center(
                child: CommonText(
                  text: 'Welcome To Clicker Count App!',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.redError,
                  textAlign: TextAlign.center,
                  //height: 1.0,
                ),
              ),
              SizedBox(height: 24.h),

              // --- Body Paragraph 1 ---
              _buildBodyText(
                'These "Terms" Of Use Govern Your Access And Use Of Clicker Count App, Except Where We Expressly State That Separate Terms (And Not These) Apply, And Provide Information About The Clicker Count App Service (The "Service"), Outlined Below.',
              ),
              SizedBox(height: 16.h),

              _buildBodyText(
                'The Clicker Count App Service is one of service, provided to you by Just Metaverse (Pte. Ltd.). These Terms of Use therefore constitute an agreement between you and Just Metaverse (Pte. Ltd.). If you do not agree to these Terms, then do not access or use Clicker Count App.',),
              SizedBox(height: 16.h),

              // --- Section 1 Heading ---
              _buildSectionTitle('1. The Clicker Count App Service'),
              SizedBox(height: 16.h),

              // --- Section 1 Body Paragraph 1 ---
              _buildBodyText(
                'We agree to provide you with the Clicker Count App Service. The Service includes All of The Clicker Count App products, features, applications, services, Technologies And software that we provide to advance Clicker Count App\'s mission: A mobile platform that brings together fun, social interaction, and real-time data visualization. The Service is made up of the following aspects: Offering personalised opportunities to create, connect, communicate,Discover And share.We offer you different types of accounts And features to help you create, share, grow your presence and communicate with people on and off Clicker Count App. Designed for outdoor enthusiasts, this app allows users to track and share their sightings of attractive individuals while engaging in outdoor activities like walks and hikes. This innovative app blends location-based services, community-driven features, and ethical data collection, offering a unique and exciting way for users to interact with their surroundings and each other. Fostering a positive, Inclusive And safe environment. Ensuring access to our Service. Connecting you with brands, products and services in ways that you care about. Research and innovation.',
              ),

              // --- Section 1 Heading ---
              _buildSectionTitle('2. How our service is funded '),
              SizedBox(height: 16.h),

              // --- Section 1 Body Paragraph 1 ---
              _buildBodyText(
                'Instead of paying to use Clicker Count App, by using the Service covered by these Terms, you acknowledge that we can show you ads that businesses and organisations pay us to promote on and off the Clicker Count App. We may use your personal data, such as information about your activity and interests, to show you ads that are more relevant to you. We may show you relevant and useful ads without telling advertisers who you are. We don\'t sell your personal data. We allow advertisers to tell us things such as their business goal and the kind of audience they want to see their ads. We then show their ad to people who might be interested. We also provide advertisers with reports about the performance of their ads to help them understand how people are interacting with their content on and off Clicker Count App. We don\'t share information that directly identifies you (information such as your name or email address that by itself can be used to contact you or identifies who you are) unless you give us specific permission. You may see branded content on Clicker Count App posted by account holders who promote products or services based on a commercial relationship with the business partner mentioned in their content. '
              ),
              SizedBox(height: 16.h),

              // --- Section 1 Heading ---
              _buildSectionTitle('3. The Privacy Policy '),
              SizedBox(height: 16.h),

              // --- Section 1 Body Paragraph 1 ---
              _buildBodyText(
                'Providing our Service requires collecting and using your information. The PRivacy Policy explains how we collect, use and share information. It also explains the many ways in which you can control your information, including in the Clicker Count App Privacy. You must agree to the Privacy Policy to use Clicker Count App.'
              ),


              _buildSectionTitle('4. Your Commitments '),
              SizedBox(height: 16.h),

              // --- Section 1 Body Paragraph 1 ---
              _buildBodyText(
                  'In return for our commitment to provide the Service, we require you to make the below commitments to us. '
              ),

              _buildSectionTitle('4.1 Who can use Clicker Count App. '),
              SizedBox(height: 16.h),

              // --- Section 1 Body Paragraph 1 ---
              _buildBodyText(
                  'We want our Service to be as open and inclusive as possible, but we also want it to be safe, secure and in accordance with the law. So, we need you to commit to a few restrictions in order to be part of the Clicker Count App community. You must be at least 13 years old or the minimum legal age in your country to use Clicker Count App. You must not be prohibited from receiving any aspect of our Service under applicable laws or engaging in payments-related Services if you are on an applicable denied party listing. We must not have previously disabled your account for violation of law or any of our policies. You must not be a convicted sex offender.'
              ),

              _buildSectionTitle('4.2 How you can\'t use Clicker Count App. '),
              SizedBox(height: 16.h),

              // --- Section 1 Body Paragraph 1 ---
              _buildBodyText(
                'Providing a safe and open Service for a broad community requires that we all do our part. You can\'t impersonate others or provide inaccurate information. You can\'t do anything unlawful, misleading or fraudulent or for an illegal or unauthorised purpose. You can\'t violate (or help or encourage others to violate) these Terms or our policies You can\'t do anything to interfere with or impair the intended operation of the Service. You can\'t attempt to create accounts or access or collect information in unauthorised ways. You can\'t sell, licence or purchase any account or data obtained from us or our Service, regardless of whether such data was obtained while logged in to an Clicker Count App account. You can\'t post someone else\'s private or confidential information without permission or do anything that violates someone else\'s rights, including intellectual property rights (e.g. copyright infringement, trademark infringement, counterfeit or pirated goods). You can\'t modify, translate, create derivative works of or reverse-engineer our products or their components.You can\'t use a domain name or URL in your username without our prior written consent. You can\'t do, or attempt to do, anything to circumvent, bypass or override any technological measures that control or limit access to the Service or data. '),

              SizedBox(height: 16.h),
              // --- Section 1 Body Paragraph 2 (Details) ---
              _buildBodyText(
                'Offering Personalised Opportunities To Create, Connect, Communicate, Discover And Share. We Offer You Different Types Of Accounts And Features To Help You Create, Share, Grow Your Presence And Communicate With People On And Off Clicker Count App. Designed For Outdoor Enthusiasts, This App Allows Users To Track And Share Their Sightings Of Attractive Individuals While Engaging In Outdoor Activities Like Walks And Hikes. This Innovative App Blends Location-Based Services, Community-Driven Features, And Ethical Data Collection, Offering A Unique',
              ),
              // ... Add more content here to fill the rest of the screen

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for Section Titles (Numbered, Black, Semi-bold)
  Widget _buildSectionTitle(String text) {
    return CommonText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColor.black,
      textAlign: TextAlign.start,
      maxLines: 2,
      //height: 1.2,
    );
  }

  // Helper method for Body Text (Normal weight, justified)
  Widget _buildBodyText(String text) {
    return CommonText(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
      textAlign: TextAlign.justify,
      maxLines: 16,
    );
  }
}