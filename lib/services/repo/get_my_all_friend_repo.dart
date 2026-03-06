import 'package:flutter/material.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/data/my_friends_model.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

class GetMyAllFriendsRepo {
  Future<List<MyFriendsData>> getFriendList({String? searchTerm}) async {
    final List<MyFriendsData> myFriendsList = [];
    try {
      String url = ApiEndPoint.getMyAllFriend;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        url += "?searchTerm=${Uri.encodeComponent(searchTerm)}";
      }
      final ApiResponseModel response = await ApiService.get(url);
      if (response.statusCode == 200) {
        debugPrint("Friend List=================: ${response.data}");

        if (response.data["data"] is List) {
          for (var item in response.data["data"]) {
            myFriendsList.add(MyFriendsData.fromJson(item));
          }
        }
      }
    } catch (e) {}
    return myFriendsList;
  }
}
