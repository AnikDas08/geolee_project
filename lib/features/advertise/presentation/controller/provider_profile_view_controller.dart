import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/advertise/presentation/screen/advertiser_edit_profile_screen.dart';
import 'package:giolee78/features/profile/data/model/user_profile_model.dart';
import 'package:giolee78/services/api/api_service.dart';

class ProviderProfileViewController extends GetxController {
  bool isLoading = false;
  UserModel? profileModel;

  String localAddress = '';

  // ================= LIFE CYCLE =================

  @override
  void onInit() {
    super.onInit();
    getAdvertiserData();
  }

  // ================= NAVIGATION =================

  void navigateToEditProfile() {
    Get.to(const AdvertiserEditProfileScreen());
  }

  void goBack() {
    Get.back();
  }

  // ================= API CALL =================

  Future<void> getAdvertiserData() async {
    isLoading = true;
    update();

    try {
      final response = await ApiService.get(ApiEndPoint.advertiserProfile);

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = response.data as Map<String, dynamic>;
        final advertiser = res['data'];

        if (advertiser == null) {
          debugPrint("❌ Advertiser data is null");
          return;
        }

        final user = advertiser['user'];

        if (user == null) {
          debugPrint("❌ User data is null");
          return;
        }
      }
    } catch (e) {
      debugPrint("❌ Failed To Load Profile: $e");
    }

    isLoading = false;
    update();
  }
}
