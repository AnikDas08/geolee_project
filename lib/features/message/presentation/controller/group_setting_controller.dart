import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/message/presentation/controller/chat_controller.dart';
import 'package:giolee78/features/message/presentation/controller/group_message_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../data/model/chat_list_model.dart';

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


        if (data['avatarUrl'] != null && data['avatarUrl'].isNotEmpty) {
          String path = data['avatarUrl'];
          avatarFilePath.value = path;
          appLog("✅ Avatar Path: $path");
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

        if (newName != null && newName.isNotEmpty) {
          groupName.value = newName;
        }
        if (newDescription != null) {
          description.value = newDescription;
        }
        if (newPrivacy != null) {
          privacy.value = newPrivacy;
        }
        if (newAccessType != null) {
          accessType.value = newAccessType;
        }
        if (imageFile != null) {
          avatarFilePath.value = imageFile.path;
        }

        Get.find<ChatController>().getChatRepos();


        update();
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

    // 1️⃣ Update backend
    await updateGroupProfile(newName: newName);

    // 2️⃣ Update ChatController local list manually
    final chatController = Get.find<ChatController>();

    // Update in chats list
    int index = chatController.chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final oldChat = chatController.chats[index];
      chatController.chats[index] = ChatModel(
        id: oldChat.id,
        isGroup: oldChat.isGroup,
        chatName: newName,          // <-- নতুন নাম
        chatImage: oldChat.chatImage,
        participant: oldChat.participant,
        latestMessage: oldChat.latestMessage,
        unreadCount: oldChat.unreadCount,
        isDeleted: oldChat.isDeleted,
        createdAt: oldChat.createdAt,
        updatedAt: oldChat.updatedAt,
        isOnline: oldChat.isOnline,
      );
    }

    // Update in filteredChats list
    index = chatController.filteredChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final oldChat = chatController.filteredChats[index];
      chatController.filteredChats[index] = ChatModel(
        id: oldChat.id,
        isGroup: oldChat.isGroup,
        chatName: newName,
        chatImage: oldChat.chatImage,
        participant: oldChat.participant,
        latestMessage: oldChat.latestMessage,
        unreadCount: oldChat.unreadCount,
        isDeleted: oldChat.isDeleted,
        createdAt: oldChat.createdAt,
        updatedAt: oldChat.updatedAt,
        isOnline: oldChat.isOnline,
      );
    }

    // 3️⃣ Update UI
    chatController.update();

    // 4️⃣ Update GroupMessageController UI
    final groupController = Get.find<GroupMessageController>();
    groupController.groupName.value = newName;
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

  void showLeaveGroupDialog() {
    final RxBool isLoading = false.obs;

    Get.dialog(
      Obx(() => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app,
                size: 50.sp,
                color: Colors.orange.shade700,
              ),
              SizedBox(height: 12.h),
              Text(
                "Leave Group",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to leave this group?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 20.h),

              // Buttons Row (Container taps)
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey.shade100,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Leave Button
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading.value
                          ? null
                          : () async {
                        try {
                          isLoading.value = true;

                          String url =
                              "${ApiEndPoint.baseUrl}/chats/leave/$chatId";

                          var response = await ApiService.patch(url);

                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            Get.back();
                            Get.offAllNamed(AppRoutes.homeNav);
                            Get.snackbar(
                              "Success",
                              "You have left the group successfully",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          Get.snackbar(
                            "Error",
                            "Failed to leave the group. Please try again.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.orange.shade700,
                        ),
                        alignment: Alignment.center,
                        child: isLoading.value
                            ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          "Leave",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }

  void onDeleteGroup() {
    final RxBool isLoading = false.obs;

    Get.dialog(
      Obx(() => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_forever,
                size: 50.sp,
                color: Colors.red.shade700,
              ),
              SizedBox(height: 12.h),
              Text(
                "Delete Group",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to permanently DELETE this group?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 20.h),

              // Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () async {
                        try {
                          isLoading.value = true;
                          final res = await ApiService.delete(
                              ApiEndPoint.deleteChatById(chatId));
                          if (res.statusCode == 200) {
                            appLog("✅ Group deleted successfully");
                            Get.offAllNamed(AppRoutes.homeNav);
                          } else {
                            appLog(
                                "❌ Failed to delete group: ${res.statusCode}");
                            Get.back();
                            Get.snackbar(
                              'Delete Failed',
                              'You are not the author. Cannot delete group.',
                            );
                          }
                        } catch (e) {
                          appLog("❌ Error deleting group: $e");
                          Get.back();
                          Get.snackbar('Error', 'Error: $e');
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: isLoading.value
                          ? SizedBox(
                        height: 18.h,
                        width: 18.h,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}