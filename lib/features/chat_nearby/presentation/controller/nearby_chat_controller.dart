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

  // ================= PAGINATION =================
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  RxBool isPaginationLoading = false.obs;

  bool get hasMoreData => _currentPage < _totalPages;

  @override
  void onInit() {
    super.onInit();
    getNearbyChat();
  }

  // ================= FETCH NEARBY CHAT =================
  Future<void> getNearbyChat({bool isRefresh = true}) async {
    try {
      // Reset pagination on refresh
      if (isRefresh) {
        _currentPage = 1;
        nearbyChatList.clear();
      }

      final double lat = LocalStorage.user.location.lat;
      final double lng = LocalStorage.user.location.long;

      if (lat == 0.0 || lng == 0.0) {
        nearbyChatError.value =
            "Location not available. Please enable location.";
        debugPrint("❌ Invalid coordinates - Lat: $lat, Lng: $lng");
        return;
      }

      final url =
          "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&page=$_currentPage&limit=20";

      debugPrint("🌐 Fetching Nearby Chat - URL: $url");
      debugPrint("📄 Page: $_currentPage");

      isRefresh
          ? isNearbyChatLoading.value = true
          : isPaginationLoading.value = true;
      nearbyChatError.value = '';

      final ApiResponseModel response = await ApiService.get(url);

      debugPrint("📦 Full Response: ${response.data}");
      debugPrint("✅ Status: ${response.statusCode}");

      if (response.isSuccess) {
        // ========== PARSE PAGINATION ==========
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages = pagination['totalPage'] ?? 1;
          _totalUsers = pagination['total'] ?? 0;
          debugPrint(
            "📊 Total Users: $_totalUsers | Total Pages: $_totalPages | Current Page: $_currentPage",
          );
        }

        // ========== PARSE DATA WITH PER-ITEM ERROR HANDLING ==========
        final rawList = response.data['data'];

        if (rawList == null) {
          nearbyChatError.value = "No data found";
          debugPrint("❌ Data is null in response");
          return;
        }

        final List data = rawList as List;
        debugPrint("📋 Raw list count: ${data.length}");

        final List<NearbyChatUserModel> parsedList = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final user = NearbyChatUserModel.fromJson(data[i]);
            parsedList.add(user);
            debugPrint(
              "✅ Parsed user [$i]: ${user.name} | Role: ${user.role} | Distance: ${user.distance}",
            );
          } catch (e) {
            // ✅ Skip broken items instead of stopping all parsing
            debugPrint("❌ Failed to parse user at index [$i]: $e");
            debugPrint("❌ Raw data: ${data[i]}");
          }
        }

        debugPrint(
          "✅ Successfully parsed: ${parsedList.length} / ${data.length} users",
        );

        // ========== ADD TO LIST ==========
        if (isRefresh) {
          nearbyChatList.value = parsedList;
        } else {
          nearbyChatList.addAll(parsedList);
        }

        debugPrint("📋 Total in list now: ${nearbyChatList.length}");
      } else {
        nearbyChatError.value = response.message ?? "Something went wrong";
        debugPrint("❌ API Error: ${response.message}");
      }
    } catch (e) {
      nearbyChatError.value = e.toString();
      debugPrint("❌ Nearby Chat Error: $e");
    } finally {
      isNearbyChatLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  // ================= LOAD MORE (PAGINATION) =================
  Future<void> loadMore() async {
    if (!hasMoreData || isPaginationLoading.value) return;
    _currentPage++;
    debugPrint("📄 Loading page: $_currentPage");
    await getNearbyChat(isRefresh: false);
  }
}
