import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

class User {
  final String id;
  final String name;
  final String avatarUrl;

  User({required this.id, required this.name, required this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}

class PendingRequestController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<User> pendingRequests = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingRequests();
  }

  /// Fetch pending requests from server
  Future<void> fetchPendingRequests() async {
    try {
      isLoading.value = true;
      final url = ApiEndPoint.getPendingRequest; // ex: {{BASE_URL}}/join-requests/
      final ApiResponseModel response = await ApiService.get(url);

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List data = response.data['data'];
        pendingRequests.value = data.map((e) => User.fromJson(e)).toList();
        debugPrint("✅ Pending Requests Loaded: ${pendingRequests.length}");
      } else {
        debugPrint("❌ Failed to load pending requests");
      }
    } catch (e) {
      debugPrint("❌ Error fetching pending requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update join request status
  Future<void> updateRequestStatus(User user, String status) async {
    try {
      final url = "${ApiEndPoint.baseUrl}/join-requests/update/${user.id}";
      final body = {"status": status}; // accepted | rejected | cancelled
      isLoading.value = true;

      final ApiResponseModel response = await ApiService.patch(
        url,
        body: body,
      );

      if (response.statusCode == 200) {
        pendingRequests.removeWhere((p) => p.id == user.id);
        Get.snackbar(
          status == "accepted" ? "Accepted" : "Rejected",
          "${user.name} request has been ${status}!",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar("Error", "Failed to update request status");
      }
    } catch (e) {
      debugPrint("❌ Error updating request: $e");
      Get.snackbar("Error", "Error updating request: $e");
    } finally {
      isLoading.value = false;
    }
  }


  void onAcceptRequest(User user) {
    Get.defaultDialog(
      title: "Accept Request",
      middleText: "Are you sure you want to accept ${user.name}?",
      textConfirm: "Accept",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () async {
        await updateRequestStatus(user, "accepted");
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  /// Reject request
  void onRejectRequest(User user) {
    Get.defaultDialog(
      title: "Reject Request",
      middleText: "Are you sure you want to reject ${user.name}'s request?",
      textConfirm: "Reject",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await updateRequestStatus(user, "rejected");
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }
}