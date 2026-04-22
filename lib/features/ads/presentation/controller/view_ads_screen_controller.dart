import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../utils/app_utils.dart';
import '../../../dashboard/presentation/controller/dash_board_screen_controller.dart';
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
      final ApiResponseModel response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
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

      final ApiResponseModel response = await ApiService.delete(
        ApiEndPoint.deleteAdvertisementById + adsId,
      );

      // Close loading dialog
      Get.back();

      if (response.statusCode == 200) {
        // Instant update: Remove from local list first
        if (Get.isRegistered<HistoryAdsController>()) {
          final historyController = Get.find<HistoryAdsController>();
          historyController.allAds.removeWhere((element) => element.id == adsId);
          historyController.activeAds.removeWhere((element) => element.id == adsId);
          historyController.update();
          historyController.fetchAds();
        }
        
        // Update Dashboard list as well
        if (Get.isRegistered<DashBoardScreenController>()) {
          final dashboardController = Get.find<DashBoardScreenController>();
          dashboardController.activeAds.removeWhere((element) => element.id == adsId);
          dashboardController.update();
          dashboardController.fetchAdvertisementOverview(); // Refresh stats too
        }

        Get.back(); // Close ViewAdsScreen
        
        Utils.successSnackBar(
          "Success",
          "Ad deleted successfully",
        );
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