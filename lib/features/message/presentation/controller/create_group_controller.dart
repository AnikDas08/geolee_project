import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import 'chat_controller.dart';

// ============================================
// GROUP MEMBER MODEL
// ============================================
class GroupMember {
  final String id;
  final String name;
  final String? image;

  GroupMember({required this.id, required this.name, this.image});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    // If the JSON comes from 'my-chats', participant info is in 'anotherParticipant'
    final participant = json['anotherParticipant'];
    if (participant != null) {
      return GroupMember(
        id: participant['_id'] ?? '',
        name: participant['name'] ?? 'Unknown',
        image: participant['image'],
      );
    }

    // Fallback for direct user objects (e.g. from search)
    return GroupMember(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      image: json['image'],
    );
  }
}

enum PrivacyType { public, private, restricted }

class CreateGroupController extends GetxController {
  // Text controllers
  final groupNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();

  RxBool isMemberLoading = false.obs;
  RxBool isCreating = false.obs;

  // Privacy
  var selectedPrivacyType = PrivacyType.public.obs;

  // Privacy options for dropdown
  final privacyTypes = [
    "Public Group",
    "Private Group",
    "Admin Approval Group",
  ];

  final privacyOptions = {
    PrivacyType.public: "Public Group",
    PrivacyType.private: "Private Group",
    PrivacyType.restricted: "Admin Approval Group",
  };

  // Members
  final availableMembers = <GroupMember>[].obs;
  final selectedMembers = <GroupMember>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // Privacy getter for API
  String get privacyValue {
    switch (selectedPrivacyType.value) {
      case PrivacyType.public:
        return 'public';
      case PrivacyType.private:
        return 'private';
      case PrivacyType.restricted:
        return 'restricted';
    }
  }

  // Participant IDs for API
  List<String> get participantIds => selectedMembers.map((e) => e.id).toList();

  // Change privacy type
  void changePrivacyType(String? value) {
    if (value == null) return;

    switch (value) {
      case "Public Group":
        selectedPrivacyType.value = PrivacyType.public;
        break;
      case "Private Group":
        selectedPrivacyType.value = PrivacyType.private;
        break;
      case "Admin Approval Group":
        selectedPrivacyType.value = PrivacyType.restricted;
        break;
    }
    update();
  }

  // Add member
  void addMember(GroupMember member) {
    if (!selectedMembers.contains(member)) {
      selectedMembers.add(member);
      update();
    }
  }

  // Remove member
  void removeMember(String memberId) {
    selectedMembers.removeWhere((member) => member.id == memberId);
    update();
  }

  // Toggle member (add or remove)
  void toggleMember(GroupMember member) {
    if (selectedMembers.any((m) => m.id == member.id)) {
      removeMember(member.id);
    } else {
      addMember(member);
    }
  }

  // Search members
  void searchMembers(String query) {
    searchQuery.value = query.toLowerCase();
    if (query.isEmpty) {
      fetchMyChats();
    } else {
      fetchMyChats(search: query);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchMyChats();
  }

  // Fetch members from API
  Future<void> fetchMyChats({String search = ''}) async {
    try {
      isMemberLoading.value = true;
      final response = await ApiService.get(ApiEndPoint.getMyChat(search));

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        availableMembers.value = data
            .map((e) => GroupMember.fromJson(e))
            .toList();
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to load members",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint("Error fetching members: $e");
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isMemberLoading.value = false;
    }
  }

  // Validate inputs
  bool _validateInputs() {
    if (groupNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter group name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter description',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Add at least one member',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> leaveChat(String id) async {
    try {
      final response = await ApiService.delete(ApiEndPoint.leaveChat(id));

      if (response.statusCode == 200) {
        debugPrint("${response.statusCode}${response.message}");
      }
    } catch (e) {
      debugPrint("Error fetching members: $e");
    }
  }

  // Create group API
  Future<void> createGroup() async {
    if (!_validateInputs()) return;

    try {
      isCreating.value = true;

      final body = {
        "participants": participantIds,
        "chatName": groupNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "privacy": privacyValue,
      };

      debugPrint("Creating group with: $body");

      final ApiResponseModel response = await ApiService.post(
        ApiEndPoint.createGroup,
        body: body,
      );

      if (response.statusCode == 200 || response.data['success'] == true) {
        final createdGroupId = response.data['data']['_id'];
        final createdGroupName = groupNameController.text.trim();
        final createdGroupImage = response.data['data']['avatarUrl'] ?? "";

        // Navigate before clearing form
        Get.toNamed(AppRoutes.message, parameters: {
          "chatId": createdGroupId,
          "name": createdGroupName,
          "image": createdGroupImage,
        });

        // Snackbar
        Get.snackbar(
          "Success",
          "Group created successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form after navigation
        groupNameController.clear();
        descriptionController.clear();
        searchController.clear();
        selectedMembers.clear();
        selectedPrivacyType.value = PrivacyType.public;

        // Refresh group list
        ChatController.instance.getChatRepos();
      }
    } catch (e) {
      debugPrint("Error creating group: $e");
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    groupNameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
