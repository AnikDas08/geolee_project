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

class SignInController extends GetxController {
  bool isLoading = false;

  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'ibrahimsparktech@gmail.com' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'password123' : "",
  );

  void onTapSkipButton() {}

  Future<void> signInUser(GlobalKey<FormState> formKey) async {
    if (isLoading) return;
    if (!formKey.currentState!.validate()) return;
    
    // Unfocus keyboard before starting navigation/loading
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
        LocalStorage.token = token;
        await Future.wait([
          LocalStorage.setString(LocalStorageKeys.token, token),
          LocalStorage.setBool(LocalStorageKeys.isLogIn, true),
          LocalStorage.setString(LocalStorageKeys.role, "user"),
        ]);
        LocalStorage.isLogIn = true;
        LocalStorage.getAllPrefData();
        await getUserData();

        // Sync FCM Token
        try {
          final fcmToken = await FirebaseNotificationService().getFCMToken();
          if (fcmToken != null && LocalStorage.userId.isNotEmpty) {
            await UserApiService.sendTokenToServer(
              userId: LocalStorage.userId,
              token: fcmToken,
            );
          }
        } catch (e) {
          debugPrint("Error syncing FCM token after login: $e");
        }

        SocketServices.connectToSocket();

        debugPrint(
          "My Token Is :===============💕💕💕 ${LocalStorage.token.toString()}",
        );
        
        // Use offAllNamed for successful login to clear auth stack
        Get.offAllNamed(AppRoutes.homeNav);
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

  Future<void> getUserData() async {
    isLoading = true;
    update();
    try {
      final response = await ApiService.get(
        ApiEndPoint.profile,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;
        LocalStorage.userId = data['data']?["_id"];
        LocalStorage.myImage = data['data']?["image"];
        LocalStorage.myName = data['data']?["name"];
        LocalStorage.myEmail = data['data']?["email"];
        LocalStorage.bio = data['data']?['bio'];
        LocalStorage.dateOfBirth = data['data']?['dob'];
        LocalStorage.gender = data['data']?['gender'];

        LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
        LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
        LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
        LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName);
        LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail);
      } else {
        // Get.snackbar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      // Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    // Note: Manual disposal of controllers linked to UI can cause "used after disposed" 
    // errors during transition animations. GetX handles cleanup, but we can clear them.
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
