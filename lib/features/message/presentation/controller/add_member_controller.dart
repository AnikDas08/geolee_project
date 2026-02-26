import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:giolee78/utils/app_utils.dart';
import '../../data/model/add_friend_model.dart';
import '../../data/model/friend_response_model.dart';



class AddMemberController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchKeyword = ''.obs;
  String chatId = '';
  Timer? _debounce;

  final RxList<Participant> searchResults = <Participant>[].obs;
  final RxList<Participant> currentMembers = <Participant>[].obs;

  List<Participant> allFriendsList = [];

  @override
  void onInit() {
    super.onInit();
    chatId = Get.arguments?['chatId'] ?? '';
    appLog("🔍 ChatID: $chatId");

    if (chatId.isNotEmpty) {
      loadData();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// Load both current members and friends
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      appLog("🔄 Loading data...");

      // First fetch current members
      await fetchCurrentMembers();

      // Then fetch friends
      await fetchMyFriends();

      appLog("✅ Data loading complete");
    } catch (e) {
      appLog("❌ Error in loadData: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch current members
  Future<void> fetchCurrentMembers() async {
    try {
      appLog("📥 Fetching current members...");
      final response = await ApiService.get("${ApiEndPoint.getSingleChatById}/$chatId");

      appLog("📊 Members Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final groupData = TotalMemberResponseModelById.fromJson(response.data as Map<String, dynamic>);
        currentMembers.assignAll(groupData.data.participants);

        appLog("✅ Current members count: ${currentMembers.length}");
        for (var member in currentMembers) {
          appLog("   📍 Member: ${member.name} (${member.id})");
        }
      }
    } catch (e) {
      appLog("❌ Error fetching members: $e");
    }
  }

  /// Fetch friends from API
  Future<void> fetchMyFriends() async {
    try {
      appLog("📥 Fetching friends...");
      final response = await ApiService.get(ApiEndPoint.getMyAllFriend);

      appLog("📊 Friends Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse response using model
        final friendsResponse = FriendsResponse.fromJson(response.data as Map<String, dynamic>);

        appLog("📊 Total friends from API: ${friendsResponse.data.length}");

        // Convert to Participant list
        List<Participant> friends = [];
        for (var i = 0; i < friendsResponse.data.length; i++) {
          final friendData = friendsResponse.data[i];
          friends.add(Participant(
            id: friendData.friend.id,
            name: friendData.friend.name,
            image: friendData.friend.image,
          ));
          appLog("   👤 Friend $i: ${friendData.friend.name} (${friendData.friend.id})");
        }

        appLog("📊 Current members in list: ${currentMembers.length}");
        for (var member in currentMembers) {
          appLog("   📍 Current: ${member.name} (${member.id})");
        }

        // Filter out already added members
        appLog("🔍 Filtering...");
        List<Participant> filtered = [];
        for (var friend in friends) {
          bool isAlreadyMember = currentMembers.any((member) => member.id == friend.id);
          if (isAlreadyMember) {
            appLog("   🚫 Filtered out: ${friend.name} (already member)");
          } else {
            appLog("   ✅ Keeping: ${friend.name}");
            filtered.add(friend);
          }
        }

        allFriendsList = filtered;
        appLog("✅ Available friends (after filtering): ${allFriendsList.length}");

        // Show all friends initially
        searchResults.assignAll(allFriendsList);
      }
    } catch (e) {
      appLog("❌ Error fetching friends: $e");
      Utils.errorSnackBar("Error", "Failed to load friends");
    }
  }

  /// Search/Filter friends
  void onSearchChanged(String value) {
    searchKeyword.value = value.trim();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (searchKeyword.value.isEmpty) {
        searchResults.assignAll(allFriendsList);
      } else {
        final filtered = allFriendsList
            .where((friend) => friend.name.toLowerCase()
            .contains(searchKeyword.value.toLowerCase()))
            .toList();
        appLog("🔎 Search for '${searchKeyword.value}': found ${filtered.length}");
        searchResults.assignAll(filtered);
      }
    });
  }

  /// Add member to group
  /// Add member to group
  Future<void> onAddMember(Participant friend) async {
    try {
      if (chatId.isEmpty) {
        appLog("❌ Error: Chat ID is empty");
        return;
      }

      appLog("➕ Adding: ${friend.name} to Chat: $chatId");


      final url = "${ApiEndPoint.addMember}$chatId";

      appLog("📤 Sending payload: {members: [${friend.id}]}");

      final response = await ApiService.patch(
        url,
        body: {
          "members": [friend.id] // Friend ID array hishebe body-te jabe
        },
      );

      appLog("📊 Add response: ${response.statusCode}");

      if (response.statusCode == 200) {
        currentMembers.add(friend);
        allFriendsList.removeWhere((f) => f.id == friend.id);
        searchResults.removeWhere((f) => f.id == friend.id);

        Utils.successSnackBar("Success", "${friend.name} added to group");
        appLog("✅ ${friend.name} added successfully");
      }
    } catch (e) {
      appLog("❌ Error adding member: $e");
      Utils.errorSnackBar("Error", "Could not add member");
    }
  }

  /// Remove member dialog
  void showRemoveMemberDialog(Participant member) {
    final RxBool isRemoving = false.obs;

    Get.dialog(
      Obx(() => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Icon(Icons.person_remove, size: 50.sp, color: Colors.red.shade700),
              SizedBox(height: 12.h),
              Text(
                "Remove Member",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                "Remove ${member.name} from the group?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
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
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: isRemoving.value ? null : () => _removeMember(member, isRemoving),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.red.shade700,
                        ),
                        alignment: Alignment.center,
                        child: isRemoving.value
                            ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          "Remove",
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

  /// Helper to remove member
  Future<void> _removeMember(Participant member, RxBool isRemoving) async {
    try {
      isRemoving.value = true;
      Get.back();

      appLog("🗑️ Removing: ${member.name}");

      final response = await ApiService.patch(
        "${ApiEndPoint.removeMember}$chatId",
        body: {"member": member.id},
      );

      appLog("📊 Remove response: ${response.statusCode}");

      if (response.statusCode == 200) {
        currentMembers.removeWhere((m) => m.id == member.id);
        allFriendsList.add(member);
        searchResults.add(member);

        Utils.successSnackBar("Removed", "${member.name} removed");
        appLog("✅ ${member.name} removed successfully");
      }
    } catch (e) {
      appLog("❌ Error removing member: $e");
      Utils.errorSnackBar("Error", "Could not remove member");
    } finally {
      isRemoving.value = false;
    }
  }
}