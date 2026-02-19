import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/component/other_widgets/item.dart';
import 'package:giolee78/component/pop_up/common_pop_menu.dart';
import 'package:giolee78/component/text/common_text.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/ads/presentation/screen/history_ads_screen.dart';
import 'package:giolee78/features/advertise/presentation/screen/provider_profile_view_screen.dart';
import 'package:giolee78/features/auth/change_password/presentation/screen/change_password_screen.dart';
import 'package:giolee78/features/profile/presentation/controller/profile_controller.dart';
import 'package:giolee78/features/profile/presentation/screen/help_support_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/privacy_policy_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/terms_of_services_screen.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/constants/app_icons.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/extensions/extension.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../advertise/presentation/controller/advertiser_edit_profile_controller.dart';
import '../../../advertise/presentation/controller/provider_profile_view_controller.dart';

class DashBoardProfile extends StatelessWidget {
  const DashBoardProfile({super.key});

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

              final  advEditProfileController=Get.put(AdvertiserEditProfileController());

              advEditProfileController.fetchAdvertiserProfile();

                print("===============================${LocalStorage.myRole}");
                print("===============================${LocalStorage.businessLicenceNumber}");

                Get.to(() => const ProviderProfileViewScreen());
              },
            ),
            ProfileItemData(
              imageSrc: AppIcons.edit,
              title: 'Change Password',
              onTap: () {
                Get.to(() => const ChangePasswordScreen());
              },
            ),
            if (LocalStorage.role == "advertise")
              ProfileItemData(
                imageSrc: AppIcons.edit,
                title: 'Ads History',
                onTap: () {
                  Get.to(() => const HistoryAdsScreen());
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
                  onTap: () {
                    controller.deleteAccount();
                  },
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
                      child: GetBuilder<ProviderProfileViewController>(
                        builder: (controller) {
                          return ClipOval(
                            child: controller.userImage.isNotEmpty
                                ? CommonImage(
                              imageSrc: ApiEndPoint.imageUrl + controller.businessLogo,
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

                    /// User Name here
                    CommonText(
                      text: LocalStorage.businessName,
                      fontWeight: FontWeight.w600,
                      top: 16,
                      bottom: 8.h,
                    ),
                    CommonText(
                      text:
                      LocalStorage.advertiserBio,
                      fontSize: 12,
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

                    /*if (LocalStorage.myRole != "advertiser")
                      CommonButton(
                        titleText: "Advertise with Us",
                        onTap: (){


                          if(controller.advToken.isEmpty){
                            Get.toNamed(
                                AppRoutes.serviceProviderInfo
                            );
                            print("My Role Is :===========================${LocalStorage.myRole.toString()}");
                          }else{
                            Get.toNamed(
                                AppRoutes.homeNav
                            );

                          }


                        },
                      ),*/

                    if (LocalStorage.role != "user")
                      CommonButton(
                        titleText: "Become a User",
                        onTap: () {
                          print("My Role Is :===========================${LocalStorage.role.toString()}");

                          successPopUps(
                            message:
                            'Your Role now User.',
                            onTap: () async{
                              await LocalStorage.setString(LocalStorageKeys.role, "user");
                              // LocalStorage.setString(
                              //LocalStorageKeys.myRole, LocalStorage.myRole=UserType.user.name,
                              //
                              // );

                              //LocalStorage.setRoles(LocalStorageKeys.myRole, LocalStorage.myRole='user');
                              print("My Role Is :===========================${LocalStorage.role.toString()}");
                              //appLog(LocalStorage.myRole.toString());

                              Get.offAllNamed(AppRoutes.homeNav);
                            },
                            buttonTitle: 'Go to HomeScreen',
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
      content: const CommonText(
        text: 'Are you sure you want to log out?',
        fontSize: 20,
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
