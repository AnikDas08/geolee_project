import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:flutter/material.dart';

class GroupSettingsController extends GetxController {
  final RxString avatarFilePath = "".obs;
  final RxString groupName = 'Loading...'.obs;
  final RxString description = ''.obs;
  final RxString privacy = 'public'.obs;
  final RxString accessType = 'open'.obs;
  final RxInt memberCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  String chatId = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    // Delay to ensure arguments are available from navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeFromArguments();
    });
  }

  void _initializeFromArguments() {
    try {
      final dynamic args = Get.arguments;
      appLog("📥 GroupSettings received args: $args");

      if (args is Map) {
        chatId = args['chatId'] ?? '';
      } else if (args is String) {
        chatId = args;
      }

      appLog("📌 Chat ID extracted: $chatId");

      if (chatId.isNotEmpty) {
        fetchGroupDetails();
      } else {
        appLog("⚠️ Warning: chatId is empty");
      }
    } catch (e) {
      appLog("❌ Error initializing from arguments: $e");
    }
  }

  // ─── Fetch Group Details ─────────────────────────
  Future<void> fetchGroupDetails() async {
    if (chatId.isEmpty) {
      appLog("⚠️ Cannot fetch group details: chatId is empty");
      return;
    }
    try {
      isLoading.value = true;
      update();

      // Correct endpoint that works
      final url = "${ApiEndPoint.baseUrl}/chats/single/$chatId";
      appLog("📡 Fetching group details from: $url");

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        groupName.value = data['chatName'] ?? 'Unnamed Group';
        description.value = data['description'] ?? '';
        privacy.value = data['privacy'] ?? 'public';
        accessType.value = data['accessType'] ?? 'open';
        memberCount.value = (data['participants'] as List?)?.length ?? 0;

        // API uses 'avatarUrl' not 'image'
        if (data['avatarUrl'] != null && data['avatarUrl'].isNotEmpty) {
          avatarFilePath.value = data['avatarUrl'];
          appLog("✅ Avatar loaded: ${data['avatarUrl']}");
        }

        appLog("✅ Group details loaded: ${groupName.value}");
      } else {
        appLog("❌ Failed to fetch group: ${response.statusCode}");
        Get.snackbar('Error', 'Failed to load group details');
      }
    } catch (e) {
      appLog("❌ Error fetching group details: $e");
      Get.snackbar('Error', 'Error loading group details');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ─── Update Group ─────────────────────────────
  Future<void> updateGroupProfile({
    String? newName,
    String? newDescription,
    String? newPrivacy,
    String? newAccessType,
    XFile? imageFile,
  }) async {
    if (chatId.isEmpty) {
      appLog("⚠️ Cannot update: chatId is empty");
      return;
    }
    try {
      isSaving.value = true;
      final String endpoint = ApiEndPoint.updateChatById(chatId);
      final Map<String, String> body = {};

      if (newName != null && newName.isNotEmpty) body['chatName'] = newName;
      if (newDescription != null && newDescription.isNotEmpty)
        body['description'] = newDescription;
      if (newPrivacy != null) body['privacy'] = newPrivacy;
      if (newAccessType != null) body['accessType'] = newAccessType;

      appLog("📡 Updating group with endpoint: $endpoint");

      final response = await ApiService.multipartUpdate(
        endpoint,
        method: 'PATCH',
        body: body,
        imageName: 'image',
        imagePath: imageFile?.path,
      );

      if (response.statusCode == 200) {
        appLog("✅ Group updated successfully");
        await fetchGroupDetails();
        Get.snackbar('Success', 'Group updated successfully!');
      } else {
        appLog("❌ Failed to update group: ${response.statusCode}");
        Get.snackbar('Error', 'Failed to update group');
      }
    } catch (e) {
      appLog("❌ Error updating group: $e");
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onUpdateGroupName(String newName) async {
    if (newName.isEmpty) {
      Get.snackbar('Error', 'Group name cannot be empty');
      return;
    }
    await updateGroupProfile(newName: newName);
  }

  Future<void> pickGroupImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        appLog("📸 Image picked: ${pickedFile.path}");
        await updateGroupProfile(imageFile: pickedFile);
      }
    } catch (e) {
      appLog("❌ Error picking image: $e");
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void onPendingRequest() {
    Get.toNamed(AppRoutes.friendPendingScreenHere, arguments: chatId);
  }

  void onPrivacySettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Group Privacy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text("Public"),
              trailing: Obx(() => Radio<String>(
                value: 'public',
                groupValue: privacy.value,
                onChanged: (val) {
                  if (val != null) {
                    privacy.value = val;
                    updateGroupProfile(newPrivacy: val);
                    Get.back();
                  }
                },
              )),
            ),
            ListTile(
              title: const Text("Private"),
              trailing: Obx(() => Radio<String>(
                value: 'private',
                groupValue: privacy.value,
                onChanged: (val) {
                  if (val != null) {
                    privacy.value = val;
                    updateGroupProfile(newPrivacy: val);
                    Get.back();
                  }
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void onLeaveGroup() {
    Get.defaultDialog(
      title: "Leave Group",
      middleText: "Are you sure you want to leave this group?",
      textConfirm: "Leave",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          isLoading.value = true;
          final res = await ApiService.delete(ApiEndPoint.leaveChat(chatId));
          if (res.statusCode == 200) {
            appLog("✅ Successfully left group");
            Get.offAllNamed(AppRoutes.homeNav);
          } else {
            appLog("❌ Failed to leave group: ${res.statusCode}");
            Get.back();
            Get.snackbar('Error', 'Failed to leave group');
          }
        } catch (e) {
          appLog("❌ Error leaving group: $e");
          Get.back();
          Get.snackbar('Error', 'Error: $e');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  void onDeleteGroup() {
    Get.defaultDialog(
      title: "Delete Group",
      middleText: "Permanently DELETE this group?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade700,
      onConfirm: () async {
        try {
          isLoading.value = true;
          final res = await ApiService.delete(ApiEndPoint.deleteChatById(chatId));
          if (res.statusCode == 200) {
            appLog("✅ Group deleted successfully");
            Get.offAllNamed(AppRoutes.homeNav);
          } else {
            appLog("❌ Failed to delete group: ${res.statusCode}");
            Get.back();
            Get.snackbar('Error', 'Failed to delete group');
          }
        } catch (e) {
          appLog("❌ Error deleting group: $e");
          Get.back();
          Get.snackbar('Error', 'Error: $e');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }
}