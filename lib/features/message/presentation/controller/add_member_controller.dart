import 'package:get/get.dart';
import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String avatarUrl;

  User({required this.id, required this.name, required this.avatarUrl});
}

class AddMemberController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchKeyword = ''.obs;

  // Mock list of all potential users (to be searched)
  final List<User> _allPotentialUsers = [
    User(id: 'u1', name: 'Arlene McCoy', avatarUrl: 'https://placehold.co/40x40/FFD180/8D6E63?text=AM'),
    User(id: 'u2', name: 'Darrell Steward', avatarUrl: 'https://placehold.co/40x40/FFCCBC/BF360C?text=DS'),
    User(id: 'u3', name: 'Kathryn Murphy', avatarUrl: 'https://placehold.co/40x40/B3E5FC/0277BD?text=KM'),
    User(id: 'u4', name: 'Ralph Edwards', avatarUrl: 'https://placehold.co/40x40/C8E6C9/2E7D32?text=RE'),
  ];

  // Mock list of current members (to be displayed and potentially removed)
  final RxList<User> currentMembers = <User>[
    User(id: 'm1', name: 'Arlene McCoy', avatarUrl: 'https://placehold.co/40x40/FFD180/8D6E63?text=AM'),
    User(id: 'm5', name: 'Theresa Webb', avatarUrl: 'https://placehold.co/40x40/D1C4E9/4527A0?text=TW'),
    User(id: 'm6', name: 'Wade Warren', avatarUrl: 'https://placehold.co/40x40/F0F4C3/AFB42B?text=WW'),
    User(id: 'm7', name: 'Savannah Nunez', avatarUrl: 'https://placehold.co/40x40/F8BBD0/C2185B?text=SN'),
    User(id: 'm8', name: 'Devon Lane', avatarUrl: 'https://placehold.co/40x40/BCAAA4/5D4037?text=DL'),
    User(id: 'm9', name: 'Cody Fisher', avatarUrl: 'https://placehold.co/40x40/B2DFDB/00695C?text=CF'),
    User(id: 'm10', name: 'Esther Howard', avatarUrl: 'https://placehold.co/40x40/FFF9C4/FFEB3B?text=EH'),
    User(id: 'm11', name: 'Guy Hawkins', avatarUrl: 'https://placehold.co/40x40/E1BEE7/8E24AA?text=GH'),
    User(id: 'm12', name: 'Annette Black', avatarUrl: 'https://placehold.co/40x40/CFD8DC/607D8B?text=AB'),
    User(id: 'm13', name: 'Cameron Williamson', avatarUrl: 'https://placehold.co/40x40/FFE0B2/EF6C00?text=CW'),
  ].obs;

  // Computed list of users available to be added, based on search and membership status
  RxList<User> get usersToInvite => _allPotentialUsers
      .where((user) =>
  !currentMembers.any((member) => member.id == user.id) &&
      (searchKeyword.isEmpty ||
          user.name.toLowerCase().contains(searchKeyword.value.toLowerCase())))
      .toList()
      .obs;

  // Computed list of current members filtered by search (for the bottom section)
  RxList<User> get filteredMembers => currentMembers
      .where((member) =>
  searchKeyword.isEmpty ||
      member.name.toLowerCase().contains(searchKeyword.value.toLowerCase()))
      .toList()
      .obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroupData();
  }

  Future<void> fetchGroupData() async {
    isLoading.value = true;
    // Simulate fetching both user list and current members
    await 1.seconds.delay();

    // The data is already initialized, just toggling loading state
    isLoading.value = false;
  }

  void onSearchChanged(String value) {
    searchKeyword.value = value.trim();
  }

  void onAddMember(User user) {
    // Check if the user is already a member (safety check)
    if (!currentMembers.any((member) => member.id == user.id)) {
      currentMembers.add(user);
      searchKeyword.value = ''; // Clear search after adding
      Get.snackbar('Added', '${user.name} has been added to the group.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void onRemoveMember(User member) {
    // Confirmation dialog is a good practice here
    Get.defaultDialog(
      title: "Remove Member",
      middleText: "Are you sure you want to remove ${member.name} from the group?",
      textConfirm: "Remove",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        currentMembers.removeWhere((m) => m.id == member.id);
        Navigator.pop(Get.context!);
        Get.snackbar('Removed', '${member.name} has been removed.', snackPosition: SnackPosition.BOTTOM);
      },
      onCancel: () {
        Navigator.pop(Get.context!);
      },
    );
  }
}