import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/clicker/data/all_post_model.dart';
import 'package:giolee78/features/clicker/data/single_user_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/app_utils.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../friend/data/post_model_by_id.dart';
import '../../data/addbanner_model.dart';

enum FriendStatus { none, requested, friends }

class ClickerController extends GetxController {
  /// ================= Search & UI State
  final searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();

  /// ================= Carousel
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
    'All',
    'Great Vibes',
    'Off Vibes',
    'Charming Gentleman',
    'Lovely Lady',
  ];

  /// ================= Post Data
  var posts = <PostData>[].obs;
  var filteredPosts = <PostData>[].obs;
  var isLoading = false.obs;

  /// ================= Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isLoadingMore = false.obs;

  /// ================= User Profile & Specific Posts
  Rxn<SingleUserByIdData> userData = Rxn<SingleUserByIdData>();
  var usersPosts = <PostById>[].obs;
  var isUserLoading = false.obs;

  /// ================= Friend Status
  var friendStatus = FriendStatus.none.obs;
  var pendingRequestId = ''.obs;


  @override
  void onInit() {
    super.onInit();
    getAllPosts();
    _getUniqueDeviceId();
    getCurrentLocation();
    if (LocalStorage.token.isNotEmpty) {
      getBanners();
      searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    super.onClose();
  }

  Future<void> createOrGetChatAndGo({
    required String receiverId,
    required String name,
    required String image,
  }) async {
    try {
      isLoading.value = true;

      final response = await ApiService.post(
        ApiEndPoint.createOneToOneChat,
        body: {
          "participant": receiverId,
        },
      );

      if (response.isSuccess) {
        final data = response.data["data"];
        String chatId = data["_id"] ?? "";

        if (chatId.isNotEmpty) {
          Get.toNamed(
            AppRoutes.message,
            parameters: {
              "chatId": chatId,
              "name": name,
              "image": image,
            },
          );
        } else {
          print("Chat ID null or empty");
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
  // ================= Fetch Dynamic Banners
  Future<void> getBanners() async {
    try {
      isBannerLoading.value = true;

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final String deviceId = await _getUniqueDeviceId();

      final String url = "advertisements/nearby-active"
          "?lng=${position.longitude}"
          "&lat=${position.latitude}"
          "&deviceId=$deviceId";

      final response = await ApiService.get(url);

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

  // ================= Get All Posts (with Pagination)
  Future<void> getAllPosts({String? clickerType, bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        if (currentPage.value >= totalPages.value) return;
        isLoadingMore.value = true;
        currentPage.value += 1;
      } else {
        isLoading.value = true;
        currentPage.value = 1;
        posts.clear();
        filteredPosts.clear();
      }

      String url = ApiEndPoint.getAllPost;
      final List<String> queryParams = [];

      queryParams.add("page=${currentPage.value}");
      queryParams.add("limit=10");

      final String filter = clickerType ?? selectedFilter;
      if (filter != 'All') queryParams.add("clickerType=$filter");
      if (LocalStorage.token.isEmpty) queryParams.add("privacy=public");

      if (queryParams.isNotEmpty) url += "?${queryParams.join('&')}";

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final AllPostModel responseData = AllPostModel.fromJson(response.data);

        totalPages.value = responseData.pagination.totalPage;

        final visiblePosts = responseData.data.where((post) {
          return post.privacy == 'public';
        }).toList();
        if (isLoadMore) {
          posts.addAll(visiblePosts);
        } else {
          posts.assignAll(visiblePosts);
        }

        _filterPosts();
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ================= Get Posts By Specific User ID
  Future<void> getPostsByUserId(String userId) async {
    try {
      debugPrint("🌐 [getPostsByUserId] Starting - userId: $userId");
      isUserLoading.value = true;
      usersPosts.clear();

      final url = "${ApiEndPoint.getUserById}$userId";
      debugPrint("🌐 [getPostsByUserId] URL: $url");

      final response = await ApiService.get(url);

      debugPrint("🌐 [getPostsByUserId] Status: ${response.statusCode}");
      debugPrint("🌐 [getPostsByUserId] Response: ${response.data}");

      if (response.statusCode == 200) {
        final responseData = PostResponseById.fromJson(
          response.data as Map<String, dynamic>,
        );

        debugPrint("✅ [getPostsByUserId] Parsed ${responseData.data.length} posts");

        usersPosts.assignAll(responseData.data);
        usersPosts.refresh(); // 🔥 Force refresh

        debugPrint("✅ [getPostsByUserId] usersPosts updated: ${usersPosts.length} posts");
      } else {
        debugPrint("❌ [getPostsByUserId] Error status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ [getPostsByUserId] Exception: $e");
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
      final response = await ApiService.get(
        "${ApiEndPoint.getUserSingleProfileById}$userId",
      );
      if (response.statusCode == 200) {
        final responseData = SingleUserByIdModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        userData.value = responseData.data;
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  // ================= Get Current Location
  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading.value = true;

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        userAddress.value =
            place.locality ?? place.subAdministrativeArea ?? "Unknown";
      }
    } catch (e) {
      userAddress.value = "Location Error";
      debugPrint("Location Error: $e");
    } finally {
      isLocationLoading.value = false;
    }
  }



  // ================= Device ID
  Future<String> _getUniqueDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown_ios_id";
    }
    return "unknown_device";
  }

  // ================= Banner Click Tracking
  Future<void> clickBanner(String bannerId) async {
    try {
      final String url = "advertisements/track-click/$bannerId";
      final response = await ApiService.post(url);
      if (response.statusCode == 200) {
        debugPrint("Banner click tracked: $bannerId");
      }
    } catch (e) {
      debugPrint("Error tracking banner click: $e");
    }
  }

  // ================= Search/Filter Logic
  void _onSearchChanged() {
    searchText.value = searchController.text;
    _filterPosts();
  }

  void _filterPosts() {
    List<PostData> filtered = posts.toList();

    filtered = filtered.where((post) {
      if (post.privacy == 'public') return true;
      return post.user.id == LocalStorage.userId;
    }).toList();

    if (selectedFilter != 'All') {
      filtered = filtered
          .where((post) => post.clickerType == selectedFilter)
          .toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      filtered = filtered
          .where(
            (post) =>
        post.user.name.toLowerCase().contains(query) ||
            post.description.toLowerCase().contains(query) ||
            post.address.toLowerCase().contains(query),
      )
          .toList();
    }

    filteredPosts.assignAll(filtered);
  }

  void changePosition(int position) => _currentPosition.value = position;

  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
    getAllPosts(clickerType: newFilter);
  }

  // ================= Friendship Logic
  Future<void> checkFriendship(String userId) async {
    try {
      final response = await ApiService.get(
        "${ApiEndPoint.checkFriendStatus}$userId",
      );
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
    } catch (e) {
      debugPrint("Friendship Error: $e");
    }
  }

  Future<void> onTapAddFriendButton(String userId) async {
    try {
      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": userId},
      );
      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.requested;
        Utils.successSnackBar("Sent", "Friend request sent");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    }
  }

  Future<void> cancelFriendRequest(String userId) async {
    try {
      isLoading.value = true;
      final idToUse = pendingRequestId.value.isNotEmpty
          ? pendingRequestId.value
          : userId;
      final endpoint = "${ApiEndPoint.cancelFriendRequest}$idToUse";

      final response = await ApiService.patch(
        endpoint,
        body: {"status": "cancelled"},
      );

      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.none;
        pendingRequestId.value = '';
        Utils.successSnackBar("Cancelled", "Friend request cancelled");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}