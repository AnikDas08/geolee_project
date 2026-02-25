import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:giolee78/utils/app_utils.dart';
// Assuming your model is in this path
import '../../data/model/add_friend_model.dart';


class AddMemberController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchKeyword = ''.obs;
  String chatId = '';
  Timer? _debounce;

  // List for search results (users found in global search)
  final RxList<Participant> searchResults = <Participant>[].obs;

  // List for existing group members
  final RxList<Participant> currentMembers = <Participant>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Getting chatId passed from previous screen via Get.toNamed(..., arguments: {'chatId': '...'})
    chatId = Get.arguments?['chatId'] ?? '';
    if (chatId.isNotEmpty) {
      fetchCurrentMembers();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// 1. Fetch current members of the group
  Future<void> fetchCurrentMembers() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get("${ApiEndPoint.getSingleChatById}/$chatId");

      if (response.statusCode == 200) {
        final groupData = TotalMemberResponseModelById.fromJson(response.data as Map<String,dynamic>);
        currentMembers.assignAll(groupData.data.participants);
      }
    } catch (e) {
      appLog("❌ Error fetching members: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 2. Search users with Debounce (Wait 500ms after user stops typing)
  void onSearchChanged(String value) {
    searchKeyword.value = value.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (searchKeyword.value.isNotEmpty) {
        searchUsers(searchKeyword.value);
      } else {
        searchResults.clear();
      }
    });
  }

  Future<void> searchUsers(String query) async {
    try {
      // We don't set global isLoading to true here to avoid flickering the whole screen
      final response = await ApiService.get(ApiEndPoint.getMyChat(query));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        // Convert dynamic list to Participant list
        List<Participant> results = data.map((e) {
          // Handling your specific JSON structure where user info is in 'anotherParticipant'
          final p = e['anotherParticipant'];
          return Participant(
            id: p?['_id'] ?? e['_id'] ?? '',
            name: p?['name'] ?? e['name'] ?? 'Unknown',
            image: p?['image'] ?? e['image'] ?? '',
          );
        }).toList();

        // Filter out users who are already in the group
        results.removeWhere((res) => currentMembers.any((m) => m.id == res.id));
        searchResults.assignAll(results);
      }
    } catch (e) {
      appLog("❌ Search error: $e");
    }
  }

  /// 3. Add member
  Future<void> onAddMember(Participant user) async {
    try {
      final url="${ApiEndPoint.addMember}${user.id}";
      final response = await ApiService.patch(
        url,
        body: {"members": user.id},
      );

      if (response.statusCode == 200) {
        currentMembers.add(user);
        searchResults.removeWhere((u) => u.id == user.id);
        Utils.successSnackBar("Success", "${user.name} added to group");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Could not add member");
    }
  }




  /// 4. Remove member
  void showRemoveMemberDialog(Participant member) {
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
                Icons.person_remove,
                size: 50.sp,
                color: Colors.red.shade700,
              ),
              SizedBox(height: 12.h),
              Text(
                "Remove Member",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Remove ${member.name} from the group?",
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

                  // Remove Button
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading.value
                          ? null
                          : () async {
                        try {
                          isLoading.value = true;
                          Get.back(); // Close dialog first

                          final response = await ApiService.patch(
                            "${ApiEndPoint.removeMember}${chatId}",
                            body: {"member": member.id},
                          );

                          if (response.statusCode == 200) {
                            currentMembers
                                .removeWhere((m) => m.id == member.id);
                            Utils.successSnackBar(
                                "Removed", "${member.name} removed");
                          }
                        } catch (e) {
                          Utils.errorSnackBar(
                              "Error", "Could not remove member");
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.red.shade700,
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
}