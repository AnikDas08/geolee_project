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

class SignInController extends GetxController {
  /// Sign in Button Loading variable
  bool isLoading = false;

  /// email and password Controller here
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'ebrahimnazmul20032@gmail.com' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'password1234' : "",
  );

  /// Sign in Api call here

  Future<void> signInUser(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    // return;

    isLoading = true;
    update();
    try {
      final Map<String, String> body = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      final response = await ApiService.post(
        ApiEndPoint.signIn,
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;

        Get.snackbar(
          barBlur: 0.5,
            "Welcome Back","Logged In Successfully");
        await LocalStorage.setString(LocalStorageKeys.token, data["data"]['accessToken']);

        LocalStorage.isLogIn = true;

        await LocalStorage.setBool(
          LocalStorageKeys.isLogIn,
          LocalStorage.isLogIn,
        );
        await LocalStorage.setString(LocalStorageKeys.role, "user");
        LocalStorage.getAllPrefData();

        print("My Token Is :===========================💕💕💕💕💕💕 ${LocalStorage.token.toString()}");
        await getUserData();

        Get.toNamed(AppRoutes.homeNav);
        // Get.to(() => const HistoryAdsScreen());

        emailController.clear();
        passwordController.clear();
      } else {
        Get.snackbar(
          colorText: AppColors.white,
          backgroundColor: AppColors.red,
            'Invalid Credential', "${response.message}");
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
        LocalStorage.bio=data['data']?['bio'];
        LocalStorage.dateOfBirth=data['data']?['dob'];
        LocalStorage.gender=data['data']?['gender'];

        LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
        LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
        LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
        LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName);
        LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail);
      } else {
        Get.snackbar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
