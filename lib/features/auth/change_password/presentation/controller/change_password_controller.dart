import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';

class ChangePasswordController extends GetxController {
  bool isLoading = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  ///  change password function

  Future<void> changePasswordRepo() async {
    try {
      isLoading = true;
      update();
      final body = {
        "currentPassword": currentPasswordController.text.trim(),
        "newPassword": newPasswordController.text.trim(),
        "confirmPassword": confirmPasswordController.text.trim(),
      };

      final response = await ApiService.post(
        ApiEndPoint.changePassword,
        body: body,
      );

      if (response.statusCode == 200) {
        Get.snackbar('Password Changed !', response.message);
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Get.back();
      } else {
        Get.snackbar("Failed", response.message);
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  /// dispose Controller
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
