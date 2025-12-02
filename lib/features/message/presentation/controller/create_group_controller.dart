import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupController extends GetxController {
  /// Text Controllers
  final groupNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();

  /// Selected Privacy Type
  String selectedPrivacyType = 'Public Group';

  /// Privacy Type Options
  final List<String> privacyTypes = [
    'Public Group',
    'Private Group',
    'Admin Approval Group',
  ];

  /// Selected Members List
  List<GroupMember> selectedMembers = [];

  /// Search Query
  String searchQuery = '';

  /// Change Privacy Type
  void changePrivacyType(String? value) {
    if (value != null) {
      selectedPrivacyType = value;
      update();
    }
  }

  /// Add Member
  void addMember(GroupMember member) {
    if (!selectedMembers.any((m) => m.id == member.id)) {
      selectedMembers.add(member);
      update();
    }
  }

  /// Remove Member
  void removeMember(String memberId) {
    selectedMembers.removeWhere((m) => m.id == memberId);
    update();
  }

  /// Search Members
  void searchMembers(String query) {
    searchQuery = query.toLowerCase().trim();
    update();
  }

  /// Clear Search
  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    update();
  }

  /// Create Group
  void createGroup() {
    if (groupNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter group name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter group description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedMembers.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one member',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // TODO: Implement API call to create group
    Get.snackbar(
      'Success',
      'Group created successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Navigate back
    Get.back();
  }

  @override
  void onClose() {
    groupNameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

// ============================================
// GROUP MEMBER MODEL
// ============================================
class GroupMember {
  final String id;
  final String name;
  final String? image;

  GroupMember({
    required this.id,
    required this.name,
    this.image,
  });
}