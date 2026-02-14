import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/ads/data/add_history_model.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../data/single_ads_model.dart';
import 'history_ads_controller.dart';

class ViewAdsScreenController extends GetxController {
  late String adsId;
  SingleAdvertisement? ad;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    adsId = Get.arguments;
    fetchAdById();
  }

  Future<void> fetchAdById() async {
    isLoading = true;
    update();

    try {
      final endpoint = "${ApiEndPoint.getAdvertisementById}$adsId";
      ApiResponseModel response = await ApiService.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        ad = SingleAdvertisement.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching single ad: $e");
    }

    isLoading = false;
    update();
  }

  Future<void> deleteAdsById() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      ApiResponseModel response = await ApiService.delete(
        ApiEndPoint.deleteAdvertisementById + adsId,
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Ad deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // ✅ Refresh history list if controller exists
        if (Get.isRegistered<HistoryAdsController>()) {
          await Get.find<HistoryAdsController>().fetchAds();
          Get.find<HistoryAdsController>().update();
        }

        // ✅ Navigate back with result
        Get.back(result: true);
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to delete ad",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint("Delete Ads Error: $e");
      Get.snackbar(
        "Error",
        "Failed to delete ad: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}