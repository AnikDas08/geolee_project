import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/utils/enum/enum.dart';

import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_keys.dart';
import '../../../../services/storage/storage_services.dart';
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

  var clickerCount = RxnString(); // nullable, no initial value
  var filterOption = RxnString();

  // Filter parameters
  var selectedPeriod = 'Last 24 Hours'.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  String? argument;

  List<String> clickerOptions = ["All", "Great Vibes", "Off Vibes", "Charming Gentleman","Lovely Leady"];
  List<String> filterOptions = ["Option 1", "Option 2", "Option 3"];

  @override
  void onInit() {
    super.onInit();
    argument=Get.arguments;
    LocalStorage.myRole==UserType.user.name;
    LocalStorage.setString(
      LocalStorageKeys.myRole,
      LocalStorage.myRole,
    );
    Get.find<HomeNavController>().refresh();
    fetchPosts();
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
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
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
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
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

  /*void clearSearch() {
    searchQuery = '';
    filteredPosts = allPosts;
    update();
  }*/
}