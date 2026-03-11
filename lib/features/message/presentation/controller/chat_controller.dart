import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../data/model/chat_list_model.dart';
import '../../repository/chat_repository.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/enum/enum.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';

class ChatController extends GetxController {
  List<ChatModel> singleChats = [];
  List<ChatModel> chats = [];
  List<ChatModel> filteredChats = [];
  List<ChatModel> filteredSingleChats = [];

  bool isSingleLoading = false;
  bool isGroupLoading = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoadingMoreSingle = false;
  bool hasNoData = false;
  bool hasNoSingleData = false;
  int page = 0;
  int singlePage = 0;
  RxString currentRadius = (LocalStorage.radius).obs;

  RxDouble currentLatitude = 0.0.obs;
  RxDouble currentLongitude = 0.0.obs;
  RxBool isLocationUpdating = false.obs;


  int _groupTotalPages = 1;
  int _singleTotalPages = 1;

  bool get hasMoreGroups => page < _groupTotalPages;

  bool get hasMoreSingles => singlePage < _singleTotalPages;


  String? _currentOpenChatId;

  ScrollController scrollController = ScrollController();
  ScrollController singleScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  Timer? _searchDebounce;

  static ChatController get instance => Get.put(ChatController());

  int get totalUnreadCount {
    int total = 0;
    for (var chat in singleChats) {
      total += chat.unreadCount;
    }
    for (var chat in chats) {
      total += chat.unreadCount;
    }
    return total;
  }

  int unreadCountForChat(String chatId) {
    final single = singleChats.firstWhereOrNull((c) => c.id == chatId);
    if (single != null) return single.unreadCount;

    final group = chats.firstWhereOrNull((c) => c.id == chatId);
    if (group != null) return group.unreadCount;

    return 0;
  }

  void setOpenChat(String chatId) {
    _currentOpenChatId = chatId;
    markChatAsSeen(chatId);
    debugPrint(" Chat opened: $chatId");
  }

  // ===================================

  void clearOpenChat() {
    debugPrint(" Chat closed: $_currentOpenChatId");
    _currentOpenChatId = null;
  }

  void clearSearch() {
    searchController.clear();
    _searchDebounce?.cancel();
    getChatRepos();
    getChatRepos(isGroup: true);
    update();
  }

