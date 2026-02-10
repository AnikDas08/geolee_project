import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/auth/sign%20up/presentation/widget/success_profile.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../services/storage/storage_services.dart';
import '../../../../../utils/app_utils.dart';

class ForgetPasswordController extends GetxController {
  /// Loading for forget password
  bool isLoadingEmail = false;

  /// Loading for Verify OTP

  bool isLoadingVerify = false;

  /// Loading for Creating New Password
  bool isLoadingReset = false;

  /// this is ForgetPassword Token , need to verification
  String forgetPasswordToken = '';

  /// this is timer , help to resend OTP send time
  int start = 0;
  Timer? _timer;
  String time = "00:00";

  /// here all Text Editing Controller
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );

  /// create Forget Password Controller instance
  static ForgetPasswordController get instance =>
      Get.put(ForgetPasswordController());

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// start Time for check Resend OTP Time

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    start = 180; // Reset the start value
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        final minutes = (start ~/ 60).toString().padLeft(2, '0');
        final seconds = (start % 60).toString().padLeft(2, '0');

        time = "$minutes:$seconds";

        update();
      } else {
        _timer?.cancel();
      }
    });
  }

  /// Forget Password Api Call

  Future<void> forgotPasswordRepo() async {
    // Get.toNamed(AppRoutes.verifyEmail);
    // return;
    isLoadingEmail = true;
    update();
    try {
      Map<String, String> body = {"email": emailController.text};
      var response = await ApiService.post(
        ApiEndPoint.forgotPassword,
        body: body,
        header: {'Content-Type': "application/json"},
      );
      //
      if (response.statusCode == 200) {
        var data = response.data;
        Utils.successSnackBar(response.statusCode.toString(), response.message);
        Get.toNamed(AppRoutes.verifyEmail);
      } else {
        Utils.errorSnackBar(response.statusCode, response.message);
        Get.snackbar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      Get.snackbar("Error is =============================", e.toString());
    } finally {
      isLoadingEmail = false;
      update();
    }
  }

  /// Verify OTP Api Call

  Future<void> verifyOtpRepo() async {
    isLoadingVerify = true;
    update();

    try {
      final body = {
        "email": emailController.text.trim(),
        "oneTimeCode": int.parse(otpController.text.trim()),
      };

      final response = await ApiService.post(
        ApiEndPoint.verifyOtp,
        body: body,
      );

      final data = response.data;
      if (response.statusCode == 200 && data['success'] == true) {

        Get.offAllNamed(AppRoutes.createPassword);

       final String token = data['data']['resetToken'];
       forgetPasswordToken=token;
       LocalStorage.setString(LocalStorageKeys.forgotPasswordToken, LocalStorage.forgotPasswordToken=token);
        debugPrint("OTP VERIFIED → Navigating...");



      } else {
        Utils.errorSnackBar(
          "Error ${response.statusCode}",
          data['message'] ?? "OTP verification failed",
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingVerify = false;
      update();
    }
  }

  //
  /// Create New Password Api Call

  Future<void> resetPasswordRepo() async {

    print("====================================${forgetPasswordToken}");
    // successPopUps(
    //   message:
    //       "Your password has been successfully reset. You can now log in using your new password.",
    //   onTap: () {
    //     Get.offAllNamed(AppRoutes.signIn);
    //   },
    //   buttonTitle: "Login",
    // );
    // return;

    isLoadingReset = true;
    update();
    try {
      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": forgetPasswordToken,
      };

      Map<String, String> body = {
        "newPassword": passwordController.text,
        "confirmPassword": confirmPasswordController.text,
      };
      var response = await ApiService.post(
        ApiEndPoint.resetPassword,
        body: body,
        header: header,
      );

      if (response.statusCode == 200) {
        Utils.successSnackBar(response.message, response.message);
        SuccessProfileDialogHere.show(
          Get.context!,
          title:
              "Your password has been successfully reset. You can now log in using your new password.",
        );

        emailController.clear();
        otpController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        Get.offAllNamed(AppRoutes.signIn);
      } else {
        Get.snackbar(response.statusCode.toString(), response.message);
      }
      isLoadingReset = false;
      update();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingReset = false;
      update();
    }
  }
}
