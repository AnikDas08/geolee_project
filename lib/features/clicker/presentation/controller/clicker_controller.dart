import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/clicker/data/all_post_model.dart';
import 'package:giolee78/features/clicker/data/single_user_model.dart';
import 'package:giolee78/features/friend/presentation/controller/my_friend_controller.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:http/http.dart' as http;
import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../friend/data/post_model_by_id.dart';
import '../../data/addbanner_model.dart';
import 'package:giolee78/utils/enum/enum.dart';

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
  List<PostById> _allUserPostsRaw = []; // Store raw posts for re-filtering
  var isUserLoading = false.obs;

  /// ================= Friend Status
  var friendStatus = FriendStatus.none.obs;
  var pendingRequestId = ''.obs;


  @override
  void onInit() {
    super.onInit();
    debugPrint("🚀 ClickerController onInit called");
    getAllPosts();
    _getUniqueDeviceId();
    getCurrentLocation();
    updateProfileAndLocationVisible();

    debugPrint("🔑 LocalStorage token: ${LocalStorage.token.isNotEmpty ? 'PRESENT' : 'EMPTY'}");

    // Always call getBanners to see if it works for everyone
    debugPrint("📡 Calling getBanners() from onInit (Global)");

    if (LocalStorage.token.isNotEmpty) {
      getBanners();
      searchController.addListener(_onSearchChanged);

      // Trigger location suggestions as user types, with 500ms debounce
      debounce(searchText, (String? value) {
        if (value != null) {
          fetchLocationSuggestions(value);
        }
      }, time: const Duration(milliseconds: 500));

      // Listen for friendship status changes to refresh user posts
      if (Get.isRegistered<MyFriendController>()) {
        final friendC = Get.find<MyFriendController>();
        ever(friendC.friendStatusMap, (_) {
          _filterPosts();
          _filterUserPosts();
        });
      }
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    super.onClose();
  }

  Future<void> updateProfileAndLocationVisible() async {
    try {
      final latitude = LocalStorage.lat.toDouble();
      final longitude = LocalStorage.long.toDouble();

      // API call
      final response = await ApiService.patch(
        ApiEndPoint.updateProfile,

        body: {
          // 'isLocationVisible': false,
          "location": [longitude, latitude],
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Profile location updated');
      } else {
        debugPrint('Failed to update profile: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }


  /// ================= Location Suggestions
  var locationSuggestions = <String>[].obs;
  var isSearchingSuggestions = false.obs;
  final String _googleApiKey = 'AIzaSyAp3rwzXU0fAqaPCTRfx81ixNMu5flXnPo';

// Call this to fetch Google Places suggestions
  Future<void> fetchLocationSuggestions(String input) async {
    if (input.isEmpty) {
      locationSuggestions.clear();
      return;
    }

    try {
      isSearchingSuggestions.value = true;
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeComponent(input)}'
            '&key=$_googleApiKey'
            '&types=geocode',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        locationSuggestions.assignAll(
          predictions.map((p) => p['description'] as String).toList(),
        );
      }
    } catch (e) {
      debugPrint("Suggestion Error: $e");
    } finally {
      isSearchingSuggestions.value = false;
    }
  }



  void onLocationSelected(String location) {
    searchController.text = location;
    searchText.value = location;
    locationSuggestions.clear();
    getAllPosts(searchTerm: location); // search in DB
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
        body: {"participant": receiverId},
      );

      if (response.isSuccess) {
        final data = response.data["data"];
        final String chatId = data["_id"] ?? "";

        if (chatId.isNotEmpty) {
          Get.toNamed(
            AppRoutes.message,
            parameters: {
              "chatId": chatId,
              "name": name,
              "image": image,
              "userId": receiverId,
            },
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ================= Fetch Dynamic Banners
  Future<void> getBanners() async {
    debugPrint("📡 [getBanners] Started");
    try {
      isBannerLoading.value = true;

      debugPrint("📡 [getBanners] Fetching location (with 5s timeout)...");
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        debugPrint("📡 [getBanners] Location fetched: ${position.latitude}, ${position.longitude}");
      } catch (e) {
        debugPrint("📡 [getBanners] Location error or timeout: $e. Using fallback (0,0).");
        position = Position(
          longitude: 0.0,
          latitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }

      final String deviceId = await _getUniqueDeviceId();
      final String path = ApiEndPoint.nearbyActiveAds;

      final String url =
          "$path"
          "?lng=${position.longitude}"
          "&lat=${position.latitude}"
          "&deviceId=$deviceId";

      debugPrint("🌐 Fetching Banners URL: ${ApiEndPoint.baseUrl}$url");
      final response = await ApiService.get(url);

      debugPrint("📡 [getBanners] Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        debugPrint("✅ Banner Ads Received: ${data.length}");
        adList.assignAll(data.map((e) => AdBannerModel.fromJson(e)).toList());

        // Log ad images to verify URLs
        for (var ad in adList) {
          debugPrint("🖼️ Ad image: ${ad.image}");
        }

        adList.refresh(); // Force refresh for UI
      } else {
        debugPrint("❌ [getBanners] Error response: ${response.data}");
      }
    } catch (e) {
      debugPrint("❌ [getBanners] Exception: $e");
    } finally {
      isBannerLoading.value = false;
    }
  }

  Future<void> getAllPosts({String? clickerType, bool isLoadMore = false, String? searchTerm,}) async {
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
      queryParams.add("limit=50");

      final String filter = clickerType ?? selectedFilter;
      if (filter != 'All') queryParams.add("clickerType=$filter");

      final term = searchTerm ?? searchText.value;
      if (term.isNotEmpty) queryParams.add("searchTerm=${Uri.encodeComponent(term)}");

      if (queryParams.isNotEmpty) url += "?${queryParams.join('&')}";
      debugPrint("🌐 Fetching Posts: $url");

      final response = await ApiService.get(url);

        if (response.statusCode == 200) {
        final AllPostModel responseData = AllPostModel.fromJson(response.data);
        totalPages.value = responseData.pagination.totalPage;

        debugPrint("✅ Received ${responseData.data.length} posts from server");

        if (isLoadMore) {
          posts.addAll(responseData.data);
        } else {
          posts.assignAll(responseData.data);
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

  void _onSearchChanged() {
    searchText.value = searchController.text;
    _filterPosts();
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

        debugPrint(
          "✅ [getPostsByUserId] Parsed ${responseData.data.length} posts",
        );

        _allUserPostsRaw = responseData.data;
        _filterUserPosts();

        debugPrint(
          "✅ [getPostsByUserId] usersPosts updated: ${usersPosts.length} posts (Filtered from ${_allUserPostsRaw.length})",
        );
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
      final String url = "/advertisements/track-click/$bannerId";
      final response = await ApiService.post(url);
      if (response.statusCode == 200) {
        debugPrint("Banner click tracked: $bannerId");
      }
    } catch (e) {
      debugPrint("Error tracking banner click: $e");
    }
  }

  void _filterPosts() {
    List<PostData> filtered = posts.toList();


    debugPrint("🔍 Total posts received from server: ${posts.length}");
    filtered = filtered.where((post) {
      final p = post.privacy.toLowerCase().trim();
      final isPublic = p == 'public';

      // LOG EVERY POST'S PRIVACY
      debugPrint("📦 Post ${post.id} | Privacy: [${post.privacy}] | Render: $isPublic");

      return isPublic;
    }).toList();

    if (selectedFilter != 'All') {
      filtered = filtered
          .where((post) => post.clickerType == selectedFilter)
          .toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      filtered = filtered
          .where((post) =>
      post.user.name.toLowerCase().contains(query) ||
          post.description.toLowerCase().contains(query) ||
          post.address.toLowerCase().contains(query))
          .toList();
    }

    filteredPosts.assignAll(filtered);
  }

  void changePosition(int position) => _currentPosition.value = position;

  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
    getAllPosts(clickerType: newFilter);
  }

  // ================= Friendship Logic=============
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
        _filterUserPosts();
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

        // 🔄 Refresh friend requests in MyFriendController so badge updates on home screen
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        }
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    }
  }

  Future<void> cancelFriendRequest(String userId) async {
    // Save previous state for rollback
    final previousStatus = friendStatus.value;

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
      } else {
        // Rollback
        friendStatus.value = previousStatus;
        Utils.errorSnackBar("Failed", response.data['message'] ?? "Could not cancel request");
      }
    } catch (e) {
      // Rollback
      friendStatus.value = previousStatus;
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= Private Helper: Filter User Posts
  void _filterUserPosts() {
    if (_allUserPostsRaw.isEmpty) {
      usersPosts.clear();
      return;
    }

    final String currentUserId = LocalStorage.userId;
    final MyFriendController friendC = Get.isRegistered<MyFriendController>()
        ? Get.find<MyFriendController>()
        : Get.put(MyFriendController());

    final List<PostById> filtered = _allUserPostsRaw.where((post) {

      if (post.user.id == currentUserId) return true;

      final privacy = post.privacy.toLowerCase().trim();

      if (privacy == 'only me' || privacy == 'onlyme') return false;

      if (privacy == 'friend' || privacy == 'friends') {
        final status = friendC.getFriendStatus(post.user.id);
        return status == FriendStatus.friends;
      }

      if (privacy == 'public') return true;

      return false;
    }).toList();

    usersPosts.assignAll(filtered);
    usersPosts.refresh();
  }

}
