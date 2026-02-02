import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/addpost/my_post_model.dart' hide Pagination;
import 'package:giolee78/features/home/presentation/controller/home_controller.dart';
import 'package:giolee78/services/storage/storage_services.dart';

import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import '../../data/post_model.dart';

class MyPostController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<MyPostsModelOne?> myPostsModel = Rx<MyPostsModelOne?>(null);
  RxList<PostDataOne> posts = <PostDataOne>[].obs;

  RxList<PostData>myPost=<PostData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts() async {
    try {
      isLoading.value = true;

      final url = ApiEndPoint.getMyPost;

      ApiResponseModel response = await ApiService.get(
        url,
        header: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Content-Type': 'application/json',
        },
      );



      if (response.statusCode == 200 || response.statusCode == 201) {


        print("===============================${response.data}");

        final myPostModel = MyPostModel.fromJson(response.data as Map<String, dynamic>);
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
    }
  }


  Future<void> deletePost(String postId) async {
    try {
      ApiResponseModel response = await ApiService.delete(
        "${ApiEndPoint.deletePost}$postId",
        header: {
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
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


        Get.find<HomeController>().fetchPosts();
        fetchMyPosts();
        update();

      } else {
        Get.snackbar(
          'Error',
          'Failed to delete post',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      Get.snackbar(
        'Error',
        'Failed to delete post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  // Helper method to get pagination info
  Pagination? get pagination => myPostsModel.value?.pagination;
}
