import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:image_picker/image_picker.dart';

class GroupSettingsController extends GetxController {
  // Use RxString for image path, will be updated by image_picker
  final RxString? avatarFilePath = "".obs;
  final RxString groupName = 'Sports Club'.obs;
  final RxInt memberCount = 0.obs;
  final RxBool isLoading = false.obs;
  String chatId = '';

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  @override
  void onInit() {
    super.onInit();
    chatId = Get.arguments['chatId'] ?? '';
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    if (chatId.isEmpty) return;
    try {
      isLoading.value = true;
      final response = await ApiService.get("${ApiEndPoint.chatRoom}/$chatId");
      if (response.statusCode == 200) {
        final data = response.data['data'];
        groupName.value = data['chatName'] ?? 'Unnamed Group';
        memberCount.value = (data['participants'] as List?)?.length ?? 0;
      }
    } catch (e) {
      appLog("❌ Error fetching group details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Method to pick image from gallery ---
  Future<void> pickGroupImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      avatarFilePath!.value = pickedFile.path;
      Get.snackbar(
        'Success',
        'Group image selected!',
        snackPosition: SnackPosition.BOTTOM,
      );
      // In a real app, you would upload this file to a server here after picking.
    } else {
      Get.snackbar(
        'Info',
        'No image selected.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onUpdateGroupName(String newName) {
    if (newName.isNotEmpty) {
      groupName.value = newName;
      Get.snackbar(
        'Success',
        'Group name updated to $newName',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onAddMember() {
    Get.toNamed('/add-member', arguments: {'chatId': chatId});
  }

  void onPendingRequest() {
    Get.toNamed(AppRoutes.friendPendingScreenHere);
  }

  void onPrivacySettings() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void onLeaveGroup() {
    if (chatId.isEmpty) return;
    Get.defaultDialog(
      title: "Leave Group",
      middleText: "Are you sure you want to leave ${groupName.value}?",
      textConfirm: "Leave",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          final response = await ApiService.delete(
            ApiEndPoint.leaveChat(chatId),
          );
          if (response.statusCode == 200) {
            Get.offAllNamed(AppRoutes.homeNav); // Assuming home route
            Get.snackbar('Success', 'You have left the group');
          }
        } catch (e) {
          appLog("❌ Error leaving group: $e");
        }
      },
      onCancel: () => Get.back(),
    );
  }

  void onDeleteGroup() {
    if (chatId.isEmpty) return;
    Get.defaultDialog(
      title: "Delete Group",
      middleText: "Permanently DELETE ${groupName.value}?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        try {
          final response = await ApiService.delete(
            ApiEndPoint.deleteChatById(chatId),
          );
          if (response.statusCode == 200) {
            Get.offAllNamed(AppRoutes.homeNav);
            Get.snackbar('Deleted', 'Group has been permanently deleted');
          }
        } catch (e) {
          appLog("❌ Error deleting group: $e");
        }
      },
      onCancel: () => Get.back(),
    );
  }
}
