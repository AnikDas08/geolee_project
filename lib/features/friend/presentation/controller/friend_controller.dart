import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class MyFriendController extends GetxController {
  // List to track suggested friends (id, name, avatar)
  final RxList<Map<String, dynamic>> suggestedFriends = <Map<String, dynamic>>[
    {'id': '1', 'name': 'Arlene McCoy', 'avatar': AppImages.profileImage},
    {'id': '2', 'name': 'Brooklyn Simmons', 'avatar': AppImages.profileImage},
  ].obs;

  // List to track friend request sent status
  final RxMap<String, bool> friendRequestSent = <String, bool>{}.obs;

  // List of current friends
  final RxList<Map<String, dynamic>> friendsList = <Map<String, dynamic>>[
    {'id': '3', 'name': 'Wade Warren', 'avatar': AppImages.profileImage},
    {'id': '4', 'name': 'Esther Howard', 'avatar': AppImages.profileImage},
    {'id': '5', 'name': 'Cameron Williamson', 'avatar': AppImages.profileImage},
    {'id': '6', 'name': 'Robert Fox', 'avatar': AppImages.profileImage},
  ].obs;

  // Send friend request
  void sendFriendRequest(String userId) {
    friendRequestSent[userId] = true;

  }

  // Remove friend
  void removeFriend(String userId) {
    friendsList.removeWhere((friend) => friend['id'] == userId);

  }

  // Check if friend request is sent
  bool isRequestSent(String userId) {
    return friendRequestSent[userId] ?? false;
  }
}