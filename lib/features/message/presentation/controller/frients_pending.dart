import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';

class PendingRequest {
  final String id;
  final String userId;
  final String status;
  final String userName;
  final String userImage;

  PendingRequest({
    required this.id,
    required this.userId,
    required this.status,
    required this.userName,
    required this.userImage,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      status: json['status'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      userImage: json['userImage'] ?? '',
    );
  }
}

class PendingRequestController extends GetxController {
  final String chatId = Get.arguments ?? '';

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasNoMoreData = false.obs;

  final RxList<PendingRequest> pendingRequests = <PendingRequest>[].obs;

  int page = 1; // প্রথম page
  int limit = 10; // API অনুযায়ী

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchPendingRequests();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      fetchMorePendingRequests();
    }
  }

  Future<void> fetchPendingRequests() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final url =
          "${ApiEndPoint.getPendingRequest}$chatId?page=$page&limit=$limit";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = response.data['data']['data'];
        final totalPage = response.data['data']['pagination']['totalPage'] ?? 1;

        pendingRequests.value =
            data.map((e) => PendingRequest.fromJson(e)).toList();

        // যদি এক page-এ data না থাকে
        if (page >= totalPage) hasNoMoreData.value = true;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load pending requests");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMorePendingRequests() async {
    if (isLoadingMore.value || hasNoMoreData.value) return;

    page++;
    isLoadingMore.value = true;

    try {
      final url =
          "${ApiEndPoint.getPendingRequest}$chatId?page=$page&limit=$limit";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final List data = response.data['data']['data'];
        final totalPage = response.data['data']['pagination']['totalPage'] ?? 1;

        if (data.isNotEmpty) {
          pendingRequests.addAll(data.map((e) => PendingRequest.fromJson(e)));
        }

        if (page >= totalPage) hasNoMoreData.value = true;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load more pending requests");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> updateRequestStatus(PendingRequest request, String status) async {
    try {
      isLoading.value = true;

      final url = "${ApiEndPoint.baseUrl}/join-requests/update/${request.id}";
      final response = await ApiService.patch(
        url,
        body: {"status": status},
      );

      if (response.statusCode == 200) {
        pendingRequests.removeWhere((e) => e.id == request.id);
        Get.snackbar(
          status == "accepted" ? "Accepted" : "Rejected",
          "Request ${status.capitalizeFirst}",
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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}