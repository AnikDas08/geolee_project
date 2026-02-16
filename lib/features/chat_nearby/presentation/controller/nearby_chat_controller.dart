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
  }

  Future<void> getNearbyChat() async {
    try {
      final url =
          "${ApiEndPoint.nearbyChat}?lat=23.78&lng=90.41&radius=5";

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