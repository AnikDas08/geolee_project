import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';

class ChangePasswordController extends GetxController {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  ///  change password function

  Future<void> changePasswordRepo() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    update();
    try {
      final Map<String, String> body = {
        "currentPassword": currentPasswordController.text,
        "newPassword": newPasswordController.text,
        "confirmPassword": confirmPasswordController.text,
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
      isLoading = false;
      update();
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
