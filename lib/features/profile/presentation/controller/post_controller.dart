import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/addpost/my_post_model.dart' hide Pagination;
import 'package:giolee78/features/home/presentation/controller/home_controller.dart';

import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import '../../data/post_model.dart';

class MyPostController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<MyPostsModelOne?> myPostsModel = Rx<MyPostsModelOne?>(null);
  RxList<PostDataOne> posts = <PostDataOne>[].obs;

  RxList<PostData> myPost = <PostData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPosts(); // Initial load
  }


  Future<void> fetchMyPosts() async {
    try {
      isLoading.value = true;
      update(); // Trigger UI for loading state

      final url = ApiEndPoint.getMyPost;
      final ApiResponseModel response = await ApiService.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final myPostModel = MyPostModel.fromJson(response.data);
        
        // ✅ FIXED: Use assignAll or clear the list first to avoid duplication
        myPost.assignAll(myPostModel.data ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      Get.snackbar(
        'Error',
        'Failed to load posts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      update(); // Trigger UI refresh
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final ApiResponseModel response = await ApiService.delete(
        "${ApiEndPoint.deletePost}$postId",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        myPost.removeWhere((post) => post.id == postId);

        Get.snackbar(
          'Success',
          'Post deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchPosts();
        }
        
        // No need to call fetchMyPosts() again since we manually removed it from the list
        update();

      } else {
        Get.snackbar(
          'Error',
          'Failed to delete post',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
    }
  }

  Pagination? get pagination => myPostsModel.value?.pagination;
}
