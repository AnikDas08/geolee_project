import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/friend/data/friend_request_model.dart';
import 'package:giolee78/features/friend/data/suggested_friend_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/repo/get_my_all_friend_repo.dart';
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
  final RxSet<String> processingRequestIds = <String>{}.obs;

  // ================= Search
  final RxString searchQuery = ''.obs;


  ///TODO======================================
  List<MyFriendsData> get filteredFriendsList {
    if (searchQuery.value.isEmpty) return myFriendsList;

    final query = searchQuery.value.toLowerCase();

    return myFriendsList.where((data) {
      final email = (data.friend?.email ?? '').toLowerCase();
      // Only full email match
      return email == query;
    }).toList();
  }

/*
  List<MyFriendsData> get filteredFriendsList {
    if (searchQuery.value.isEmpty) return myFriendsList;

    final query = searchQuery.value.toLowerCase();

    return myFriendsList.where((data) {
      final name = (data.friend?.name ?? '').toLowerCase();
      final email = (data.friend?.email ?? '').toLowerCase();

      return name.contains(query) || email.contains(query);
    }).toList();
  }
*/

  // ================= Suggested Friends Filtering
  List<SuggestedFriendUserModel> get filteredSuggestedFriends {
    final currentUserId = LocalStorage.userId;

    // Get all friend IDs from the main list
    final friendIds = myFriendsList
        .map((data) => data.friend?.id)
        .whereType<String>()
        .toSet();

    // Filter suggested list
    return suggestedFriendList.where((user) {
      // 1. Exclude myself
      if (user.id == currentUserId) return false;

      // 2. Exclude if already in myFriendsList
      if (friendIds.contains(user.id)) return false;

      // 3. Exclude if they are already friends
      final status = getFriendStatus(user.id);
      if (status == FriendStatus.friends) return false;

      // 4. Local Filter (Backup if DB search returns too many or unfiltered results)
      ///TODO=========================================
  /*    if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesEmail = (user.email).toLowerCase() == query; // Full match
        if (!matchesEmail) return false;
      }*/

      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesName = (user.name).toLowerCase().contains(query);
        final matchesEmail = (user.email).toLowerCase().contains(query);
        if (!matchesName && !matchesEmail) return false;
      }

      return true;
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

    debounce(searchQuery, (query) async {
      if (query.isEmpty) {
        // Restore both lists from server
        await Future.wait([getMyAllFriends(), getSuggestedFriend()]);
      } else {
        // Search both sections on the server simultaneously
        await Future.wait([
          getMyAllFriends(searchTerm: query),
          searchGlobalUsers(query),
        ]);
      }
    }, time: const Duration(milliseconds: 500));
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
  Future<void> getMyAllFriends({String? searchTerm}) async {
    try {
      isLoading.value = true;
      myFriendsList.value = await GetMyAllFriendsRepo().getFriendList(
        searchTerm: searchTerm,
      );

      // Sync friendStatusMap for all confirmed friends
      for (var f in myFriendsList) {
        final userId = f.friend?.id;
        if (userId != null && userId.isNotEmpty) {
          friendStatusMap[userId] = FriendStatus.friends;
        }
      }
      friendStatusMap.refresh();
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
      final index = myFriendsList.indexWhere((data) => data.id == friendshipId);

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

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final model = FriendModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        final sorted = model.data
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        requests.value = sorted;
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
  Future<void> acceptFriendRequest(String requestId) async {
    if (processingRequestIds.contains(requestId)) return;

    try {
      processingRequestIds.add(requestId);
      processingRequestIds.refresh();

      final url = ApiEndPoint.friendStatusUpdate + requestId;
      final response = await ApiService.patch(
        url,
        body: {"status": 'accepted'},
      );

      if (response.statusCode == 200) {
        // Find index by requestId
        final index = requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          final userId = requests[index].sender.id;
          requests.removeAt(index);
          requests.refresh();

          // Update status in maps for other screens
          friendStatusMap[userId] = FriendStatus.friends;
          pendingRequestIdMap.remove(userId);
          friendStatusMap.refresh();
          pendingRequestIdMap.refresh();
        }
        await getMyAllFriends();
        Utils.successSnackBar("Success", "Friend request accepted");
      } else {
        debugPrint("acceptFriendRequest error => ${response.data}");
        Utils.errorSnackBar(
          "Error",
          response.data["message"] ?? "Cannot accept request",
        );
      }
    } catch (e) {
      debugPrint("acceptFriendRequest error => ${e.toString()}");
      Utils.errorSnackBar("Error", "Network error");
    } finally {
      processingRequestIds.remove(requestId);
      processingRequestIds.refresh();
    }
  }

  // ================= Reject Friend Request
  Future<void> rejectFriendRequest(String requestId) async {
    if (processingRequestIds.contains(requestId)) return;

    try {
      processingRequestIds.add(requestId);
      processingRequestIds.refresh();

      final url = ApiEndPoint.friendStatusUpdate + requestId;
      final response = await ApiService.patch(
        url,
        body: {"status": 'rejected'},
      );

      if (response.statusCode == 200) {
        // Find index by requestId
        final index = requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          final userId = requests[index].sender.id;
          requests.removeAt(index);
          requests.refresh();

          // Reset status in maps
          friendStatusMap[userId] = FriendStatus.none;
          pendingRequestIdMap.remove(userId);
          friendStatusMap.refresh();
          pendingRequestIdMap.refresh();
        }
        Utils.successSnackBar("Rejected", "Friend request rejected");
      } else {
        debugPrint("rejectFriendRequest error => ${response.data}");
        Utils.errorSnackBar(
          "Failed",
          response.data["message"] ?? "Could not reject request",
        );
      }
    } catch (e) {
      debugPrint("rejectFriendRequest error => ${e.toString()}");
      Utils.errorSnackBar("Error", "Network error");
    } finally {
      processingRequestIds.remove(requestId);
      processingRequestIds.refresh();
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
      final Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint("⏱️ Location timeout! Trying last known...");
              throw Exception("Location timeout");
            },
          );

      debugPrint("✅ Got position: ${position.latitude}, ${position.longitude}");

      LocalStorage.lat = position.latitude;
      LocalStorage.long = position.longitude;

      await getSuggestedFriend();
    } catch (e) {
      debugPrint("❌ _initLocationThenFetch error: $e");

      try {
        final Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint(
            "📍 Using last known: ${lastKnown.latitude}, ${lastKnown.longitude}",
          );
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

      final double lat = LocalStorage.lat;
      final double lng = LocalStorage.long;

      if (lat == 0.0 || lng == 0.0) {
        nearbyChatError.value =
            "Location not available. Please enable location.";
        debugPrint("❌ Invalid coordinates - Lat: $lat, Lng: $lng");
        return;
      }

      final url =
          "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&page=$_currentPage&limit=20";
      debugPrint("🌐 Fetching Nearby - URL: $url | Page: $_currentPage");

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

        final List<dynamic> data = rawList as List<dynamic>;
        debugPrint("📋 Raw list count: ${data.length}");

        final List<SuggestedFriendUserModel> parsedList = [];
        final currentUserId = LocalStorage.userId;
        for (int i = 0; i < data.length; i++) {
          try {
            final user = SuggestedFriendUserModel.fromJson(data[i]);
            // Filter out current user
            if (user.id != currentUserId) {
              parsedList.add(user);
              debugPrint(
                "✅ Parsed [$i]: ${user.name} | Distance: ${user.distance}",
              );
            }
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

        // Parallelize friendship status checks for better performance
        final List<Future<void>> checks = parsedList
            .map((user) => checkFriendship(user.id))
            .toList();
        await Future.wait(checks);
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

  // ================= Global Search (Search by name/email on server)
  Future<void> searchGlobalUsers(String query) async {
    if (query.isEmpty) {
      await getSuggestedFriend();
      return;
    }

    try {
      isNearbyChatLoading.value = true;
      nearbyChatError.value = '';
      suggestedFriendList.clear();



      final double lat = LocalStorage.lat;
      final double lng = LocalStorage.long;
      final String encoded = Uri.encodeComponent(query);

      String url;
      if (lat != 0.0 && lng != 0.0) {

        ///TODO ========== Nearby search with email filter
           url = "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&email=$encoded&limit=50";

        //url = "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&searchTerm=$encoded&limit=50";
      } else {
        ///TODO===========================
        // Fallback search by email only
           url = "${ApiEndPoint.searchUsers}?email=$encoded&limit=50";

        //url = "${ApiEndPoint.searchUsers}?searchTerm=$encoded&limit=50";
      }
      debugPrint("🌐 Global Search URL: $url");

      final ApiResponseModel response = await ApiService.get(url);
      debugPrint("✅ Global Search Status: ${response.statusCode}");

      if (response.isSuccess) {
        final rawList = response.data['data'];
        final List<SuggestedFriendUserModel> parsedList = [];

        if (rawList != null && rawList is List) {
          for (var item in rawList) {
            try {
              final user = SuggestedFriendUserModel.fromJson(item);
              if (user.id != LocalStorage.userId) {
                parsedList.add(user);
              }
            } catch (e) {
              debugPrint("❌ Failed to parse user in search: $e");
            }
          }
        }

        suggestedFriendList.value = parsedList;
        debugPrint("📋 Search results: ${parsedList.length}");

        if (parsedList.isNotEmpty) {
          final List<Future<void>> checks = parsedList
              .map((u) => checkFriendship(u.id))
              .toList();
          await Future.wait(checks);
        }
      } else {
        nearbyChatError.value = response.message;
        debugPrint("❌ Global Search API Error: ${response.message}");
      }
    } catch (e) {
      nearbyChatError.value = e.toString();
      debugPrint("❌ Global Search Exception: $e");
    } finally {
      isNearbyChatLoading.value = false;
    }
  }

  // ================= Check Friendship Status (per user)
  Future<void> checkFriendship(String userId) async {
    try {
      final response = await ApiService.get(
        "${ApiEndPoint.checkFriendStatus}$userId",
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];

        debugPrint("🔍 checkFriendship raw data: $data");

        if (data['isAlreadyFriend'] == true) {
          friendStatusMap[userId] = FriendStatus.friends;
        } else if (data['pendingFriendRequest'] != null) {
          final request = data['pendingFriendRequest'];
          final requestId = request['_id'];
          final senderId = request['sender'];

          pendingRequestIdMap[userId] = requestId ?? '';

          // If I am the sender, it's 'requested'. If I am NOT the sender, it's 'received'.
          if (senderId == LocalStorage.userId) {
            friendStatusMap[userId] = FriendStatus.requested;
          } else {
            friendStatusMap[userId] = FriendStatus.received;
          }
        } else {
          friendStatusMap[userId] = FriendStatus.none;
          pendingRequestIdMap.remove(userId);
        }
        friendStatusMap.refresh();
        pendingRequestIdMap.refresh();
      }
    } catch (e) {
      debugPrint("Friendship Error [$userId]: $e");
    }
  }

  // ================= Add Friend
  Future<void> onTapAddFriendButton(String userId) async {
    // Save previous state for rollback
    final previousStatus = friendStatusMap[userId];

    try {
      // Optimistic Update
      friendStatusMap[userId] = FriendStatus.requested;
      friendStatusMap.refresh();

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
        await fetchFriendRequests();
      } else {
        // Rollback on non-200 response
        friendStatusMap[userId] = previousStatus ?? FriendStatus.none;
        friendStatusMap.refresh();
        Utils.errorSnackBar(
          "Failed",
          response.data['message'] ?? "Could not send request",
        );
      }
    } catch (e) {
      // Rollback on error
      friendStatusMap[userId] = previousStatus ?? FriendStatus.none;
      friendStatusMap.refresh();
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      loadingUserIds.remove(userId);
      loadingUserIds.refresh();
    }
  }

  // ================= Cancel Friend Request
  Future<void> cancelFriendRequest(String userId) async {
    // Save previous state for rollback
    final previousStatus = friendStatusMap[userId];

    try {
      // Optimistic Update
      friendStatusMap[userId] = FriendStatus.none;
      friendStatusMap.refresh();

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
        pendingRequestIdMap.remove(userId);
        pendingRequestIdMap.refresh();
      } else {
        // Rollback
        friendStatusMap[userId] = previousStatus ?? FriendStatus.requested;
        friendStatusMap.refresh();
        Utils.errorSnackBar(
          "Failed",
          response.data['message'] ?? "Could not cancel request",
        );
      }
    } catch (e) {
      // Rollback
      friendStatusMap[userId] = previousStatus ?? FriendStatus.requested;
      friendStatusMap.refresh();
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      loadingUserIds.remove(userId);
      loadingUserIds.refresh();
    }
  }
}
