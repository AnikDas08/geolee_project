import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/features/clicker/data/all_post_model.dart';
import 'package:giolee78/features/clicker/data/single_user_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../friend/data/post_model_by_id.dart';

enum FriendStatus { none, requested, friends }

class ClickerController extends GetxController {
  /// ================= Search
  final searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();

  /// ================= Carousel
  final _currentPosition = 0.obs;
  int get currentPosition => _currentPosition.value;
  void changePosition(int position) => _currentPosition.value = position;

  /// ================= Filter
  final _selectedFilter = 'All'.obs;
  String get selectedFilter => _selectedFilter.value;

  final List<String> filterOptions = [
    'All',
    'Great Vibes',
    'Off Vibes',
    'Charming Gentleman',
    'Lovely Lady',
  ];

  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
    _filterPosts();
  }

  /// ================= Banners
  final banners = [
    CommonImage(imageSrc: AppImages.banner1),
    CommonImage(imageSrc: AppImages.banner2),
    CommonImage(imageSrc: AppImages.banner3),
  ].obs;

  /// ================= All posts
  var posts = <PostData>[].obs;
  var filteredPosts = <PostData>[].obs;
  var isLoading = false.obs;

  // ================= User profile + posts
  Rxn<SingleUserByIdData> userData = Rxn<SingleUserByIdData>();
  var usersPosts = <PostById>[].obs;
  var isUserLoading = false.obs;

  // ================= Friend
  var friendStatus = FriendStatus.none.obs;
  var pendingRequestId = ''.obs; // ✅ Request ID store করার জন্য

  @override
  void onInit() {
    super.onInit();
    getAllPosts();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  // ================= Check Friendship Status
  Future<void> checkFriendship(String userId) async {
    try {
      final response = await ApiService.get(
        "${ApiEndPoint.checkFriendStatus}$userId",
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data['isAlreadyFriend'] == true) {
          friendStatus.value = FriendStatus.friends;
        } else if (data['pendingFriendRequest'] != null &&
            data['pendingFriendRequest']['status'] == 'pending') {
          friendStatus.value = FriendStatus.requested;

          // ✅ Request ID save করুন
          pendingRequestId.value = data['pendingFriendRequest']['_id'] ?? '';
        } else {
          friendStatus.value = FriendStatus.none;
        }
      }
    } catch (e) {
      debugPrint("Friendship check error: $e");
    }
  }

  // ================= Search + Filter
  void _onSearchChanged() {
    searchText.value = searchController.text;
    _filterPosts();
  }



  void _filterPosts() {
    List<PostData> filtered = posts;

    if (selectedFilter != 'All') {
      filtered = filtered
          .where((post) => post.clickerType == selectedFilter)
          .toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      filtered = filtered.where((post) {
        return post.user.name.toLowerCase().contains(query) ||
            post.description.toLowerCase().contains(query) ||
            post.address.toLowerCase().contains(query)||
           post.user.name.toLowerCase().contains(query);
      }).toList();
    }

    filteredPosts.assignAll(filtered);
  }

  // ================= Get all posts
  Future<void> getAllPosts({String? clickerType}) async {
    try {
      isLoading.value = true;
      String url = ApiEndPoint.getAllPost;

      if (clickerType != null &&
          clickerType.isNotEmpty &&
          clickerType != 'All') {
        url += "?clickerType=$clickerType";
      }

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = AllPostModel.fromJson(response.data);
        posts.assignAll(responseData.data);
        _filterPosts();
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }



  // ================= Get posts by user ID
  Future<void> getPostsByUser(String userId) async {
    try {
      isUserLoading.value = true;
      usersPosts.clear();

      final url = "${ApiEndPoint.getUserById}$userId";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = PostResponseById.fromJson(
          response.data as Map<String, dynamic>,
        );

        final filtered = responseData.data
            .where((post) => post.privacy.toLowerCase() != "only me")
            .toList();

        usersPosts.assignAll(filtered);
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }

  // ================= Get user profile
  Future<void> getUserById(String userId) async {
    try {
      isUserLoading.value = true;
      userData.value = null;

      final url = "${ApiEndPoint.getUserSingleProfileById}$userId";
      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        final responseData = SingleUserByIdModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        userData.value = responseData.data;
      } else {
        Utils.errorSnackBar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isUserLoading.value = false;
    }
  }



  // ================= Send Friend Request
  Future<void> onTapAddFriendButton(String userId) async {
    try {
      isLoading.value = true;

      final response = await ApiService.post(
        ApiEndPoint.createFriendRequest,
        body: {"receiver": userId},
      );

      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.requested;

        // ✅ যদি response এ request ID থাকে তাহলে save করুন
        if (response.data['data'] != null &&
            response.data['data']['_id'] != null) {
          pendingRequestId.value = response.data['data']['_id'];
        }

        Utils.successSnackBar(
          "Request Sent",
          "Friend request sent successfully",
        );
      } else {
        Utils.errorSnackBar(
          "Error",
          response.message ?? "Failed to send request",
        );
        print("============❤️❤️❤️❤️${response.message}");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }



  // ================= Cancel Friend Request (PATCH with status: cancel)
  Future<void> cancelFriendRequest(String userId) async {
    try {
      isLoading.value = true;
      final endpoint = pendingRequestId.value.isNotEmpty
          ? "${ApiEndPoint.cancelFriendRequest}${pendingRequestId.value}"
          : "${ApiEndPoint.cancelFriendRequest}$userId";

      final response = await ApiService.patch(
        endpoint,
        body: {
          "status": "cancelled" // ✅ Status পাঠান
        },
      );

      if (response.statusCode == 200) {
        friendStatus.value = FriendStatus.none;
        pendingRequestId.value = ''; // Reset request ID

        Utils.successSnackBar(
          "Request Cancelled",
          "Friend request cancelled successfully",
        );
      } else {
        Utils.errorSnackBar(
          "Error",
          response.message ?? "Failed to cancel request",
        );
        print("============❤️❤️❤️❤️${response.message}");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
      print("Cancel request error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}