  void _sortChats() {
    singleChats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void searchChats(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      getChatRepos();
      getChatRepos(isGroup: true);
    });
    update();
  }

  void setupGroupPagination() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (isLoadingMore || !hasMoreGroups) return;
        await _loadMoreGroups();
      }
    });
  }

  void setupSinglePagination() {
    singleScrollController.addListener(() async {
      if (singleScrollController.position.pixels >=
          singleScrollController.position.maxScrollExtent - 200) {
        if (isLoadingMoreSingle || !hasMoreSingles) return;
        await _loadMoreSingles();
      }
    });
  }

  Future<void> sendFriendRequest(String userId, String chatId) async {
    try {
      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": userId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final requestId = response.data['data']?['_id'] ?? '';
        _updateFriendRequestStatus(chatId, 'pending', requestId);
      }
    } catch (e) {
      debugPrint("sendFriendRequest error: $e");
    }
  }

  Future<void> cancelFriendRequest(String userId, String chatId) async {
    try {
      final index = singleChats.indexWhere((c) => c.id == chatId);
      final requestId = index != -1
          ? singleChats[index].friendRequestId ?? userId
          : userId;

      final response = await ApiService.patch(
        "${ApiEndPoint.cancelFriendRequest}$requestId",
        body: {"status": "cancelled"},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateFriendRequestStatus(chatId, 'none', '');
      }
    } catch (e) {
      debugPrint("cancelFriendRequest error: $e");
    }
  }

  void _updateFriendRequestStatus(String chatId,
      String status,
      String requestId,) {
    final index = singleChats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      singleChats[index] = singleChats[index].copyWith(
        friendRequestStatus: status,
        friendRequestId: requestId,
      );
      final fIndex = filteredSingleChats.indexWhere((c) => c.id == chatId);
      if (fIndex != -1) {
        filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(
          friendRequestStatus: status,
          friendRequestId: requestId,
        );
      }
      update();
    }
  }

  Future<void> _loadMoreGroups() async {
    if (isLoadingMore || !hasMoreGroups) return;
    isLoadingMore = true;
    update();

    try {
      page++;
      final response = await chatRepository(
        page,
        searchController.text.trim(),
        true,
      );
      _groupTotalPages = response.totalPage;
      final allGroups = response.data.where((item) => item.isGroup).toList();
      chats.addAll(allGroups);
      _sortChats();
      filteredChats = List.from(chats);
    } catch (e) {
      page--;
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  Future<void> _loadMoreSingles() async {
    if (isLoadingMoreSingle || !hasMoreSingles) return;
    isLoadingMoreSingle = true;
    update();

    try {
      singlePage++;
      final response = await chatRepository(
        singlePage,
        searchController.text.trim(),
        false,
      );
      _singleTotalPages = response.totalPage;
      final singles = response.data.where((item) => !item.isGroup).toList();
      singleChats.addAll(singles);
      _sortChats();
      filteredSingleChats = List.from(singleChats);
      await _markFriendStatusForList(singles);
    } catch (e) {
      singlePage--;
    } finally {
      isLoadingMoreSingle = false;
      update();
    }
  }

  Future<void> getChatRepos({
    bool showLoading = true,
    bool isGroup = false,
  }) async {
    try {
      if (showLoading) {
        if (isGroup) {
          isGroupLoading = true;
        } else {
          isSingleLoading = true;
        }
        isLoading = true;
        update();
      }

      if (isGroup) {
        page = 1;
      } else {
        singlePage = 1;
      }

      final response = await chatRepository(
        isGroup ? page : singlePage,
        searchController.text.trim(),
        isGroup,
      );

      if (isGroup) {
        chats.clear();
        _groupTotalPages = response.totalPage;
        final allGroups = response.data.where((item) => item.isGroup).toList();
        chats.addAll(allGroups);
        _sortChats();
        filteredChats = List.from(chats);
      } else {
        singleChats.clear();
        _singleTotalPages = response.totalPage;
        singleChats.addAll(
          response.data.where((item) => !item.isGroup).toList(),
        );
        _sortChats();
        filteredSingleChats = List.from(singleChats);
        await _markFriendStatus();
      }

      // ===============================================

      if (_currentOpenChatId != null) {
        markChatAsSeen(_currentOpenChatId!);
      }
    } catch (e) {
      debugPrint(">>>>>>>>>>>>getChatRepos Error: $e <<<<<<<<<<<<");
    } finally {
      if (isGroup) {
        isGroupLoading = false;
      } else {
        isSingleLoading = false;
      }
      isLoading = isSingleLoading || isGroupLoading;
      update();
    }
  }

  Future<void> _markFriendStatus() async {
    await _markFriendStatusForList(singleChats);
  }

  Future<void> _markFriendStatusForList(List<ChatModel> targetList) async {
    if (targetList.isEmpty) return;
    final List<Future> checks = targetList.map((chat) async {
      if (chat.participant.sId.isEmpty) return;
      try {
        final response = await ApiService.get(
          "${ApiEndPoint.checkFriendStatus}${chat.participant.sId}",
        );
        bool isFriend = false;
        if (response.statusCode == 200) {
          final data = response.data['data'];
          isFriend = data['isAlreadyFriend'] == true;
        }
        final index = singleChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          singleChats[index] = singleChats[index].copyWith(isFriend: isFriend);
          final fIndex = filteredSingleChats.indexWhere((c) => c.id == chat.id);
          if (fIndex != -1) {
            filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(
              isFriend: isFriend,
            );
          }
        }
      } catch (_) {}
    }).toList();
    await Future.wait(checks);
    update();
  }

  Status get status {
    if (isGroupLoading && chats.isEmpty) return Status.loading;
    if (filteredChats.isEmpty && hasNoData) return Status.error;
    return Status.completed;
  }

  Future<void> listenChat() async {
    SocketServices.on("chat:update", (data) {
      //getChatRepos currentOpenChatId check ========================
      getChatRepos(showLoading: false);
      getChatRepos(showLoading: false, isGroup: true);
    });

    final String eventName = "update-chatlist::${LocalStorage.userId}";
    SocketServices.on(eventName, (data) {
      page = 1;
      singlePage = 1;
      chats.clear();
      singleChats.clear();

      for (var item in data) {
        try {
          final chat = ChatModel.fromJson(item);
          if (chat.isGroup) {
            chats.add(chat);
          } else {
            singleChats.add(chat);
          }
        } catch (e) {}
      }

      _sortChats();
      filteredChats = List.from(chats);
      filteredSingleChats = List.from(singleChats);


      if (_currentOpenChatId != null) {
        markChatAsSeen(_currentOpenChatId!);
      }

      update();
      _markFriendStatus();
    });
  }

  void markChatAsSeen(String chatId) {
    bool found = false;

    // Update single chats===================================
    int index = singleChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      singleChats[index] = singleChats[index].copyWith(unreadCount: 0);
      int fIndex = filteredSingleChats.indexWhere((c) => c.id == chatId);
      if (fIndex != -1) {
        filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(
          unreadCount: 0,
        );
      }
      found = true;
    }

    // Update group chats ======================================
    int gIndex = chats.indexWhere((chat) => chat.id == chatId);
    if (gIndex != -1) {
      chats[gIndex] = chats[gIndex].copyWith(unreadCount: 0);
      int fgIndex = filteredChats.indexWhere((c) => c.id == chatId);
      if (fgIndex != -1) {
        filteredChats[fgIndex] = filteredChats[fgIndex].copyWith(
          unreadCount: 0,
        );
      }
      found = true;
    }

    if (found) {
      update();
      debugPrint(
        "Chat $chatId marked as seen. Total unread: $totalUnreadCount",
      );
    }
  }

