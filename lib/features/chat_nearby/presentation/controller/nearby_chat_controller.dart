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
  RxMap<String, bool> friendStatusMap = <String, bool>{}.obs; // ✅ NEW

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  RxBool isPaginationLoading = false.obs;
  bool get hasMoreData => _currentPage < _totalPages;

  @override
  void onInit() {
    super.onInit();
    debugPrint("📍 Lat: ${LocalStorage.lat} | Long: ${LocalStorage.long}");
    getNearbyChat();
    updateProfileAndLocationVisible();
  }

  Future<void> updateProfileAndLocationVisible() async {
    try {
      final latitude = LocalStorage.lat.toDouble();
      final longitude = LocalStorage.long.toDouble();

      final response = await ApiService.patch(
        ApiEndPoint.updateProfile,
        body: {
          'isLocationVisible': true,
          "location": [longitude, latitude],
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Profile location updated');
      } else {
        debugPrint('Failed to update profile: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> checkAllFriendships() async {
    for (var user in nearbyChatList) {
      try {
        final response = await ApiService.get(
          "${ApiEndPoint.baseUrl}/friendships/check/${user.id}",
        );
        if (response.statusCode == 200) {
          friendStatusMap[user.id] =
              response.data['data']['isAlreadyFriend'] ?? false;
        } else {
          friendStatusMap[user.id] = false;
        }
      } catch (e) {
        friendStatusMap[user.id] = false;
        debugPrint("❌ Friendship check failed for ${user.id}: $e");
      }
    }
  }

  Future<void> getNearbyChat({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        nearbyChatList.clear();
        friendStatusMap.clear(); // ✅ Clear on refresh
      }

      final double lat = LocalStorage.lat ?? 0.0;
      final double lng = LocalStorage.long ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        nearbyChatError.value =
        "Location not available. Please enable location.";
        return;
      }

      final url =
          "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&page=$_currentPage&limit=20";

      isRefresh
          ? isNearbyChatLoading.value = true
          : isPaginationLoading.value = true;
      nearbyChatError.value = '';

      final ApiResponseModel response = await ApiService.get(url);

      if (response.isSuccess) {
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages = pagination['totalPage'] ?? 1;
          _totalUsers = pagination['total'] ?? 0;
        }

        final rawList = response.data['data'];
        if (rawList == null) {
          nearbyChatError.value = "No data found";
          return;
        }

        final List data = rawList as List;
        final List<NearbyChatUserModel> parsedList = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final user = NearbyChatUserModel.fromJson(data[i]);
            parsedList.add(user);
          } catch (e) {
            debugPrint("❌ Failed to parse user at index [$i]: $e");
          }
        }

        if (isRefresh) {
          nearbyChatList.value = parsedList;
        } else {
          nearbyChatList.addAll(parsedList);
        }

        await checkAllFriendships();

      } else {
        nearbyChatError.value = response.message ?? "Something went wrong";
      }
    } catch (e) {
      nearbyChatError.value = e.toString();
      debugPrint("❌ Nearby Chat Error: $e");
    } finally {
      isNearbyChatLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData || isPaginationLoading.value) return;
    _currentPage++;
    await getNearbyChat(isRefresh: false);
  }
}