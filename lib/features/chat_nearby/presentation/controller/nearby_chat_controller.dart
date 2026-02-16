import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/chat_nearby/data/nearby_friends_model.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';

class NearbyChatController extends GetxController {
  RxList<NearbyChatUserModel> nearbyChatList = <NearbyChatUserModel>[].obs;

  RxBool isNearbyChatLoading = false.obs;
  RxString nearbyChatError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getNearbyChat();

    debugPrint("Lat Long Is : ${LocalStorage.lat}${LocalStorage.long}");
  }

  Future<void> getNearbyChat() async {
    try {
      // Get coordinates from LocalStorage
      double lat = LocalStorage.lat ?? 0.0;
      double lng = LocalStorage.long ?? 0.0;

      // Validate coordinates
      if (lat == 0.0 || lng == 0.0) {
        nearbyChatError.value = "Location not available. Please enable location.";
        debugPrint("Invalid coordinates - Lat: $lat, Lng: $lng");
        return;
      }

      final url = "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&radius=5";

      debugPrint("Fetching Nearby Chat - URL: $url");

      isNearbyChatLoading.value = true;
      nearbyChatError.value = '';

      ApiResponseModel response = await ApiService.get(url);

      if (response.isSuccess) {
        final data = response.data['data'] as List;

        debugPrint("Nearby Chat data List Is: $data");

        nearbyChatList.value = data
            .map((e) => NearbyChatUserModel.fromJson(e))
            .toList();
      } else {
        nearbyChatError.value = response.message ?? "Something went wrong";
      }
    } catch (e) {
      nearbyChatError.value = e.toString();
      debugPrint("Nearby Chat Error: $e");
    } finally {
      isNearbyChatLoading.value = false;
    }
  }
}