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
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  var clickerCount = RxnString();
  var filterOption = RxnString();

  // Filter parameters
  var selectedPeriod = 'Last 24 Hours'.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  String? argument;

  // --- Static Heatmap Variables ---
  Set<Heatmap> heatmaps = {};

  List<String> clickerOptions = ["All", "Great Vibes", "Off Vibes", "Charming Gentleman","Lovely Leady"];
  List<String> filterOptions = ["Option 1", "Option 2", "Option 3"];
  final MyProfileController myProfileController = Get.put(MyProfileController());

  @override
  void onInit() {
    super.onInit();
    argument = Get.arguments;
    Get.find<HomeNavController>().refresh();
    Get.find<MyProfileController>().refresh();
    myProfileController.getUserData();

    // Initialize the static heatmap immediately
    _loadStaticHeatmap();

    if (LocalStorage.token != null && LocalStorage.token!.isNotEmpty) {
      fetchPosts();
      myProfileController.getUserData();
    }
    else {
      allPosts = [];
      filteredPosts = [];
      isLoading = false;
      update();
    }
  }

  // --- Method to Load Static Heatmap Data ---
  void _loadStaticHeatmap() {
    List<WeightedLatLng> staticPoints = [
      WeightedLatLng(LatLng(23.777176, 90.399452), weight: 1.0),
      WeightedLatLng(LatLng(23.778000, 90.400000), weight: 1.5),
      WeightedLatLng(LatLng(23.776500, 90.398000), weight: 2.0),
      WeightedLatLng(LatLng(23.456550, 90.378000), weight: 5.0),
    ];

    heatmaps = {
      Heatmap(
        heatmapId: const HeatmapId("static_activity"),
        data: staticPoints,
        // Wrap the int in HeatmapRadius
        radius: HeatmapRadius.fromPixels(40),
        opacity: 0.7,
      )
    };
    update();
  }

  void applyFilter(String period, DateTime start, DateTime end) {
    selectedPeriod.value = period;
    startDate.value = start;
    endDate.value = end;

    if (period != 'Custom Range') {
      end = DateTime.now();
      if (period == 'Last 24 Hours') {
        start = end.subtract(const Duration(hours: 3));
      } else if (period == 'Last 7 days') {
        start = end.subtract(const Duration(hours: 24));
      } else if (period == 'Last 30 Days') {
        start = end.subtract(const Duration(days: 30));
      }
      startDate.value = start;
      endDate.value = end;
    }

    filteredPosts = allPosts.where((post) {
      return true;
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
      debugPrint('Error fetching profile: $e');
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