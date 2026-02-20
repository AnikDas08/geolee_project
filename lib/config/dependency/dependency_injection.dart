import 'package:get/get.dart';
import 'package:giolee78/features/addpost/presentation/controller/post_controller.dart';
import 'package:giolee78/features/clicker/presentation/controller/clicker_controller.dart';
import 'package:giolee78/features/home/presentation/controller/create_post_controller.dart';
import 'package:giolee78/features/home/presentation/controller/first_message_controller.dart';
import 'package:giolee78/features/home/presentation/controller/home_controller.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/edit_post_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/edit_service_provider_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/post_controller.dart';
import 'package:giolee78/features/advertise/presentation/controller/provider_complete_profile_controller.dart';
import '../../features/ads/presentation/controller/update_ads_controller.dart';
import '../../features/ads/presentation/controller/view_ads_screen_controller.dart';
import '../../features/advertise/presentation/controller/advertiser_edit_profile_controller.dart';
import '../../features/advertise/presentation/controller/provider_profile_view_controller.dart';
import '../../features/auth/change_password/presentation/controller/change_password_controller.dart';
import '../../features/auth/forgot password/presentation/controller/forget_password_controller.dart';
import '../../features/auth/sign in/presentation/controller/sign_in_controller.dart';
import '../../features/auth/sign up/presentation/controller/sign_up_controller.dart';
import '../../features/dashboard/presentation/controller/dash_board_screen_controller.dart';
import '../../features/message/presentation/controller/chat_controller.dart';
import '../../features/message/presentation/controller/message_controller.dart';
import '../../features/notifications/presentation/controller/notifications_controller.dart';
import '../../features/profile/presentation/controller/my_profile_controller.dart';
import '../../features/profile/presentation/controller/profile_controller.dart';
import '../../features/profile/presentation/controller/privacy_policy_controller.dart';
import '../../features/profile/presentation/controller/terms_of_services_controller.dart';

class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => SignInController(), fenix: true);
    Get.lazyPut(() => ForgetPasswordController(), fenix: true);
    Get.lazyPut(() => ChangePasswordController(), fenix: true);
    Get.lazyPut(() => NotificationsController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => MessageController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => MyProfileController(), fenix: true);
    Get.lazyPut(() => PrivacyPolicyController(), fenix: true);
    Get.lazyPut(() => TermsOfServicesController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => MyPostController(), fenix: true);
    Get.lazyPut(() => EditPostController(), fenix: true);
    Get.lazyPut(() => EditProfileController(), fenix: true);
    Get.lazyPut(() => ServiceProviderController(), fenix: true);
    Get.lazyPut(() => CreatePostController(), fenix: true);
    Get.lazyPut(() => FirstMessageController(), fenix: true);
    Get.lazyPut(() => PostController(), fenix: true);
    Get.lazyPut(() => ClickerController(), fenix: true);
    Get.lazyPut(() => HomeNavController(), fenix: true);
    Get.lazyPut(() => MyPostController(), fenix: true);
    Get.lazyPut(() => AdvertiserEditProfileController(), fenix: true);
    Get.lazyPut(() => ProviderProfileViewController(), fenix: true);
    Get.lazyPut(() => DashBoardScreenController(), fenix: true);
    Get.lazyPut(() => ViewAdsScreenController(), fenix: true);
    Get.lazyPut(() => UpdateAdsController(), fenix: true);

  }
}
