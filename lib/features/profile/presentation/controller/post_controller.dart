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
  RxBool isLoadMore = false.obs;

  Rx<MyPostsModelOne?> myPostsModel = Rx<MyPostsModelOne?>(null);

  RxList<PostDataOne> posts = <PostDataOne>[].obs;
  RxList<PostData> myPost = <PostData>[].obs;

  int page = 1;
  bool hasMore = true;
  int totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    fetchMyPosts();
  }

  Future<void> fetchMyPosts({bool loadMore = false}) async {

    if (loadMore && !hasMore) return;

    try {

      if (loadMore) {
        isLoadMore.value = true;
      } else {
        page = 1;
        hasMore = true;
        isLoading.value = true;
      }

      update();

      final url = "${ApiEndPoint.getMyPost}?page=$page&limit=10";

      debugPrint('📡 Fetching posts URL: $url');

      final ApiResponseModel response = await ApiService.get(url);

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {

        // ✅ Use MyPostModel directly — model is correct
        final MyPostModel myPostModel = MyPostModel.fromJson(
          response.data as Map<dynamic, dynamic>,
        );

        // ✅ Read totalPage from parsed pagination
        totalPages = myPostModel.pagination.totalPage;

        debugPrint('📄 Total: ${myPostModel.pagination.total} | TotalPages: $totalPages | CurrentPage: $page');

        final List<PostData> newPosts = myPostModel.data;

        debugPrint('✅ Fetched ${newPosts.length} posts on page $page');

        if (loadMore) {
          myPost.addAll(newPosts);
        } else {
          myPost.assignAll(newPosts);
        }

        if (newPosts.isEmpty || page >= totalPages) {
          hasMore = false;
          debugPrint('🔚 No more pages');
        } else {
          page++;
          debugPrint('➡️ Next page will be: $page');
        }

      } else {
        debugPrint('❌ Unexpected status: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Server returned ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e, stackTrace) {

      debugPrint('❌ Error fetching posts: $e');
      debugPrint('❌ StackTrace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to load posts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

    } finally {

      isLoading.value = false;
      isLoadMore.value = false;

      update();
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