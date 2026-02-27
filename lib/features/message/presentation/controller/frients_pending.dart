import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

class PendingRequest {
  final String id;
  final String userId;
  final String status;

  PendingRequest({
    required this.id,
    required this.userId,
    required this.status,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class PendingRequestController extends GetxController {
  final String chatId = Get.arguments ?? '';

  final RxBool isLoading = false.obs;
  final RxList<PendingRequest> pendingRequests = <PendingRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    try {
      isLoading.value = true;

      final url = "${ApiEndPoint.getPendingRequest}$chatId";

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = response.data['data']['data'];
        pendingRequests.value =
            data.map((e) => PendingRequest.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load pending requests");
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateRequestStatus(
      PendingRequest request,
      String status,
      ) async {
    try {
      isLoading.value = true;

      final url =
          "${ApiEndPoint.baseUrl}/join-requests/update/${request.id}";

      final response = await ApiService.patch(
        url,
        body: {"status": status},
      );

      if (response.statusCode == 200) {
        pendingRequests.removeWhere((e) => e.id == request.id);

        Get.snackbar(
          status == "accepted" ? "Accepted" : "Rejected",
          "Request Accepted",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed");
    } finally {
      isLoading.value = false;
    }
  }

  void onAcceptRequest(PendingRequest request) {
    updateRequestStatus(request, "accepted");
  }

  void onRejectRequest(PendingRequest request) {
    updateRequestStatus(request, "rejected");
  }
}