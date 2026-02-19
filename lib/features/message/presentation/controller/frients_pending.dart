import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
    User(id: 'p1', name: 'Arlene McCoy', avatarUrl: 'https://placehold.co/40x40/FFD180/8D6E63?text=AM'),
    User(id: 'p2', name: 'Darrell Steward', avatarUrl: 'https://placehold.co/40x40/FFCCBC/BF360C?text=DS'),
    User(id: 'p3', name: 'Kathryn Murphy', avatarUrl: 'https://placehold.co/40x40/B3E5FC/0277BD?text=KM'),
    User(id: 'p4', name: 'Ralph Edwards', avatarUrl: 'https://placehold.co/40x40/C8E6C9/2E7D32?text=RE'),
    User(id: 'p5', name: 'Esther Howard', avatarUrl: 'https://placehold.co/40x40/FFF9C4/FFEB3B?text=EH'),
    User(id: 'p6', name: 'Guy Hawkins', avatarUrl: 'https://placehold.co/40x40/E1BEE7/8E24AA?text=GH'),
    User(id: 'p7', name: 'Annette Black', avatarUrl: 'https://placehold.co/40x40/CFD8DC/607D8B?text=AB'),
    User(id: 'p8', name: 'Cameron Williamson', avatarUrl: 'https://placehold.co/40x40/FFE0B2/EF6C00?text=CW'),
    User(id: 'p9', name: 'Jane Cooper', avatarUrl: 'https://placehold.co/40x40/F48FB1/AD1457?text=JC'),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    isLoading.value = true;
    // Simulate network delay
    await 1.seconds.delay();
    // Data is already initialized in the mock list
    isLoading.value = false;
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
        Get.snackbar('Accepted', '${user.name} is now a member!', snackPosition: SnackPosition.BOTTOM);
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
        Get.snackbar('Rejected', '${user.name}\'s request has been rejected.', snackPosition: SnackPosition.BOTTOM);
      },
      onCancel: () {
        Navigator.pop(Get.context!);
      },
    );
  }
}