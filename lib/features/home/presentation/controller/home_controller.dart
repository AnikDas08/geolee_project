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
import 'package:geolocator/geolocator.dart';

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

  RxBool IsLoading = false.obs;

  var clickerCount = RxnString();
  var filterOption = RxnString();

  // Filter parameters
  var selectedPeriod = 'Last 24 Hours'.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  String? argument;

  // --- Heatmap Variables ---
  Set<Heatmap> heatmaps = {};

  // --- Current Location Variables ---
  RxDouble currentLatitude = 0.0.obs;
  RxDouble currentLongitude = 0.0.obs;
  RxBool isLocationUpdating = false.obs;

  List<String> clickerOptions = ["All", "Great Vibes", "Off Vibes", "Charming Gentleman", "Lovely Lady"];
  List<String> filterOptions = ["Option 1", "Option 2", "Option 3"];
  final MyProfileController myProfileController = Get.put(MyProfileController());

  @override
  void onInit() {
    super.onInit();
    try {
      argument = Get.arguments;
      Get.find<HomeNavController>().refresh();
      Get.find<MyProfileController>().refresh();
      myProfileController.getUserData();

      if (LocalStorage.token != null && LocalStorage.token!.isNotEmpty) {
        // Get current location and update profile
        getCurrentLocationAndUpdateProfile();

        fetchPosts();
        myProfileController.getUserData();
      } else {
        allPosts = [];
        filteredPosts = [];
        isLoading = false;
        // Load static heatmap if no posts available
        update();
      }
    } catch (e) {
      debugPrint('Error in onInit: $e');
      update();
    }
  }


  // --- Method to Generate Heatmap from Post Coordinates ---
  void _generateHeatmapFromPosts(List<Post> posts) {
    try {
      if (posts.isEmpty) {
        debugPrint('No posts available, loading static heatmap');
        return;
      }

      List<WeightedLatLng> heatmapPoints = [];
      int validCoordinatesCount = 0;
      int invalidCoordinatesCount = 0;

      for (var post in posts) {
        try {
          // Check if coordinates are valid
          if (post.lat != 0 && post.long != 0) {
            // Validate coordinate ranges
            if (post.lat >= -90 && post.lat <= 90 && post.long >= -180 && post.long <= 180) {
              // Create weighted point - you can adjust weight based on post properties
              double weight = 1.0;

              // Optional: Adjust weight based on clicker type or other criteria
              try {
                if (post.clickerType == "Great Vibes") {
                  weight = 2.0;
                } else if (post.clickerType == "Off Vibes") {
                  weight = 1.5;
                } else if (post.clickerType == "Charming Gentleman" || post.clickerType == "Lovely Leady") {
                  weight = 2.5;
                }
              } catch (e) {
                debugPrint('Error determining weight for post ${post.id}: $e');
                weight = 1.0; // Default weight
              }

              heatmapPoints.add(
                WeightedLatLng(
                  LatLng(post.lat, post.long),
                  weight: weight,
                ),
              );
              validCoordinatesCount++;
            } else {
              invalidCoordinatesCount++;
              debugPrint('Invalid coordinate range for post ${post.id}: lat=${post.lat}, long=${post.long}');
            }
          } else {
            invalidCoordinatesCount++;
            debugPrint('Zero coordinates for post ${post.id}');
          }
        } catch (e) {
          debugPrint('Error processing post ${post.id}: $e');
          invalidCoordinatesCount++;
        }
      }

      debugPrint('Heatmap generation: $validCoordinatesCount valid, $invalidCoordinatesCount invalid coordinates');

      // If we have valid points, create heatmap
      if (heatmapPoints.isNotEmpty) {
        try {
          heatmaps = {
            Heatmap(
              heatmapId: const HeatmapId("posts_activity"),
              data: heatmapPoints,
              radius: HeatmapRadius.fromPixels(50),
              opacity: 0.8,
            )
          };
          debugPrint('Heatmap created successfully with ${heatmapPoints.length} points');
        } catch (e) {
          debugPrint('Error creating heatmap object: $e');
        }
      } else {
        // No valid points, load static heatmap
        debugPrint('No valid heatmap points, loading static heatmap');
      }

      update();
    } catch (e) {
      debugPrint('Error in _generateHeatmapFromPosts: $e');
    }
  }

  void applyFilter(String period, DateTime start, DateTime end) {
    try {
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

      // Fetch posts with current filter
      fetchPostsWithFilter();

      update();
    } catch (e) {
      debugPrint('Error in applyFilter: $e');
      Get.snackbar(
        'Filter Error',
        'Failed to apply filter. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Apply clicker type filter (Local filtering - no API call)
  // Apply clicker type filter (API call with filter)
  void applyClickerFilter(String? clickerType) async {
    try {
      clickerCount.value = clickerType;

      debugPrint('Applying clicker filter: $clickerType');

      // Fetch posts with filter from API
      await fetchPostsWithFilter();

    } catch (e) {
      debugPrint('Error in applyClickerFilter: $e');
      Get.snackbar(
        'Filter Error',
        'Failed to apply clicker filter. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Fetch posts with active filters from API
  Future<void> fetchPostsWithFilter() async {
    try {
      isLoading = true;
      update();

      // Build URL with query parameters
      String url = "${ApiEndPoint.post}?limit=100";

      // Add clickerType filter if selected and not "All"
      if (clickerCount.value != null && clickerCount.value != "All") {
        url += "&clickerType=${Uri.encodeComponent(clickerCount.value!)}&limit=100";
      }

      debugPrint('Fetching posts with filter URL: $url');

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        try {
          final postResponse = PostResponseModel.fromJson(response.data);
          allPosts = postResponse.data;
          filteredPosts = allPosts;

          debugPrint('Fetched ${allPosts.length} posts successfully with filter: ${clickerCount.value}');

          // Generate heatmap from fetched posts
          _generateHeatmapFromPosts(allPosts);
        } catch (e) {
          debugPrint('Error parsing post response: $e');
          allPosts = [];
          filteredPosts = [];
          Get.snackbar(
            'Data Error',
            'Failed to parse posts data',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.7),
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint('Failed to fetch posts: Status code ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch posts. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error fetching posts with filter: $e');
      allPosts = [];
      filteredPosts = [];
      Get.snackbar(
        'Network Error',
        'Failed to load posts. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // Fetch posts with filters (clickerType, date range, etc.)
  Future<void> fetchPosts() async {
    try {
      isLoading = true;
      update();

      final response = await ApiService.get(
        "${ApiEndPoint.post}?limit=100",
      );

      if (response.statusCode == 200) {
        try {
          final postResponse = PostResponseModel.fromJson(response.data);
          allPosts = postResponse.data;
          filteredPosts = allPosts;

          debugPrint('Fetched ${allPosts.length} posts successfully');

          // Generate heatmap from fetched posts
          _generateHeatmapFromPosts(allPosts);
        } catch (e) {
          debugPrint('Error parsing post response: $e');
          allPosts = [];
          filteredPosts = [];
          Get.snackbar(
            'Data Error',
            'Failed to parse posts data',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.7),
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint('Failed to fetch posts: Status code ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch posts. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      allPosts = [];
      filteredPosts = [];
      // Load static heatmap on error
      Get.snackbar(
        'Network Error',
        'Failed to load posts. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  /*void getProfile() async {
    try {
      final response = await ApiService.get(
        "user/profile",
      );

      if (response.statusCode == 200) {
        try {
          name.value = response.data["data"]["name"] ?? "";
          image.value = response.data["data"]["image"] ?? "";
          if (response.data["data"].isNotEmpty) {
            notificationCount = 0;
          }
        } catch (e) {
          debugPrint('Error parsing profile data: $e');
        }
      } else {
        debugPrint('Failed to fetch profile: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      isLoading = false;
      update();
    }
  }*/

  // Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        Get.snackbar(
          'Location Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Get current location and update profile
  Future<void> getCurrentLocationAndUpdateProfile() async {
    try {
      isLocationUpdating.value = true;

      Position? position = await getCurrentLocation();

      if (position != null) {
        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;

        debugPrint('Updating profile with location: [${position.longitude}, ${position.latitude}]');

        // Update profile with new location
        //await updateProfile(position.longitude, position.latitude);
      } else {
        debugPrint('Could not get current location');
      }
    } catch (e) {
      debugPrint('Error in getCurrentLocationAndUpdateProfile: $e');
    } finally {
      isLocationUpdating.value = false;
    }
  }

  // Update user profile with location
  /*Future<void> updateProfile(double longitude, double latitude) async {
    try {
      Map<String, dynamic> body = {
        "location": [longitude, latitude]
      };

      debugPrint('Updating profile with body: $body');

      final response = await ApiService.patch(
        "users/profile",
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint('Profile location updated successfully');
        debugPrint('Response: ${response.data}');
      } else {
        debugPrint('Failed to update profile: Status code ${response.statusCode}');
        debugPrint('Response: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      // Don't show error to user as this is a background operation
    }
  }*/

  void searchPosts(String query) {
    try {
      searchQuery = query.toLowerCase();

      if (searchQuery.isEmpty) {
        filteredPosts = allPosts;
      } else {
        filteredPosts = allPosts.where((post) {
          try {
            return post.title.toLowerCase().contains(searchQuery) ||
                post.description.toLowerCase().contains(searchQuery) ||
                post.user.name.toLowerCase().contains(searchQuery);
          } catch (e) {
            debugPrint('Error searching post: $e');
            return false;
          }
        }).toList();
      }

      // Update heatmap based on search results
      _generateHeatmapFromPosts(filteredPosts);

      update();
    } catch (e) {
      debugPrint('Error in searchPosts: $e');
      Get.snackbar(
        'Search Error',
        'Failed to search posts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchFriendRequests() async {
    try {
      final url = "${ApiEndPoint.getMyFriendRequest}";
      IsLoading.value = true;

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        try {
          debugPrint("response => ${response.data}");

          final dataList = response.data['data'] as List<dynamic>;
          friendRequestsList.value = dataList
              .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint("Error parsing friend requests: $e");
          friendRequestsList.value = [];
        }
      } else {
        debugPrint("Error response => ${response.data}");
      }
    } catch (e) {
      debugPrint('Error fetching friend requests: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch friend requests',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      IsLoading.value = false;
    }
  }

  // Method to refresh everything
  Future<void> refreshAll() async {
    try {
      await fetchPosts();
      await fetchFriendRequests();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }

  // Clear heatmap
  void clearHeatmap() {
    try {
      heatmaps = {};
      update();
    } catch (e) {
      debugPrint('Error clearing heatmap: $e');
    }
  }
}