import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../services/storage/storage_services.dart';
import '../../../../../services/socket/socket_service.dart';
import '../../../../../services/notification/firebase_notification_service.dart';
import '../../../../../services/api/user_api_service.dart';
import '../../../../../services/auth/auth_service.dart';

class SignInController extends GetxController {
  bool isLoading = false;

  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'ibrahimsparktech@gmail.com' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'password123' : "",
  );

  void onTapSkipButton() {}

  /// Unified success handling after login (Email, Google, Apple)
  Future<void> handleAuthSuccess({
    required String accessToken,
    required dynamic userData,
  }) async {
    final userId = userData['_id'] ?? '';
    final name = userData['name'];
    final email = userData['email'];
    final image = userData['image'];

    // Save common data
    await LocalStorage.saveUserData(
      token: accessToken,
      userId: userId,
      name: name,
      email: email,
      image: image,
      userRole: "user",
    );

    // Sync other profile fields locally
    LocalStorage.bio = userData['bio'] ?? '';
    LocalStorage.dateOfBirth = userData['dob'] ?? '';
    LocalStorage.gender = userData['gender'] ?? '';

    LocalStorage.getAllPrefData();

    // Sync FCM Token
    try {
      final fcmToken = await FirebaseNotificationService().getFCMToken();
      if (fcmToken != null && userId.isNotEmpty) {
        await UserApiService.sendTokenToServer(userId: userId, token: fcmToken);
        await LocalStorage.setString(LocalStorageKeys.fcmToken, fcmToken);
      }
    } catch (e) {
      debugPrint("Error syncing FCM token after login: $e");
    }

    SocketServices.connectToSocket();

    debugPrint("Auth Success! Token: ${LocalStorage.token}");

    // Navigate home
    Get.offAllNamed(AppRoutes.homeNav);
  }

  Future<void> signInUser(GlobalKey<FormState> formKey) async {
    if (isLoading) return;
    if (!formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading = true;
    update();
    try {
      final Map<String, String> body = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final response = await ApiService.post(
        ApiEndPoint.signIn,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data["data"]?['accessToken'] ?? '';
        final userData =
            data["data"]?['user'] ??
            data["data"]; // Adjust based on API structure

        await handleAuthSuccess(accessToken: token, userData: userData);
      } else {
        Get.snackbar(
          colorText: AppColors.white,
          backgroundColor: AppColors.red,
          'Invalid Credential',
          "${response.message}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Social Sign-In==================================================

  Future<void> socialLogin({
    required String provider,
  }) async {
    if (isLoading) return;

    isLoading = true;
    update();

    try {
      Map<String, dynamic>? authData;

      /// Detect provider
      if (provider == "google") {
        authData = await AuthService.signInWithGoogle();
      } else if (provider == "apple") {
        authData = await AuthService.signInWithApple();
      } else {
        throw Exception("Unsupported provider");
      }

      if (authData == null) {
        isLoading = false;
        update();
        return;
      }

      final UserCredential userCredential = authData["userCredential"];
      final String idToken = authData["idToken"];
      final user = userCredential.user;

      final body = {
        "provider": provider,
        "providerUserId": idToken,
        "name": user?.displayName ?? "",
        "email": user?.email ?? "",
      };

      final response = await ApiService.post(
        ApiEndPoint.socialLogin,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token = data["data"]?['accessToken'] ?? '';
        final userData =
            data["data"]?['user'] ??
                data["data"]; // Adjust based on API structure

        await handleAuthSuccess(accessToken: token, userData: userData);



        /// Fetch profile + save + navigate
        await getUserData();

        // Get.snackbar(
        //   "Success",
        //   "$provider Sign-In successful",
        //   backgroundColor: AppColors.primaryColor,
        //   colorText: Colors.white,
        // );

        Get.offAllNamed(AppRoutes.homeNav);
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "$provider login failed",
        );
      }
    } catch (e) {
      debugPrint("$provider Sign-In Error: $e");

      Get.snackbar(
        "Error",
        "$provider Sign-In failed: $e",
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getUserData() async {
    // This might be redundant if we use handleAuthSuccess, but keeping it for completeness
    isLoading = true;
    update();
    try {
      final response = await ApiService.get(
        ApiEndPoint.profile,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await LocalStorage.saveUserData(
          token: LocalStorage.token,
          userId: data["_id"],
          name: data["name"],
          email: data["email"],
          image: data["image"],
        );
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
