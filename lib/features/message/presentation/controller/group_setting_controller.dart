import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:image_picker/image_picker.dart'; // Required for image picking
// Required for File

class GroupSettingsController extends GetxController {
  // Use RxString for image path, will be updated by image_picker
  final RxString? avatarFilePath="".obs;
  final RxString groupName = 'Sports Club'.obs;
  final RxInt memberCount = 50.obs;
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  @override
  void onInit() {
    super.onInit();
    fetchGroupDetails();
  }

  void fetchGroupDetails() async {
    isLoading.value = true;
    // Simulate network delay
    await 2.seconds.delay();

    // Assume data is fetched
    groupName.value = 'Sports Club';
    memberCount.value = 50;
    // Note: avatarFilePath remains null until an image is picked or a remote URL is fetched.

    isLoading.value = false;
  }

  // --- Method to pick image from gallery ---
  Future<void> pickGroupImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      avatarFilePath!.value = pickedFile.path;
      Get.snackbar('Success', 'Group image selected!', snackPosition: SnackPosition.BOTTOM);
      // In a real app, you would upload this file to a server here after picking.
    } else {
      Get.snackbar('Info', 'No image selected.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void onUpdateGroupName(String newName) {
    if (newName.isNotEmpty) {
      groupName.value = newName;
      Get.snackbar('Success', 'Group name updated to $newName', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void onAddMember() {
    Get.toNamed('/add-member');
  }

  void onPendingRequest() {
    Get.toNamed(AppRoutes.friendPendingScreenHere);
  }

  void onPrivacySettings() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void onLeaveGroup() {
    Get.defaultDialog(
      title: "Leave Group",
      middleText: "Are you sure you want to leave ${groupName.value}?",
      textConfirm: "Leave",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        // Close dialog and navigate back from settings screen
        Navigator.pop(Get.context!);
        Get.snackbar('Left', 'You have left ${groupName.value}.', snackPosition: SnackPosition.BOTTOM);
      },
       onCancel: () {
        Navigator.pop(Get.context!);
      },
    );
  }

  void onDeleteGroup() {
    Get.defaultDialog(
      title: "Delete Group",
      middleText: "Are you absolutely sure you want to DELETE ${groupName.value}? This action is irreversible.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () {
        Navigator.pop(Get.context!);
        Get.snackbar('Deleted', '${groupName.value} has been permanently deleted.', snackPosition: SnackPosition.BOTTOM);
      },
      onCancel: () {
        Navigator.pop(Get.context!);
      },
    );
  }
}