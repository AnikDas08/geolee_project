import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/log/app_log.dart';

class User {
  final String id;
  final String name;
  final String avatarUrl;

  User({required this.id, required this.name, required this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['image'] ?? '',
    );
  }
}

class AddMemberController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchKeyword = ''.obs;
  String chatId = '';

  // Real list of users from search
  final RxList<User> searchResults = <User>[].obs;

  // Real list of current members (fetched from API)
  final RxList<User> currentMembers = <User>[].obs;

  // Computed list of current members filtered by search (locally)
  List<User> get filteredMembers => currentMembers
      .where(
        (member) =>
            searchKeyword.isEmpty ||
            member.name.toLowerCase().contains(
              searchKeyword.value.toLowerCase(),
            ),
      )
      .toList();

  @override
  void onInit() {
    super.onInit();
    chatId = Get.arguments['chatId'] ?? '';
    fetchCurrentMembers();
  }

  /// Fetch current members of the group
  Future<void> fetchCurrentMembers() async {
    if (chatId.isEmpty) return;

    try {
      isLoading.value = true;
      // Note: Assuming there's an endpoint to get group details or members
      // If not specifically available, we might need to get it from the chat list
      final response = await ApiService.get("${ApiEndPoint.chatRoom}/$chatId");
      if (response.statusCode == 200) {
        final List<dynamic> membersData =
            response.data['data']?['participants'] ?? [];
        currentMembers.value = membersData
            .map((e) => User.fromJson(e))
            .toList();
      }
    } catch (e) {
      appLog("❌ Error fetching current members: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Search for users to invite
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiEndPoint.getMyChat(query));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        searchResults.value = data.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) {
      appLog("❌ Error searching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchKeyword.value = value.trim();
    searchUsers(value.trim());
  }

  /// Add member to group via API
  Future<void> onAddMember(User user) async {
    if (chatId.isEmpty) return;

    try {
      final response = await ApiService.patch(
        ApiEndPoint.addMember,
        body: {"chatId": chatId, "userId": user.id},
      );

      if (response.statusCode == 200) {
        currentMembers.add(user);
        searchResults.removeWhere((u) => u.id == user.id);
        Get.snackbar('Success', '${user.name} added to group');
      }
    } catch (e) {
      appLog("❌ Error adding member: $e");
      Get.snackbar('Error', 'Failed to add member');
    }
  }

  /// Remove member from group via API
  Future<void> onRemoveMember(User member) async {
    if (chatId.isEmpty) return;

    Get.defaultDialog(
      title: "Remove Member",
      middleText: "Remove ${member.name} from the group?",
      textConfirm: "Remove",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          final response = await ApiService.patch(
            ApiEndPoint.removeMember,
            body: {"chatId": chatId, "userId": member.id},
          );

          if (response.statusCode == 200) {
            currentMembers.removeWhere((m) => m.id == member.id);
            Get.back();
            Get.snackbar('Removed', '${member.name} removed');
          }
        } catch (e) {
          appLog("❌ Error removing member: $e");
          Get.snackbar('Error', 'Failed to remove member');
        }
      },
    );
  }
}
