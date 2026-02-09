import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/features/clicker/data/all_post_model.dart';
import 'package:giolee78/features/clicker/data/single_user_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/app_utils.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../friend/data/post_model_by_id.dart';
import '../../data/addbanner_model.dart';

enum FriendStatus { none, requested, friends }

class ClickerController extends GetxController {
  /// ================= Search & UI State
  final searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final _currentPosition = 0.obs;
  int get currentPosition => _currentPosition.value;

  /// ================= Banners & Filters
  var adList = <AdBannerModel>[].obs;
  var isBannerLoading = false.obs;
  final _selectedFilter = 'All'.obs;
  String get selectedFilter => _selectedFilter.value;
  var userAddress = "Fetching location...".obs;
  var isLocationLoading = false.obs;

  final List<String> filterOptions = [
    'All', 'Great Vibes', 'Off Vibes', 'Charming Gentleman', 'Lovely Lady',
  ];

  /// ================= Post Data
  var posts = <PostData>[].obs;
  var filteredPosts = <PostData>[].obs;
  var isLoading = false.obs;

  // ================= User Profile & Specific Posts
  Rxn<SingleUserByIdData> userData = Rxn<SingleUserByIdData>();
  var usersPosts = <PostById>[].obs;
  var isUserLoading = false.obs;

  // ================= Friend Status
  var friendStatus = FriendStatus.none.obs;
  var pendingRequestId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getAllPosts();
    getCurrentLocation(); // Fetch location on startup
    if (LocalStorage.token.isNotEmpty) {
      getBanners();
      searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  // ================= Fetch Dynamic Banners
  Future<void> getBanners() async {
    try {
      isBannerLoading.value = true;
      final response = await ApiService.get("advertisements/nearby-active/");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        adList.assignAll(data.map((e) => AdBannerModel.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint("Banner Error: $e");
    } finally {
      isBannerLoading.value = false;
    }
  }

  // ================= Get All Posts
  Future<void> getAllPosts({String? clickerType}) async {
    try {
      isLoading.value = true;
      String url = ApiEndPoint.getAllPost;
      List<String> queryParams = [];

      String filter = clickerType ?? selectedFilter;
      if (filter != 'All') queryParams.add("clickerType=$filter");
      if (LocalStorage.token.isEmpty) queryParams.add("privacy=public");

      if (queryParams.isNotEmpty) url += "?${queryParams.join('&')}";

      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        final responseData = AllPostModel.fromJson(response.data);
        posts.assignAll(responseData.data);
        _filterPosts();
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= Get Posts By Specific User ID (The one you missed!)
  Future<void> getPostsByUser(String userId) async {
    try {
      isUserLoading.value = true;
      usersPosts.clear();

      final url = "${ApiEndPoint.getUserById}$userId";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = PostResponseById.fromJson(response.data as Map<String, dynamic>);
        // Filter out "only me" posts for public/friend viewing
        final filtered = responseData.data
            .where((post) => post.privacy.toLowerCase() != "only me")
            .toList();
        usersPosts.assignAll(filtered);
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  // ================= Get User Profile Info
  Future<void> getUserById(String userId) async {
    try {
      isUserLoading.value = true;
      userData.value = null;
      final response = await ApiService.get("${ApiEndPoint.getUserSingleProfileById}$userId");
      if (response.statusCode == 200) {
        final responseData = SingleUserByIdModel.fromJson(response.data as Map<String, dynamic>);
        userData.value = responseData.data;
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading.value = true;

      // 1. Check Service & Permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        userAddress.value = "Location services disabled";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          userAddress.value = "Permission denied";
          return;
        }
      }

      // 2. Get Position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low // Low accuracy is faster and enough for city names
      );

      // 3. Get City Name
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // locality usually gives the city (e.g., "Dhaka" or "New York")
        userAddress.value = place.locality ?? place.subAdministrativeArea ?? "Unknown";
      }
    } catch (e) {
      userAddress.value = "Location Error";
      debugPrint("Location Error: $e");
    } finally {
      isLocationLoading.value = false;
    }
  }

  // ================= Search/Filter Logic
  void _onSearchChanged() {
    searchText.value = searchController.text;
    _filterPosts();
  }

  void _filterPosts() {
    List<PostData> filtered = posts;
    if (selectedFilter != 'All') {
      filtered = filtered.where((post) => post.clickerType == selectedFilter).toList();
    }
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      filtered = filtered.where((post) =>
      post.user.name.toLowerCase().contains(query) ||
          post.description.toLowerCase().contains(query) ||
          post.address.toLowerCase().contains(query)).toList();
    }
    filteredPosts.assignAll(filtered);
  }

  void changePosition(int position) => _currentPosition.value = position;
  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
    getAllPosts(clickerType: newFilter);
  }
  Future<void> cancelFriendRequest(String userId) async {
    try {
      isLoading.value = true;
      // Use pendingRequestId if available, otherwise fallback to userId
      final idToUse = pendingRequestId.value.isNotEmpty ? pendingRequestId.value : userId;
      final endpoint = "${ApiEndPoint.cancelFriendRequest}$idToUse";

      final response = await ApiService.patch(endpoint, body: {"status": "cancelled"});

      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.none;
        pendingRequestId.value = '';
        Utils.successSnackBar("Cancelled", "Friend request cancelled successfully");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  // ================= Friendship Logic
  Future<void> checkFriendship(String userId) async {
    try {
      final response = await ApiService.get("${ApiEndPoint.checkFriendStatus}$userId");
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data['isAlreadyFriend'] == true) {
          friendStatus.value = FriendStatus.friends;
        } else if (data['pendingFriendRequest'] != null) {
          friendStatus.value = FriendStatus.requested;
          pendingRequestId.value = data['pendingFriendRequest']['_id'] ?? '';
        } else {
          friendStatus.value = FriendStatus.none;
        }
      }
    } catch (e) { debugPrint("Friendship Error: $e"); }
  }

  Future<void> onTapAddFriendButton(String userId) async {
    try {
      final response = await ApiService.post(ApiEndPoint.createFriendRequest, body: {"receiver": userId});
      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.requested;
        Utils.successSnackBar("Sent", "Friend request sent");
      }
    } catch (e) { Utils.errorSnackBar("Error", e.toString()); }
  }
}