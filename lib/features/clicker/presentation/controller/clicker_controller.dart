import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/features/clicker/data/all_post_model.dart';
import 'package:giolee78/features/clicker/data/single_user_model.dart';

import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import '../../../../config/api/api_end_point.dart';

enum FriendStatus {
  none, // Add Friend
  requested, // Request Sent
  friends, // Message
}

class ClickerController extends GetxController {
  final searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();

  /// Carousel
  final _currentPosition = 0.obs;

  int get currentPosition => _currentPosition.value;

  void changePosition(int position) => _currentPosition.value = position;

  /// Filter
  final _selectedFilter = 'All'.obs;

  String get selectedFilter => _selectedFilter.value;

  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
    _filterPosts(); // Use combined filter
  }

  final List<String> filterOptions = [
    'All',
    'Great Vibes',
    'Off Vibes',
    'Charming Gentleman',
    'Lovely Lady',
  ];

  /// Banners
  final banners = [
    CommonImage(imageSrc: AppImages.banner1),
    CommonImage(imageSrc: AppImages.banner2),
    CommonImage(imageSrc: AppImages.banner3),
  ].obs;

  /// All posts
  var posts = <PostData>[].obs;
  var filteredPosts = <PostData>[].obs; // Filtered list
  var isLoading = false.obs;

  /// User posts
  Rxn<SingleUserByIdData> userData = Rxn<SingleUserByIdData>();

  var userPosts = <PostData>[].obs;
  var isUserLoading = false.obs;
  var isSendFriendRequest = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllPosts();

    searchController.addListener(_onSearchChanged);
  }

  //================================onClose
  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  // ================================Search method
  void _onSearchChanged() {
    searchText.value = searchController.text;
    _filterPosts();
  }

  // =================================Combined filter method (search + clicker type)
  void _filterPosts() {
    List<PostData> filtered = posts;

    // Filter by clicker type
    if (selectedFilter != 'All') {
      filtered = filtered
          .where((post) => post.clickerType == selectedFilter)
          .toList();
    }

    // Filter by search text
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      filtered = filtered.where((post) {
        final userName = post.user.name.toLowerCase();
        final description = post.description.toLowerCase();
        final location = post.address.toLowerCase();

        return userName.contains(query) ||
            description.contains(query) ||
            location.contains(query);
      }).toList();
    }

    filteredPosts.assignAll(filtered);
  }

  /// Fetch all posts from API (with optional filter param)
  Future<void> getAllPosts({String? clickerType}) async {
    try {
      isLoading.value = true;

      String url = ApiEndPoint.getAllPost;

      if (clickerType != null &&
          clickerType.isNotEmpty &&
          clickerType != 'All') {
        url += "?clickerType=$clickerType";
      }

      var response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = AllPostModel.fromJson(response.data);
        posts.assignAll(responseData.data);
        _filterPosts();
      } else {
        Utils.errorSnackBar(
          "Error",
          response.message ?? "Something went wrong",
        );
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch posts by user ID
  Future<void> getPostsByUser(String userId) async {
    try {
      isUserLoading.value = true;

      final url = "${ApiEndPoint.getUserById}$userId";
      var response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = AllPostModel.fromJson(response.data);

        // 🔥 privacy filter
        final filteredPosts = responseData.data.where((post) {
          return post.privacy != "only me";
        }).toList();

        posts.assignAll(filteredPosts);

        _filterPosts();
      } else {
        Utils.errorSnackBar(
          "Error",
          response.message ?? "Something went wrong",
        );
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  Future<void> getUserById(String userId) async {
    try {
      isUserLoading.value = true;

      final url = "${ApiEndPoint.getUserSingleProfileById}$userId";

      var response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = SingleUserByIdModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        userData.value = responseData.data; // ✅ CORRECT
      } else {
        Utils.errorSnackBar(
          "Error",
          response.message ?? "Something went wrong",
        );
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  var friendStatus = FriendStatus.none.obs;

  Future<void> onTapAddFriendButton(String userId) async {
    if (friendStatus.value == FriendStatus.requested) {
      Get.defaultDialog(
        title: "Notice",
        middleText: "You have already sent a friend request to this user.",
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await ApiService.post(
        "${ApiEndPoint.createFriendRequest}",
        body: {"receiver": userId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        friendStatus.value = FriendStatus.requested;
        Get.snackbar("Success", "Friend request sent successfully!");
      } else {
        Get.snackbar("Failed", response.message ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool isFriend = false;

  fetchFriendshipStatus(String userId) async {
    final url = "${ApiEndPoint.checkFriendStatus}${userId}";

    final response = await ApiService.get(url);

    return response.data;
  }

  Future<void> checkFriendship(String userId) async {
    try {
      final result = await fetchFriendshipStatus(userId);
      final data = result.data;

      if (data.isAlreadyFriend == true) {
        friendStatus.value = FriendStatus.friends;
      } else if (data.pendingFriendRequest != null) {
        friendStatus.value = FriendStatus.requested;
      } else {
        friendStatus.value = FriendStatus.none;
      }
    } catch (e) {
      print('Friendship check error: $e');
    }
  }
}
