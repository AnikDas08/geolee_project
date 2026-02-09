import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/addpost/presentation/controller/post_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../data/single_post_mode.dart';

class EditPostControllers extends GetxController {
  final isLoading = false.obs;
  String postId = '';

  // Image handling
  final selectedImages = <File>[].obs;
  final existingImageUrls = <String>[].obs;
  final removedImages = <String>[].obs; // ✅ Track removed images to send to API

  final descriptionController = TextEditingController();
  final selectedPricingOption = ''.obs;
  final selectedPriorityLevel = ''.obs;
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();
  final selectedGender = ''.obs;

  final List<String> priorityLevels = ['friend', 'public', 'only me'];
  final ImagePicker _picker = ImagePicker();

  Rxn<SinglePostData> mySinglePost = Rxn<SinglePostData>();

  void initialize(String id) {
    postId = id;
    debugPrint("🆔 Received Post ID in controller: $postId");
    if (postId.isNotEmpty) {
      fetchMyPostsById(postId);
    }
  }

  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  Future<void> fetchMyPostsById(String? postId) async {
    try {
      isLoading.value = true;
      final url = "${ApiEndPoint.getSinglePost}$postId";

      ApiResponseModel response = await ApiService.get(
        url,

      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final myPostModel = SinglePostModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        mySinglePost.value = myPostModel.data;
        _populateFieldsWithPostData();
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFieldsWithPostData() {
    if (mySinglePost.value != null) {
      final post = mySinglePost.value!;
      descriptionController.text = post.description ?? '';
      selectedPricingOption.value = post.clickerType ?? '';
      selectedPriorityLevel.value = post.privacy ?? '';

      if (post.photos.isNotEmpty) {
        existingImageUrls.assignAll(post.photos);
      }

      postId = post.id.toString();
          update();
    }
  }


  Future<void> editPost() async {
    isLoading.value = true;

    try {
      final url = "${ApiEndPoint.updatePost}$postId";

      Map<String, String> body = {
        'description': descriptionController.text.trim(),
        'clickerType': selectedPricingOption.value,
        'privacy': selectedPriorityLevel.value.toLowerCase(),
        'removedImages': jsonEncode(removedImages),
      };


      List<Map<String, dynamic>> files = [];
      for (var file in selectedImages) {
        files.add({
          'name': 'image',
          'image': file.path,
        });
      }


      var response = await ApiService.multipartImage(
        url,
        method: "PATCH",
        body: body,
        files: files,

      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utils.successSnackBar("Post Updated", "Successfully saved changes");
        Get.back();

        try {
          // Get.find<PostController>().fetchMyPosts();
        } catch (_) {}

        removedImages.clear();
        //selectedImages.clear();
        Get.back();
      } else {
        Utils.errorSnackBar("Update Failed", response.message ?? "Error");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void removeImageAtIndex(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      update();
    }
  }

  void removeExistingImageAtIndex(int index) {
    if (index >= 0 && index < existingImageUrls.length) {
      // ✅ Add the URL to the removed list before removing from UI
      removedImages.add(existingImageUrls[index]);
      existingImageUrls.removeAt(index);
      update();

      Get.snackbar(
        'Removed',
        'Image marked for removal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
        update();
      }
    } catch (e) {
      debugPrint("Image Selection Error: $e");
    }
  }

  Future<void> pickImageFromGallery() async => await _pickImage(ImageSource.gallery);
  Future<void> pickImageFromCamera() async => await _pickImage(ImageSource.camera);

  @override
  void onClose() {
    descriptionController.dispose();
    priceController.dispose();
    serviceTimeController.dispose();
    super.onClose();
  }
}