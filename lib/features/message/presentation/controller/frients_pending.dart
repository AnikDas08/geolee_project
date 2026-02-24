import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

// Reusing the User model definition
class User {
  final String id;
  final String name;
  final String avatarUrl;

  User({required this.id, required this.name, required this.avatarUrl});
}

class PendingRequestController extends GetxController {
  final RxBool isLoading = false.obs;

  // Mock list of pending requests
  final RxList<User> pendingRequests = <User>[
    User(
      id: 'p1',
      name: 'Arlene McCoy',
      avatarUrl: 'https://placehold.co/40x40/FFD180/8D6E63?text=AM',
    ),
    User(
      id: 'p2',
      name: 'Darrell Steward',
      avatarUrl: 'https://placehold.co/40x40/FFCCBC/BF360C?text=DS',
    ),
    User(
      id: 'p3',
      name: 'Kathryn Murphy',
      avatarUrl: 'https://placehold.co/40x40/B3E5FC/0277BD?text=KM',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final url = ApiEndPoint.getPendingRequest;
      ApiResponseModel response = await ApiService.get(url);

      if (response.statusCode == 200) {
        debugPrint(response.data.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
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
      onConfirm: () {
        // Implement API call to accept request
        pendingRequests.removeWhere((p) => p.id == user.id);
        Navigator.pop(Get.context!);
        Get.snackbar(
          'Accepted',
          '${user.name} is now a member!',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onCancel: () {
        Navigator.pop(Get.context!);
      },
    );
  }

  void onRejectRequest(User user) {
    Get.defaultDialog(
      title: "Reject Request",
      middleText: "Are you sure you want to reject ${user.name}'s request?",
      textConfirm: "Reject",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        // Implement API call to reject request
        pendingRequests.removeWhere((p) => p.id == user.id);
        Navigator.pop(Get.context!);
        Get.snackbar(
          'Rejected',
          '${user.name}\'s request has been rejected.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onCancel: () {
        Navigator.pop(Get.context!);
      },
    );
  }
}
