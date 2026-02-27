import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/services/storage/storage_services.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';

enum FriendStatus { none, requested, friends }

class ChatNearbyProfileController extends GetxController {
  var isLoading = false.obs;
  var error = ''.obs;

  var userProfile = Rxn<Map<String, dynamic>>();

  var friendStatus = FriendStatus.none.obs;
  var pendingRequestId = ''.obs;

  Future<void> initProfile(String userId) async {
    await Future.wait([
      fetchUserProfile(userId),
      checkFriendship(userId),
    ]);
  }



  Future<void> sendGreeting(TextEditingController controller) async {
    try {
      isLoading.value = true;
      error.value = '';

      // ✅ Validate message is not empty
      if (controller.text.isEmpty) {
        Utils.errorSnackBar("Error", "Please enter a greeting message");
        isLoading.value = false;
        return;
      }

      // ✅ Validate user profile is loaded
      if (userProfile.value == null) {
        Utils.errorSnackBar("Error", "User profile not loaded yet. Please wait...");
        isLoading.value = false;
        return;
      }

      // ✅ Validate user ID exists (handle both 'id' and '_id' formats)
      final userId = userProfile.value?['id'] ?? userProfile.value?['_id'];
      if (userId == null || userId.toString().isEmpty) {
        debugPrint("User profile: ${userProfile.value}");
        Utils.errorSnackBar("Error", "User ID not found in profile");
        isLoading.value = false;
        return;
      }

      debugPrint("Sending greeting - User ID: $userId, Message: ${controller.text}");

      final response = await ApiService.post(
        ApiEndPoint.sendGreeting,
        body: {
          "user": userId,
          "text": controller.text
        },
      );

      if (response.statusCode == 200) {
        debugPrint("=========================${response.message}");
        Utils.successSnackBar("Success", "Greeting sent successfully");
        controller.clear();
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Failed to send greeting");
      }
    } catch (e) {
      debugPrint("Error sending greeting: $e");
      Utils.errorSnackBar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final lat = LocalStorage.lat.toDouble();
      final lng = LocalStorage.long.toDouble();

      final response = await ApiService.get(
        "${ApiEndPoint.getUserSingleProfileById +userId}?lat=$lat&lng=$lng",
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        userProfile.value = Map<String, dynamic>.from(data);

        if (data['isAlreadyFriend'] == true) {
          friendStatus.value = FriendStatus.friends;
        } else if (data['pendingFriendRequest'] != null) {
          friendStatus.value = FriendStatus.requested;
          pendingRequestId.value =
              data['pendingFriendRequest']['_id'] ?? '';
        } else {
          friendStatus.value = FriendStatus.none;
        }
      } else {
        error.value = response.message ?? "Failed to load user profile";
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint("Error fetching user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkFriendship(String userId) async {
    try {
      final response =
      await ApiService.get(ApiEndPoint.checkFriendStatus + userId);

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data['isAlreadyFriend'] == true) {
          friendStatus.value = FriendStatus.friends;
        } else if (data['pendingFriendRequest'] != null) {
          friendStatus.value = FriendStatus.requested;
          pendingRequestId.value =
              data['pendingFriendRequest']['_id'] ?? '';
        } else {
          friendStatus.value = FriendStatus.none;
        }
      }
    } catch (e) {
      debugPrint("Error checking friendship: $e");
    }
  }

  Future<void> addFriend(String userId) async {
    try {
      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": userId},
      );

      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.requested;
        Utils.successSnackBar(
            "Sent", "Friend request sent");

        // 🔄 Refresh friend requests in MyFriendController so badge updates on home screen
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
      } else {

        debugPrint(response.message);
        Utils.errorSnackBar("Error", response.message ?? "Failed to send request");
      }
    } catch (e) {
      debugPrint("Error adding friend: $e");
      Utils.errorSnackBar("Error", "Something went wrong");
    }
  }

  Future<void> cancelRequest(String userId) async {
    try {
      final idToUse =
      pendingRequestId.value.isNotEmpty ? pendingRequestId.value : userId;

      final response = await ApiService.patch(
        ApiEndPoint.cancelFriendRequest + idToUse,
        body: {"status": "cancelled"},
      );

      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.none;
        pendingRequestId.value = '';
        Utils.successSnackBar("Cancelled", "Request cancelled");
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Failed to cancel request");
      }
    } catch (e) {
      debugPrint("Error cancelling request: $e");
      Utils.errorSnackBar("Error", "Something went wrong");
    }
  }

  @override
  void onClose() {
    // ✅ Clean up when controller is disposed
    super.onClose();
  }
}