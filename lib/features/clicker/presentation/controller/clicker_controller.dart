import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/features/clicker/data/all_post_model.dart';
import 'package:giolee78/features/clicker/data/single_user_model.dart';

import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import '../../../../config/api/api_end_point.dart';

enum FriendStatus {
  none,        // Add Friend
  requested,   // Request Sent
  friends      // Message
}

class ClickerController extends GetxController {
  /// Carousel
  final _currentPosition = 0.obs;
  int get currentPosition => _currentPosition.value;
  void changePosition(int position) => _currentPosition.value = position;

  /// Filter
  final _selectedFilter = 'All'.obs;
  String get selectedFilter => _selectedFilter.value;
  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
    applyFilter(); // Filter automatically applied when changed
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
  var userPosts = <PostData>[].obs;
  var isUserLoading = false.obs;
  var isSendFriendRequest=false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllPosts();

  }

  /// Apply filter locally
  void applyFilter() {
    if (selectedFilter == 'All') {
      filteredPosts.assignAll(posts);
    } else {
      filteredPosts.assignAll(
        posts.where((post) => post.clickerType == selectedFilter).toList(),
      );
    }
  }

  /// Fetch all posts from API (with optional filter param)
  Future<void> getAllPosts({String? filter}) async {
    try {
      isLoading.value = true;

      var url = ApiEndPoint.getAllPost; // e.g. "/posts"
      if (filter != null && filter != 'All') {
        url += "?category=$filter"; // pass filter param to API if exists
      }

      var response = await ApiService.get(
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
        url,
      );

      if (response.statusCode == 200) {
        final allPosts =
        AllPostModel.fromJson(response.data as Map<String, dynamic>);
        posts.assignAll(allPosts.data);
        applyFilter(); // Apply filter after fetching
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Something went wrong");
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

      final url = "${ApiEndPoint.getUserById}$userId"; // e.g. /posts/user/:id
      var response = await ApiService.get(
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
        url,
      );

      if (response.statusCode == 200) {
        final allPosts =
        AllPostModel.fromJson(response.data as Map<String, dynamic>);
        userPosts.assignAll(allPosts.data);
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  Rxn<SingleUserByIdData> userData = Rxn<SingleUserByIdData>();

  Future<void> getUserById(String userId) async {
    try {
      isUserLoading.value = true;

      final url = "${ApiEndPoint.getUserSingleProfileById}$userId";

      var response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final model = SingleUserByIdModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        userData.value = model.data; // ✅ CORRECT
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
    // ১. যদি অলরেডি রিকোয়েস্ট পাঠানো থাকে, তবে ফাংশনটি এখানেই থামিয়ে দিন
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
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
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





}
