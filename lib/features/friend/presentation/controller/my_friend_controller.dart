import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/data/friend_request_model.dart';
import 'package:giolee78/features/friend/data/suggested_friend_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/repo/get_my_all_friend_repo.dart';
import 'package:giolee78/utils/constants/app_images.dart';

import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_response_model.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';
import '../../data/my_friends_model.dart';

class MyFriendController extends GetxController {



  final RxMap<String, bool> friendRequestSent = <String, bool>{}.obs;

  // ================= Friend Requests
  var requests = <FriendData>[].obs;
  var isLoading = true.obs;

  // ================= My Friends List
  RxList<MyFriendsData> myFriendsList = <MyFriendsData>[].obs;

  // ================= Suggested Friends (Nearby)
  RxList<SuggestedFriendUserModel> suggestedFriendList =
      <SuggestedFriendUserModel>[].obs;

  RxBool isNearbyChatLoading = false.obs;
  RxString nearbyChatError = ''.obs;

  // ================= Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  RxBool isPaginationLoading = false.obs;

  bool get hasMoreData => _currentPage < _totalPages;

  // ================= Per-User Friend Status
  final RxMap<String, FriendStatus> friendStatusMap =
      <String, FriendStatus>{}.obs;
  final RxMap<String, String> pendingRequestIdMap = <String, String>{}.obs;
  final RxSet<String> loadingUserIds = <String>{}.obs;

  // ================= Search
  final RxString searchQuery = ''.obs;

  List<MyFriendsData> get filteredFriendsList {
    if (searchQuery.value.isEmpty) return myFriendsList;

    final query = searchQuery.value.toLowerCase();

    return myFriendsList.where((data) {
      final name = (data.friend?.name ?? '').toLowerCase();
      final email = (data.friend?.email ?? '').toLowerCase();

      return name.contains(query) || email.contains(query);
    }).toList();
  }

  // ================= Lifecycle
  @override
  Future<void> onInit() async {
    super.onInit();

    debugPrint("🚀 MyFriendController onInit called");
    debugPrint("📍 RAW Lat: ${LocalStorage.lat}");
    debugPrint("📍 RAW Long: ${LocalStorage.long}");
    debugPrint("📍 Lat type: ${LocalStorage.lat.runtimeType}");

    await fetchFriendRequests();
    await getMyAllFriends();
    await getSuggestedFriend();
    await _initLocationThenFetch();
    debugPrint("📍 Lat: ${LocalStorage.lat} | Long: ${LocalStorage.long}");
  }

  // ================= Per-User Helpers
  FriendStatus getFriendStatus(String userId) {
    return friendStatusMap[userId] ?? FriendStatus.none;
  }

  bool isUserLoading(String userId) {
    return loadingUserIds.contains(userId);
  }

  void sendFriendRequest(String userId) {
    friendRequestSent[userId] = true;
  }

  bool isRequestSent(String userId) {
    return friendRequestSent[userId] ?? false;
  }

