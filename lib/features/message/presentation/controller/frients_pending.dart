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
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return PendingRequest(
      id: json['_id'] ?? '',
      userId: user['_id'] ?? '',
      status: json['status'] ?? '',
      userName: user['name'] ?? 'Unknown',
      userImage: user['image'] ?? '',
    );
  }
}

class PendingRequestController extends GetxController {
  final String chatId = Get.arguments ?? '';

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasNoMoreData = false.obs;

  final RxList<PendingRequest> pendingRequests = <PendingRequest>[].obs;

  int page = 1;
  int limit = 10;

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

      debugPrint("📦 Status: ${response.statusCode}");
      debugPrint("📦 Full data: ${response.data}");

      if (response.statusCode == 200) {
        final dataWrapper = response.data['data'];
        debugPrint("📦 dataWrapper type: ${dataWrapper.runtimeType}");

        List rawList = [];
        int totalPage = 1;

        if (dataWrapper is Map) {
          rawList = dataWrapper['data'] ?? [];
          totalPage = dataWrapper['pagination']?['totalPage'] ?? 1;
        } else if (dataWrapper is List) {
          rawList = dataWrapper;
        }

        debugPrint("📦 rawList length: ${rawList.length}");

        final parsed = <PendingRequest>[];
        for (int i = 0; i < rawList.length; i++) {
          try {
            final item = PendingRequest.fromJson(rawList[i]);
            parsed.add(item);
            debugPrint("✅ [$i] name: ${item.userName} | id: ${item.userId}");
          } catch (e) {
            debugPrint("❌ Parse error [$i]: $e");
          }
        }

        pendingRequests.value = parsed;
        debugPrint("✅ Total in list: ${pendingRequests.length}");

        if (page >= totalPage) hasNoMoreData.value = true;
      }
    } catch (e) {
      debugPrint("❌ fetchPendingRequests error: $e");
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
        final dataWrapper = response.data['data'];
        List rawList = [];
        int totalPage = 1;

        if (dataWrapper is Map) {
          rawList = dataWrapper['data'] ?? [];
          totalPage = dataWrapper['pagination']?['totalPage'] ?? 1;
        } else if (dataWrapper is List) {
          rawList = dataWrapper;
        }

        if (rawList.isNotEmpty) {
          pendingRequests.addAll(
            rawList.map((e) => PendingRequest.fromJson(e)),
          );
        }

        if (page >= totalPage) hasNoMoreData.value = true;
      }
    } catch (e) {
      debugPrint("❌ fetchMorePendingRequests error: $e");
      Get.snackbar("Error", "Failed to load more pending requests");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> updateRequestStatus(
      PendingRequest request, String status) async {
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
      debugPrint("❌ updateRequestStatus error: $e");
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