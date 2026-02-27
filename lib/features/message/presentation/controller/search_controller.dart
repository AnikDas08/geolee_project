import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/features/message/data/model/search_friend_model.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';

class SearchFriendController extends GetxController {
  RxList<SearchFriendUserModel> searchFriendList = <SearchFriendUserModel>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // স্ক্রিনে ঢোকার সাথে সাথে ডাটা লোড হবে
    getSearchFriend();
  }

  Future<void> getSearchFriend() async {
    try {
      isLoading.value = true;
      final double lat = LocalStorage.lat ?? 0.0;
      final double lng = LocalStorage.long ?? 0.0;

      // ১. নিয়ারবাই ইউজার গেট করা
      final url = "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&limit=50";
      final ApiResponseModel response = await ApiService.get(url);

      if (response.isSuccess) {
        final List data = response.data['data'] ?? [];
        final List<SearchFriendUserModel> fetchedUsers = data.map((e) => SearchFriendUserModel.fromJson(e)).toList();

        searchFriendList.value = fetchedUsers;

        // ২. ইউজার লোড হওয়ার পর প্রত্যেকের ফ্রেন্ডশিপ স্ট্যাটাস চেক করা
        await _checkFriendshipForAll();
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkFriendshipForAll() async {
    for (var user in searchFriendList) {
      try {
        final res = await ApiService.get(ApiEndPoint.checkFriendStatus + user.id);
        if (res.statusCode == 200) {
          final statusData = res.data['data'];
          if (statusData['isAlreadyFriend'] == true) {
            user.friendStatus.value = FriendStatus.friends;
          } else if (statusData['pendingFriendRequest'] != null) {
            user.friendStatus.value = FriendStatus.requested;
            user.pendingRequestId.value = statusData['pendingFriendRequest']['_id'] ?? '';
          } else {
            user.friendStatus.value = FriendStatus.none;
          }
        }
      } catch (e) {
        user.friendStatus.value = FriendStatus.none;
      }
    }
    searchFriendList.refresh();
  }

  Future<void> addFriend(SearchFriendUserModel user) async {
    try {
      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": user.id},
      );

      if (response.statusCode == 200) {
        user.friendStatus.value = FriendStatus.requested;
        if (response.data['data'] != null) {
          user.pendingRequestId.value = response.data['data']['_id'] ?? '';
        }
        searchFriendList.refresh();
        Utils.successSnackBar("Success", "Friend request sent!");

        // 🔄 Refresh friend requests in MyFriendController so badge updates on home screen
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to send request");
    }
  }

  Future<void> cancelRequest(SearchFriendUserModel user) async {
    try {
      final String requestId = user.pendingRequestId.value;
      if (requestId.isEmpty) return;

      final response = await ApiService.patch(
        "${ApiEndPoint.cancelFriendRequest}$requestId",
        body: {"status": "cancelled"},
      );

      if (response.statusCode == 200) {
        user.friendStatus.value = FriendStatus.none;
        user.pendingRequestId.value = '';
        searchFriendList.refresh();
        Utils.successSnackBar("Cancelled", "Request removed");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to cancel");
    }
  }

  void onSearch(String query) {
    searchQuery.value = query.toLowerCase();
  }

  List<SearchFriendUserModel> get filteredUsers {
    return searchFriendList.where((u) {
      final nameMatch = u.name.toLowerCase().contains(searchQuery.value);
      // রিকোয়ারমেন্ট অনুযায়ী যারা অলরেডি ফ্রেন্ড তাদের লিস্টে দেখাবে না
      final isNotFriend = u.friendStatus.value != FriendStatus.friends;
      return nameMatch && isNotFriend;
    }).toList();
  }
}