  // ================= Get My All Friends
  Future<void> getMyAllFriends() async {
    try {
      isLoading.value = true;
      myFriendsList.value = await GetMyAllFriendsRepo().getFriendList();
    } catch (e) {
      debugPrint("Exception in getMyAllFriends: $e");
    } finally {
      isLoading.value = false;
      update();
    }
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

  Future<void> removeFriend(String friendshipId) async {
    try {
      final index = myFriendsList.indexWhere(
            (data) => data.id == friendshipId,
      );

      if (index == -1) return;
      final removedFriend = myFriendsList.removeAt(index);
      myFriendsList.refresh();

      final response = await ApiService.delete(
        ApiEndPoint.unfriend + friendshipId,
      );

      if (response.statusCode != 200) {
        myFriendsList.insert(index, removedFriend);
        myFriendsList.refresh();
        throw Exception("Failed to remove friend");
      }
    } catch (e) {
      print("Error removing friend: $e");
    }
  }

  RxList<FriendModel> friendRequestList = <FriendModel>[].obs;

  // ================= Fetch Friend Requests
  Future<void> fetchFriendRequests() async {
    try {
      isLoading.value = true;
      final url = ApiEndPoint.getMyFriendRequest;
      debugPrint("🔄 Fetching friend requests from: $url");

      final response = await ApiService.get(url);

      debugPrint("📦 Friend Requests API Status: ${response.statusCode}");
      debugPrint("📦 Friend Requests API Response: ${response.data}");

      if (response.statusCode == 200) {
        final model = FriendModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        debugPrint("✅ Parsed ${model.data.length} friend requests");
        model.data.forEach((req) {
          debugPrint("  - Request ID: ${req.id}, Status: ${req.status}, Sender: ${req.sender.name}");
        });

        requests.value = model.data;
        debugPrint("📝 Requests list updated. Now has ${requests.length} items");
      } else {
        debugPrint("❌ fetchFriendRequests error =====> ${response.data}");
      }
    } catch (e) {
      debugPrint("❌ fetchFriendRequests Exception: $e");
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= Accept Friend Request
  Future<void> acceptFriendRequest(String senderUserId, int index) async {
    try {
      final url = ApiEndPoint.friendStatusUpdate + senderUserId;
      final response = await ApiService.patch(
        url,
        body: {"status": 'accepted'},
      );

      if (response.statusCode == 200) {
        requests.removeAt(index);
        Get.snackbar(
          "Success",
          "Friend request accepted",
          colorText: Colors.white,
        );
      } else {
        debugPrint("acceptFriendRequest error => ${response.data}");
        Get.snackbar(
          "Info",
          response.data["message"] ?? "Cannot accept request",
        );
      }
    } catch (e) {
      debugPrint("acceptFriendRequest error => ${e.toString()}");
      Get.snackbar("Error", "Network error");
    }
  }

  // ================= Reject Friend Request
  Future<void> rejectFriendRequest(String senderUserId, int index) async {
    try {
      final url = ApiEndPoint.friendStatusUpdate + senderUserId;
      final response = await ApiService.patch(
        url,
        body: {"status": 'rejected'},
      );

      if (response.statusCode == 200) {
        requests.removeAt(index);
        Get.snackbar("Rejected", "Friend request rejected");
      } else {
        debugPrint("rejectFriendRequest error => ${response.data}");
        Get.snackbar("Rejected", "Friend request rejected");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error");
    }
  }

  Future<void> _initLocationThenFetch() async {
    try {
      debugPrint("🔄 _initLocationThenFetch started");

      final double? storedLat = LocalStorage.lat;
      final double? storedLng = LocalStorage.long;

      debugPrint("📦 Stored → Lat: $storedLat | Lng: $storedLng");

      if (storedLat != null &&
          storedLat != 0.0 &&
          storedLng != null &&
          storedLng != 0.0) {
        debugPrint("✅ Using stored location");
        await getSuggestedFriend();
        return;
      }

      debugPrint("📡 No stored location, requesting...");

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("🔐 Permission status: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint("🔐 After request: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        nearbyChatError.value =
        "Location permission permanently denied.\nPlease enable from settings.";
        debugPrint("❌ Permission denied forever");
        return;
      }

      if (permission == LocationPermission.denied) {
        nearbyChatError.value = "Location permission denied.";
        debugPrint("❌ Permission denied");
        return;
      }

      debugPrint("📡 Getting position...");
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint("⏱️ Location timeout! Trying last known...");
          throw Exception("Location timeout");
        },
      );

      debugPrint(
          "✅ Got position: ${position.latitude}, ${position.longitude}");

      LocalStorage.lat = position.latitude;
      LocalStorage.long = position.longitude;

      await getSuggestedFriend();
    } catch (e) {
      debugPrint("❌ _initLocationThenFetch error: $e");

      try {
        final Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint(
              "📍 Using last known: ${lastKnown.latitude}, ${lastKnown.longitude}");
          LocalStorage.lat = lastKnown.latitude;
          LocalStorage.long = lastKnown.longitude;
          await getSuggestedFriend();
        } else {
          nearbyChatError.value = "Could not get location. Please try again.";
        }
      } catch (e2) {
        debugPrint("❌ Last known position error: $e2");
        nearbyChatError.value = "Location error: $e";
      }
    }
  }

  // ================= Fetch Suggested Friends (Nearby)
  Future<void> getSuggestedFriend({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        suggestedFriendList.clear();
      }

      final double lat = LocalStorage.lat ?? 0.0;
      final double lng = LocalStorage.long ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        nearbyChatError.value =
        "Location not available. Please enable location.";
        debugPrint("❌ Invalid coordinates - Lat: $lat, Lng: $lng");
        return;
      }

      final url =
          "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&page=$_currentPage&limit=20";
      debugPrint(
          "🌐 Fetching Nearby - URL: $url | Page: $_currentPage");

      if (isRefresh) {
        isNearbyChatLoading.value = true;
      } else {
        isPaginationLoading.value = true;
      }
      nearbyChatError.value = '';

      final ApiResponseModel response = await ApiService.get(url);
      debugPrint("✅ Status: ${response.statusCode}");

      if (response.isSuccess) {
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages = pagination['totalPage'] ?? 1;
          _totalUsers = pagination['total'] ?? 0;
          debugPrint(
            "📊 Total: $_totalUsers | Pages: $_totalPages | Current: $_currentPage",
          );
        }

        final rawList = response.data['data'];
        if (rawList == null) {
          nearbyChatError.value = "No data found";
          debugPrint("❌ Data is null in response");
          return;
        }

        final List data = rawList as List;
        debugPrint("📋 Raw list count: ${data.length}");

        final List<SuggestedFriendUserModel> parsedList = [];
        for (int i = 0; i < data.length; i++) {
          try {
            final user = SuggestedFriendUserModel.fromJson(data[i]);
            parsedList.add(user);
            debugPrint(
              "✅ Parsed [$i]: ${user.name} | Distance: ${user.distance}",
            );
          } catch (e) {
            debugPrint("❌ Failed to parse user [$i]: $e | Raw: ${data[i]}");
          }
        }

        debugPrint("✅ Parsed: ${parsedList.length} / ${data.length} users");

        if (isRefresh) {
          suggestedFriendList.value = parsedList;
        } else {
          suggestedFriendList.addAll(parsedList);
        }

        debugPrint("📋 Total in list: ${suggestedFriendList.length}");

        for (final user in parsedList) {
          checkFriendship(user.id);
        }
      } else {
        nearbyChatError.value = response.message ?? "Something went wrong";
        debugPrint("❌ API Error: ${response.message}");
      }
    } catch (e) {
      nearbyChatError.value = e.toString();
      debugPrint("❌ Nearby Chat Error: $e");
    } finally {
      isNearbyChatLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  // ================= Load More (Pagination)
  Future<void> loadMore() async {
    if (!hasMoreData || isPaginationLoading.value) return;
    _currentPage++;
    debugPrint("📄 Loading page: $_currentPage");
    await getSuggestedFriend(isRefresh: false);
  }

  // ================= Check Friendship Status (per user)
  Future<void> checkFriendship(String userId) async {
    try {
      final response = await ApiService.get(
        "${ApiEndPoint.checkFriendStatus}$userId",
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data['isAlreadyFriend'] == true) {
          suggestedFriendList.removeWhere((user) => user.id == userId);
          friendStatusMap.remove(userId);
          friendStatusMap.refresh();
          debugPrint("🚫 Removed friend from suggested list: $userId");
        } else if (data['pendingFriendRequest'] != null) {
          friendStatusMap[userId] = FriendStatus.requested;
          pendingRequestIdMap[userId] =
              data['pendingFriendRequest']['_id'] ?? '';
          pendingRequestIdMap.refresh();
          friendStatusMap.refresh();
        } else {
          friendStatusMap[userId] = FriendStatus.none;
          friendStatusMap.refresh();
        }

        debugPrint(
          "🔍 checkFriendship [$userId] => ${friendStatusMap[userId]}",
        );
      }
    } catch (e) {
      debugPrint("Friendship Error [$userId]: $e");
    }
  }

  // ================= Add Friend
  Future<void> onTapAddFriendButton(String userId) async {
    try {
      loadingUserIds.add(userId);
      loadingUserIds.refresh();

      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": userId},
      );

      if (response.statusCode == 200) {
        final requestId = response.data['data']?['_id'];
        if (requestId != null) {
          pendingRequestIdMap[userId] = requestId;
          pendingRequestIdMap.refresh();
        }

        friendStatusMap[userId] = FriendStatus.requested;
        friendStatusMap.refresh();

        await fetchFriendRequests();
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      loadingUserIds.remove(userId);
      loadingUserIds.refresh();
    }
  }

  // ================= Cancel Friend Request
  Future<void> cancelFriendRequest(String userId) async {
    try {
      loadingUserIds.add(userId);
      loadingUserIds.refresh();

      final idToUse = (pendingRequestIdMap[userId]?.isNotEmpty == true)
          ? pendingRequestIdMap[userId]!
          : userId;

      final endpoint = "${ApiEndPoint.cancelFriendRequest}$idToUse";
      final response = await ApiService.patch(
        endpoint,
        body: {"status": "cancelled"},
      );

      if (response.statusCode == 200) {
        friendStatusMap[userId] = FriendStatus.none;
        friendStatusMap.refresh();

        pendingRequestIdMap.remove(userId);
        pendingRequestIdMap.refresh();

      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      loadingUserIds.remove(userId);
      loadingUserIds.refresh();
    }
  }
}