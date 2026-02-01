import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/other_widgets/item.dart';
import 'package:giolee78/component/pop_up/common_pop_menu.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/auth/change_password/presentation/screen/change_password_screen.dart';
import 'package:giolee78/features/profile/presentation/controller/my_profile_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/profile_controller.dart';
import 'package:giolee78/features/profile/presentation/screen/help_support_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/my_profile_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/privacy_policy_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/terms_of_services_screen.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/extensions/extension.dart';

import '../../../../config/api/api_end_point.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          final List<ProfileItemData> profileItems = [
            ProfileItemData(
              imageSrc: AppIcons.profile,
              title: 'My Profile',
              onTap: () {
                Get.to(() => const MyProfileScreen());
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.edit,
              title: 'Change Password',
              onTap: () {
                Get.to(() => const ChangePasswordScreen());
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.privacy,
              title: 'Privacy Policy',
              onTap: () {
                Get.to(() => const PrivacyPolicyScreen());
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.terms,
              title: 'Terms of Services',
              onTap: () {
                Get.to(() => const TermsOfServicesScreen());
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.support,
              title: 'Help & Support',
              onTap: () {
                Get.to(() => const HelpSupportScreen());
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.deleteAccount,
              title: 'Delete Account',
              onTap: () {
                deletePopUp(
                  controller: TextEditingController(),
                  onTap: () {},
                  isLoading: false,
                );
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.logout,
              title: 'Log Out',
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ];

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    /// User Profile Image here
                    Center(
                      child: CircleAvatar(
                        radius: 50.sp,
                        backgroundColor: Colors.transparent,
                        child: GetBuilder<MyProfileController>(
                          builder: (myProfileController) {
                            return ClipOval(
                              child: myProfileController.userImage.isNotEmpty
                                  ? CommonImage(
                                imageSrc: ApiEndPoint.imageUrl + myProfileController.userImage,
                                width: 120.w,
                                height: 120.h,
                                fill: BoxFit.cover,
                              )
                                  : CommonImage(
                                imageSrc: AppImages.profile,
                                width: 120.w,
                                height: 120.h,
                                fill: BoxFit.cover,
                              ),
                            );
                          }
                        ),
                      ),
                    ),

                    /// User Name here
                    CommonText(
                      text: LocalStorage.myName,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      top: 16,
                      bottom: 8.h,
                    ),
                    CommonText(
                      text:LocalStorage.bio.isNotEmpty?LocalStorage.bio:"Bio Not Set Yet",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      bottom: 20,
                      maxLines: 2,
                      left: 25,
                      right: 25,
                      color: AppColors.secondaryText,
                    ),
                    if(LocalStorage.myRole==UserType.user.name)
                    CommonButton(
                      titleText: 'Public',
                      buttonWidth: 80.w,
                      titleSize: 12,
                      buttonHeight: 32.h,
                      borderWidth: 4,
                      borderColor: AppColors.primaryColor2,
                      buttonColor: AppColors.primaryColor2,
                    ),

                    16.height,

                    /// Edit Profile item here
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profileItems.length,
                      itemBuilder: (context, index) {
                        final item = profileItems[index];
                        return Item(
                          imageSrc: item.imageSrc,
                          title: item.title,
                          onTap: item.onTap,
                        );
                      },
                    ),
                    SizedBox(height: 20.h,),
                    if (LocalStorage.myRole != UserType.advertise.name)
                    CommonButton(
                        titleText: "Adverise with Us",
                      onTap: (){
                          Get.toNamed(
                              AppRoutes.serviceProviderInfo
                          );
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

// Logout Dialog
void _showLogoutDialog() {
  Get.dialog(
    AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: const CommonText(
        text: 'Log Out',
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      content: CommonText(
        text: 'Are you sure you want to log out?',
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
        maxLines: 2,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: CommonButton(
                titleText: 'No',
                buttonColor: AppColors.borderColor,
                titleColor: AppColors.black,
                borderColor: AppColors.borderColor,
                onTap: () => Get.back(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CommonButton(
                titleText: 'Yes',
                buttonColor: AppColors.red,
                borderColor: AppColors.red,
                titleColor: AppColors.white,
                onTap: () {
                  LocalStorage.removeAllPrefData();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Profile Item Model
class ProfileItemData {
  final String imageSrc;
  final String title;
  final VoidCallback onTap;

  ProfileItemData({
    required this.imageSrc,
    required this.title,
    required this.onTap,
  });
}
