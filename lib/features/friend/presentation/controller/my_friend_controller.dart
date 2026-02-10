import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/data/friend_request_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/repo/get_my_all_friend_repo.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../data/my_friends_model.dart';

class MyFriendController extends GetxController {
  final RxList<Map<String, dynamic>> suggestedFriends = <Map<String, dynamic>>[
    {'id': '1', 'name': 'Arlene McCoy', 'avatar': AppImages.profileImage},
    {'id': '2', 'name': 'Brooklyn Simmons', 'avatar': AppImages.profileImage},
  ].obs;

  // List to track friend request sent status
  final RxMap<String, bool> friendRequestSent = <String, bool>{}.obs;

  // List of current friends
  final RxList<Map<String, dynamic>> friendsList = <Map<String, dynamic>>[
    {'id': '3', 'name': 'Wade Warren', 'avatar': AppImages.profileImage},
    {'id': '4', 'name': 'Esther Howard', 'avatar': AppImages.profileImage},
    {'id': '5', 'name': 'Cameron Williamson', 'avatar': AppImages.profileImage},
    {'id': '6', 'name': 'Robert Fox', 'avatar': AppImages.profileImage},
  ].obs;

  var requests = <FriendData>[].obs;
  var isLoading = true.obs;

  // Send friend request
  void sendFriendRequest(String userId) {
    friendRequestSent[userId] = true;
  }

  @override
  void onInit() {
    super.onInit();
    fetchFriendRequests();
    getMyAllFriends();
  }

  RxList<MyFriendsData> myFriendsList = <MyFriendsData>[].obs;

  Future<void> getMyAllFriends() async {
    try {
      isLoading.value = true;

      myFriendsList.value = await GetMyAllFriendsRepo().getFriendList();
    } catch (e) {
      debugPrint("Exception in getMyAllFriends: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void removeFriend(String userId) {
    friendsList.removeWhere((friend) => friend['id'] == userId);
  }

  bool isRequestSent(String userId) {
    return friendRequestSent[userId] ?? false;
  }

  Future<void> acceptFriendRequest(String senderUserId, int index) async {
    try {
      final url = "${ApiEndPoint.friendStatusUpdate + senderUserId}";

      var response = await ApiService.patch(url, body: {"status": 'accepted'});

      if (response.statusCode == 200) {
        requests.removeAt(index);

        Get.snackbar(
          "Success",
          "Friend request accepted",
          colorText: Colors.white,
        );
      } else {
        debugPrint(
          "acceptFriendRequest error ==========================> ${response.data}",
        );
        debugPrint(
          "acceptFriendRequest error ==========================> ${response.message}",
        );
        Get.snackbar(
          "Info",
          response.data["message"] ?? "Cannot accept request",
        );
      }
    } catch (e) {
      debugPrint("acceptFriendRequest error => ${e.toString()}");
      Get.snackbar("Error", "Network error");
    }
  }

  Future<void> fetchFriendRequests() async {
    try {
      final url = "${ApiEndPoint.getMyFriendRequest}";
      isLoading.value = true;
      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        debugPrint(
          "response is =>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${response.data}",
        );

        final model = FriendModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        requests.value = model.data;
      } else {
        debugPrint(
          "response is =>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${response.data} ",
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectFriendRequest(String senderUserId, int index) async {
    try {
      final url = "${ApiEndPoint.friendStatusUpdate + senderUserId}";
      final response = await ApiService.patch(
        url,
        body: {"status": 'rejected'},
      );

      if (response.statusCode == 200) {
        requests.removeAt(index);
        Get.snackbar("Rejected", "Friend request rejected");
      } else {
        debugPrint(
          "acceptFriendRequest error ==========================> ${response.data}",
        );
        debugPrint(
          "acceptFriendRequest error ==========================> ${response.message}",
        );
        Get.snackbar("Rejected", "Friend request rejected");
        debugPrint(
          "Error  is =======================================${response.data}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Network error");
    }
  }
}