//============================address From Coordinate   ===========================
  Future<String?> getAddressFromCoordinate(double lat, double lng) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      );
      if (placemarks.isNotEmpty) {
        final Placemark p = placemarks.first;
        return "${p.street}, ${p.subLocality}, ${p.locality}, "
            "${p.administrativeArea}, ${p.country}";
      }
      return null;
    } catch (e) {
      debugPrint("getAddress error: $e");
      return null;
    }
  }
  //============================update Profile ===========================

  Future<void> updateProfile(double longitude, double latitude) async {
    try {
      final String? address = await getAddressFromCoordinate(
        latitude,
        longitude,
      );
      final response = await ApiService.patch(
        ApiEndPoint.updateProfile,
        body: {
          // "isLocationVisible": false,
          "location": [longitude, latitude],
          "address": address ?? "Location Unavailable",
        },
      );
      if (response.statusCode == 200) {
        debugPrint('Profile location updated');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  //====================Current Location gate and update profile===========================
  Future<void> getCurrentLocationAndUpdateProfile() async {
    try {
      isLocationUpdating.value = true;
      final Position? position = await getCurrentLocation();
      if (position != null) {
        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;

        LocalStorage.lat = position.latitude;
        LocalStorage.long = position.longitude;

        await updateProfile(position.longitude, position.latitude);
      }
    } catch (e) {
      debugPrint('Location update error: $e');
    } finally {
      isLocationUpdating.value = false;
    }
  }

//============================================get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // ✅ medium saves memory
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }


  Future<void> getRadius() async {
    try {
      final response = await ApiService.get(ApiEndPoint.getRadius);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        LocalStorage.radius = data['nearbyRange'].toString();
        currentRadius.value = LocalStorage.radius;
      }
    } catch (e) {
      debugPrint("getRadius error: $e");
    }
  }


  @override
  void onInit() async {
    super.onInit();
    await getCurrentLocationAndUpdateProfile();
    await getRadius();

    fetchInitialData();
    listenChat();
    setupGroupPagination();
    setupSinglePagination();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    singleScrollController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([getChatRepos(), getChatRepos(isGroup: true)]);
  }
}
