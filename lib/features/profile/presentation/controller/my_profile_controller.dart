import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';

import '../../data/model/user_profile_model.dart';

class MyProfileController extends GetxController {
  static MyProfileController get instance => Get.find<MyProfileController>();

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  // ================= NAVIGATION =================

  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void goBack() {
    Get.back();
  }

  // ================= API CALL =================

  Future<void> getUserData() async {
    if (LocalStorage.token.isEmpty) {
      return;
    }

    try {
      isLoading = true;
      update();
      final response = await ApiService.get(ApiEndPoint.profile);

      if (response.statusCode == 200) {
        LocalStorage.setUser = UserModel.fromJson(response.data['data'] ?? {});

        if (LocalStorage.user.id.isNotEmpty) return;
      } else {
        Get.snackbar(
          response.statusCode.toString(),
          response.message ?? "Something went wrong",
        );
      }
    } catch (e) {
      debugPrint("Faile To Load Profile${e.toString()}");
      // Get.snackbar("Error", "Failed to load profile");
    }

    isLoading = false;
    update();
  }
}
