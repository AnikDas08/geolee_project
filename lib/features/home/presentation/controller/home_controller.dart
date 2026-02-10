import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/my_profile_controller.dart';
import 'package:giolee78/utils/enum/enum.dart';

import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_keys.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../friend/data/friend_request_model.dart';
import '../../data/data_model.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  String searchQuery = '';
  RxString name = "".obs;
  RxString image = "".obs;
  String subCategory = "";
  int notificationCount = 0;
  RxList<FriendModel> friendRequestsList = <FriendModel>[].obs;

  RxBool IsLoading=false.obs;

  var clickerCount = RxnString(); // nullable, no initial value
  var filterOption = RxnString();

  // Filter parameters
  var selectedPeriod = 'Last 24 Hours'.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  String? argument;

  List<String> clickerOptions = ["All", "Great Vibes", "Off Vibes", "Charming Gentleman","Lovely Leady"];
  List<String> filterOptions = ["Option 1", "Option 2", "Option 3"];
  final MyProfileController myProfileController=Get.put(MyProfileController());

  @override
  void onInit() {
    print("My Role Is :===========================💕💕💕💕💕💕 ${LocalStorage.role.toString()}");
    super.onInit();
    argument=Get.arguments;
    Get.find<HomeNavController>().refresh();
    Get.find<MyProfileController>().refresh();
    myProfileController.getUserData();

    if (LocalStorage.token != null && LocalStorage.token!.isNotEmpty) {
      fetchPosts(); // If this is a private feed
      myProfileController.getUserData();
    }
    else{
      allPosts = [];
      filteredPosts = [];
      isLoading = false;
      update();
    }


  }

  void applyFilter(String period, DateTime start, DateTime end) {
    selectedPeriod.value = period;
    startDate.value = start;
    endDate.value = end;

    // Apply your filtering logic here
    // For example, filter posts by date range
    if (period != 'Custom Range') {
      // Auto-calculate date range based on period
      end = DateTime.now();
      if (period == 'Last 24 Hours') {
        start = end.subtract(Duration(hours: 3));
      } else if (period == 'Last 7 days') {
        start = end.subtract(Duration(hours: 24));
      }else if (period == 'Last 30 Days') {
        start = end.subtract(Duration(days: 30));
      }
      startDate.value = start;
      endDate.value = end;
    }

    // Filter posts based on date range
    filteredPosts = allPosts.where((post) {
      // Assuming your Post model has a createdAt field
      // Adjust this according to your actual data model
      // DateTime postDate = post.createdAt;
      // return postDate.isAfter(start) && postDate.isBefore(end);
      return true; // Replace with actual filtering logic
    }).toList();

    update();
  }

  Future<void> fetchPosts() async {
    isLoading = true;
    update();

    try {
      final response = await ApiService.get(
        ApiEndPoint.post,
      );

      if (response.statusCode == 200) {
        final postResponse = PostResponseModel.fromJson(response.data);
        allPosts = postResponse.data;
        filteredPosts = allPosts;
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  void getProfile() async {
    try {
      final response = await ApiService.get(
        "user/profile",
      );

      if (response.statusCode == 200) {
        name.value = response.data["data"]["name"];
        image.value = response.data["data"]["image"];
        if (response.data["data"].isNotEmpty) {
          notificationCount = 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  void searchPosts(String query) {
    searchQuery = query.toLowerCase();

    if (searchQuery.isEmpty) {
      filteredPosts = allPosts;
    } else {
      filteredPosts = allPosts.where((post) {
        return post.title.toLowerCase().contains(searchQuery) ||
            post.description.toLowerCase().contains(searchQuery) ||
            post.user.name.toLowerCase().contains(searchQuery);
      }).toList();
    }

    update();
  }




  Future<void> fetchFriendRequests() async {
    try {
      final url = "${ApiEndPoint.getMyFriendRequest}";
      IsLoading.value = true;

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        debugPrint("response => ${response.data}");

        // ধরে নিচ্ছি response.data = { "data": [ {...}, {...} ] }
        final dataList = response.data['data'] as List<dynamic>;
        friendRequestsList.value = dataList
            .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
            .toList();

      } else {
        debugPrint("Error response => ${response.data}");
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      IsLoading.value = false;
    }
  }


  /*void clearSearch() {
    searchQuery = '';
    filteredPosts = allPosts;
    update();
  }*/
}