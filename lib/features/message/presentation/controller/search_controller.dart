import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../chat_nearby/data/nearby_friends_model.dart';

class SearchFriendController extends GetxController {
  /// User lists
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];

  RxList<NearbyChatUserModel> nearbyChatList = <NearbyChatUserModel>[].obs;

  RxBool isNearbyChatLoading = false.obs;
  RxString nearbyChatError = ''.obs;

  // ================= PAGINATION =================
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  RxBool isPaginationLoading = false.obs;
  bool get hasMoreData => _currentPage < _totalPages;

  Future<void> loadMore() async {
    if (!hasMoreData || isPaginationLoading.value) return;
    _currentPage++;
    debugPrint("📄 Loading page: $_currentPage");
    await getNearbyChat(isRefresh: false);
  }

  Future<void> getNearbyChat({bool isRefresh = true}) async {
    try {
      // Reset pagination on refresh
      if (isRefresh) {
        _currentPage = 1;
        nearbyChatList.clear();
      }

      final double lat = LocalStorage.lat ?? 0.0;
      final double lng = LocalStorage.long ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        nearbyChatError.value = "Location not available. Please enable location.";
        debugPrint("❌ Invalid coordinates - Lat: $lat, Lng: $lng");
        return;
      }

      final url = "${ApiEndPoint.nearbyChat}?lat=$lat&lng=$lng&page=$_currentPage&limit=20";

      debugPrint("🌐 Fetching Nearby Chat - URL: $url");
      debugPrint("📄 Page: $_currentPage");

      isRefresh
          ? isNearbyChatLoading.value = true
          : isPaginationLoading.value = true;
      nearbyChatError.value = '';

      final ApiResponseModel response = await ApiService.get(url);

      debugPrint("📦 Full Response: ${response.data}");
      debugPrint("✅ Status: ${response.statusCode}");

      if (response.isSuccess) {
        // ========== PARSE PAGINATION ==========
        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages = pagination['totalPage'] ?? 1;
          _totalUsers = pagination['total'] ?? 0;
          debugPrint("📊 Total Users: $_totalUsers | Total Pages: $_totalPages | Current Page: $_currentPage");
        }

        // ========== PARSE DATA WITH PER-ITEM ERROR HANDLING ==========
        final rawList = response.data['data'];

        if (rawList == null) {
          nearbyChatError.value = "No data found";
          debugPrint("❌ Data is null in response");
          return;
        }

        final List data = rawList as List;
        debugPrint("📋 Raw list count: ${data.length}");

        final List<NearbyChatUserModel> parsedList = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final user = NearbyChatUserModel.fromJson(data[i]);
            parsedList.add(user);
            debugPrint("✅ Parsed user [$i]: ${user.name} | Role: ${user.role} | Distance: ${user.distance}");
          } catch (e) {
            // ✅ Skip broken items instead of stopping all parsing
            debugPrint("❌ Failed to parse user at index [$i]: $e");
            debugPrint("❌ Raw data: ${data[i]}");
          }
        }

        debugPrint("✅ Successfully parsed: ${parsedList.length} / ${data.length} users");

        // ========== ADD TO LIST ==========
        if (isRefresh) {
          nearbyChatList.value = parsedList;
        } else {
          nearbyChatList.addAll(parsedList);
        }

        debugPrint("📋 Total in list now: ${nearbyChatList.length}");

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

  /// Loading states
  bool isLoading = false;

  /// Search controller
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  /// Search users
  void searchUsers(String query) {
    searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      filteredUsers = users;
    } else {
      filteredUsers = users.where((user) {
        final nameLower = user.name.toLowerCase();
        return nameLower.contains(searchQuery);
      }).toList();
    }

    update();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    filteredUsers = users;
    update();
  }

  /// Send friend request
  void sendFriendRequest(String userId) {
    final index = users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      users[index] = UserModel(
        id: users[index].id,
        name: users[index].name,
        image: users[index].image,
        isFriend: true,
      );

      // Update filtered list
      final filteredIndex = filteredUsers.indexWhere((user) => user.id == userId);
      if (filteredIndex != -1) {
        filteredUsers[filteredIndex] = UserModel(
          id: filteredUsers[filteredIndex].id,
          name: filteredUsers[filteredIndex].name,
          image: filteredUsers[filteredIndex].image,
          isFriend: true,
        );
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Friend request sent to ${users[index].name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      update();
    }
  }

  /// Load users (demo data)
  Future<void> loadUsers() async {
    isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 500));

    users = [
      UserModel(
        id: '1',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '2',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '3',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '4',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '5',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '6',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '7',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '8',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '9',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '10',
        name: 'John Smith',
        image: 'https://images.pexels.com/photos/1552108/pexels-photo-1552108.jpeg',
        isFriend: true,
      ),
      UserModel(
        id: '11',
        name: 'Jane Doe',
        image: 'https://images.pexels.com/photos/1542085/pexels-photo-1542085.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '12',
        name: 'Mike Johnson',
        image: 'https://images.pexels.com/photos/1516680/pexels-photo-1516680.jpeg',
        isFriend: true,
      ),
    ];

    filteredUsers = users;
    isLoading = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

/// User Model
class UserModel {
  final String id;
  final String name;
  final String image;
  final bool isFriend;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFriend,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isFriend: json['isFriend'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'isFriend': isFriend,
    };
  }
}