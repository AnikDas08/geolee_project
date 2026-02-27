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
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeFromArguments();
    });
  }

  void _initializeFromArguments() {
    try {
      final dynamic args = Get.arguments;
      if (args is Map) {
        chatId = args['chatId'] ?? '';
      } else if (args is String) {
        chatId = args;
      }

      if (chatId.isNotEmpty) {
        fetchGroupDetails();
      }
    } catch (e) {
      appLog("❌ Error initializing: $e");
    }
  }

  Future<void> fetchGroupDetails() async {
    if (chatId.isEmpty) return;
    try {
      isLoading.value = true;
      update();

      final url = "${ApiEndPoint.baseUrl}/chats/single/$chatId";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        groupName.value = data['chatName'] ?? 'Unnamed Group';
        description.value = data['description'] ?? '';
        privacy.value = data['privacy'] ?? 'public';
        accessType.value = data['accessType'] ?? 'open';
        memberCount.value = (data['participants'] as List?)?.length ?? 0;

        if (data['avatarUrl'] != null && data['avatarUrl'].isNotEmpty) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          avatarFilePath.value = "${data['avatarUrl']}?t=$timestamp";
        }
      }
    } catch (e) {
      appLog("❌ Error fetching group details: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // ✅ Admin Approval Toggle
  Future<void> toggleAdminApproval(bool value) async {
    try {
      final newAccessType = value ? 'restricted' : 'open';
      await updateGroupProfile(newAccessType: newAccessType);
    } catch (e) {
      appLog("❌ Toggle error: $e");
    }
  }

  Future<void> updateGroupProfile({
    String? newName,
    String? newDescription,
    String? newPrivacy,
    String? newAccessType,
    XFile? imageFile,
  }) async {
    if (chatId.isEmpty) return;
    try {
      isSaving.value = true;
      final String endpoint = ApiEndPoint.updateChatById(chatId);
      final Map<String, String> body = {};

      if (newName != null && newName.isNotEmpty) body['chatName'] = newName;
      if (newDescription != null && newDescription.isNotEmpty) body['description'] = newDescription;
      if (newPrivacy != null) body['privacy'] = newPrivacy;
      if (newAccessType != null) body['accessType'] = newAccessType;

      final response = await ApiService.multipartUpdate(
        endpoint,
        body: body,
        imagePath: imageFile?.path,
      );

      if (response.statusCode == 200) {
        imageCache.clear();
        imageCache.clearLiveImages();

        await fetchGroupDetails();
        Get.find<ChatController>().getChatRepos();

        Get.snackbar(
          'Success',
          newAccessType != null
              ? newAccessType == 'restricted'
              ? 'Admin approval enabled'
              : 'Admin approval disabled'
              : 'Group updated successfully!',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> onUpdateGroupName(String newName) async {
    if (newName.isEmpty) return;

    await updateGroupProfile(newName: newName);

    final chatController = Get.find<ChatController>();

    void updateList(List<ChatModel> list) {
      final int index = list.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        final oldChat = list[index];
        list[index] = ChatModel(
          id: oldChat.id,
          isGroup: oldChat.isGroup,
          chatName: newName,
          chatImage: oldChat.chatImage,
          participant: oldChat.participant,
          participants: oldChat.participants,
          latestMessage: oldChat.latestMessage,
          unreadCount: oldChat.unreadCount,
          isDeleted: oldChat.isDeleted,
          createdAt: oldChat.createdAt,
          updatedAt: oldChat.updatedAt,
          isOnline: oldChat.isOnline,
          memberCount: oldChat.memberCount,
        );
      }
    }

    updateList(chatController.chats);
    updateList(chatController.filteredChats);
    chatController.update();

    if (Get.isRegistered<GroupMessageController>()) {
      Get.find<GroupMessageController>().groupName.value = newName;
    }
  }

  Future<void> pickGroupImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      await updateGroupProfile(imageFile: pickedFile);
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
                  privacy.value = val!;
                  updateGroupProfile(newPrivacy: val);
                  Get.back();
                },
              )),
            ),
            ListTile(
              title: const Text("Private"),
              trailing: Obx(() => Radio<String>(
                value: 'private',
                groupValue: privacy.value,
                onChanged: (val) {
                  privacy.value = val!;
                  updateGroupProfile(newPrivacy: val);
                  Get.back();
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void showLeaveGroupDialog() {
    final RxBool isLeaving = false.obs;
    Get.dialog(
      Obx(() => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.exit_to_app, size: 50.sp, color: Colors.orange.shade700),
              SizedBox(height: 12.h),
              Text(
                "Leave Group",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text(
                "Are you sure you want to leave?",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLeaving.value
                          ? null
                          : () async {
                        isLeaving.value = true;
                        final res = await ApiService.patch(
                          "${ApiEndPoint.baseUrl}/chats/leave/$chatId",
                        );
                        if (res.statusCode == 200) {
                          Get.offAllNamed(AppRoutes.homeNav);
                        }
                        isLeaving.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                      ),
                      child: isLeaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Leave",
                        style: TextStyle(color: Colors.white),
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
    final RxBool isDeleting = false.obs;
    Get.dialog(
      Obx(() => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever, size: 50.sp, color: Colors.red.shade700),
              SizedBox(height: 12.h),
              Text(
                "Delete Group",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text(
                "Permanently DELETE this group?",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isDeleting.value
                          ? null
                          : () async {
                        isDeleting.value = true;
                        final res = await ApiService.delete(
                          ApiEndPoint.deleteChatById(chatId),
                        );
                        if (res.statusCode == 200) {
                          Get.offAllNamed(AppRoutes.homeNav);
                        } else {
                          Get.snackbar('Error', 'You are not the author.');
                        }
                        isDeleting.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: isDeleting.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
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