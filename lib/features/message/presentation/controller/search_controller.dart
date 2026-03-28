import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/features/message/data/model/search_friend_model.dart';
import 'package:giolee78/utils/enum/enum.dart';
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
    getSearchFriend();
  }

  Future<void> getSearchFriend() async {
    try {
      isLoading.value = true;
      final double lat = LocalStorage.lat ?? 0.0;
      final double lng = LocalStorage.long ?? 0.0;

      final url = "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&limit=50";
      final ApiResponseModel response = await ApiService.get(url);

      if (response.isSuccess) {
        final List data = response.data['data'] ?? [];
        final List<SearchFriendUserModel> fetchedUsers = data.map((e) => SearchFriendUserModel.fromJson(e)).toList();

        searchFriendList.value = fetchedUsers;

        //====================================
        // Optimization: Removed redundant _checkFriendshipForAll() call.
        // The SearchFriendUserModel now parses the friend status directly from
        // the nearby search response, eliminating the need for extra API calls.
        //====================================
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //====================================
  // Optimization: Removed _checkFriendshipForAll.
  // This method used to loop through all search results and make a network call
  // for each user to check friendship status. This is now handled within the model
  // constructor using the 'isFriend' field from the primary search response.
  //====================================

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
      final query = searchQuery.value;
      final nameMatch = u.name.toLowerCase().contains(query);
      final emailMatch = u.email.toLowerCase().contains(query);
      final isNotFriend = u.friendStatus.value != FriendStatus.friends;
      return (nameMatch || emailMatch) && isNotFriend;
    }).toList();
  }
}