import 'package:get/get.dart';
import 'package:giolee78/features/home/presentation/screen/home_nav_screen.dart';
import 'package:giolee78/features/home/presentation/screen/home_screen.dart';
import 'package:giolee78/features/addpost/presentation/screen/my_post_screen.dart';
import 'package:giolee78/features/notifications/presentation/screen/stripe_web_view_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/edit_post_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/edit_service_provider_profile.dart';
import 'package:giolee78/features/profile/presentation/screen/privacy_policy_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/provider_info_screen.dart';
import 'package:giolee78/features/profile/presentation/screen/terms_of_services_screen.dart';
import '../../features/auth/change_password/presentation/screen/change_password_screen.dart';
import '../../features/auth/forgot password/presentation/screen/create_password.dart';
import '../../features/auth/forgot password/presentation/screen/forgot_password.dart';
import '../../features/auth/forgot password/presentation/screen/verify_screen.dart';
import '../../features/auth/sign in/presentation/screen/sign_in_screen.dart';
import '../../features/auth/sign up/presentation/screen/sign_up_screen.dart';
import '../../features/auth/sign up/presentation/screen/complete_profile.dart';
import '../../features/auth/sign up/presentation/screen/verify_user.dart';
import '../../features/auth/sign up/presentation/screen/add_location.dart';
import '../../features/message/presentation/screen/chat_screen.dart';
import '../../features/message/presentation/screen/message_screen.dart';
import '../../features/notifications/presentation/screen/notifications_screen.dart';
import '../../features/onboarding_screen/onboarding_screen.dart';
import '../../features/profile/presentation/screen/edit_profile.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  static const String test = "/test_screen.dart";
  static const String splash = "/splash_screen.dart";
  static const String onboarding = "/onboarding_screen.dart";
  static const String signUp = "/sign_up_screen.dart";
  static const String verifyUser = "/verify_user.dart";
  static const String completeProfile = "/complete_profile.dart";
  static const String addLocation = "/add_location.dart";
  static const String signIn = "/sign_in_screen.dart";
  static const String forgotPassword = "/forgot_password.dart";
  static const String verifyEmail = "/verify_screen.dart";
  static const String createPassword = "/create_password.dart";
  static const String changePassword = "/change_password_screen.dart";
  static const String notifications = "/notifications_screen.dart";
  static const String chat = "/chat_screen.dart";
  static const String message = "/message_screen.dart";
  static const String profile = "/profile_screen.dart";
  static const String editProfile = "/edit_profile.dart";
  static const String privacyPolicy = "/privacy_policy_screen.dart";
  static const String termsOfServices = "/terms_of_services_screen.dart";
  static const String setting = "/setting_screen.dart";
  static const String homeNav = "/homeNav";
  static const String homeScreen = "/homeScreen";
  static const String historyScreen = "/historyScreen";
  static const String createPost = "/createPost";
  static const String history = "/history_screen.dart";
  static const String historyDetailsScreen = "/history_details_screen.dart";
  static const String customOffer = "/customOffer";
  static const String myPostScreen = "/myPostScreen";
  static const String firstMessageScreen = "/firstMessageScreen";
  static const String viewMessageScreen = "/viewMessageScreen";
  static const String reviewScreen = "/reviewScreen";
  static const String completeHistoryScreen = "/completeHistoryScreen";
  static const String serviceProviderInfo = "/serviceProviderInfo";
  static const String myProfile = "/my_profile_screen.dart";
  static const String editProfileScreen = "/editProfileScreen";
  static const String editPost = "/editPost";
  static const String stripeWebViewScreen = "/stripeWebViewScreen";

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: signUp, page: () => SignUpScreen()),
    GetPage(name: verifyUser, page: () => const VerifyUser()),
    GetPage(name: completeProfile, page: () => const CompleteProfile()),
    GetPage(name: addLocation, page: () => const AddLocation()),
    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: verifyEmail, page: () => const VerifyScreen()),
    GetPage(name: createPassword, page: () => CreatePassword()),
    GetPage(name: changePassword, page: () => ChangePasswordScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
    GetPage(name: chat, page: () => const ChatListScreen()),
    GetPage(name: message, page: () => const MessageScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: editProfile, page: () => EditProfile()),
    GetPage(name: privacyPolicy, page: () => const PrivacyPolicyScreen()),
    GetPage(name: termsOfServices, page: () => const TermsOfServicesScreen()),
    GetPage(name: homeNav, page: () => HomeNav()),
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: myPostScreen, page: () => MyPostScreen()),
    GetPage(name: serviceProviderInfo, page: () => ServiceProviderInfoScreen()),
    GetPage(name: editProfileScreen, page: () => EditProfileScreen()),
    GetPage(name: editPost, page: () => EditPostScreen()),
    GetPage(
      name: stripeWebViewScreen,
      page: () => StripeWebViewPage(checkoutUrl: Get.arguments),
    ),
  ];
}
