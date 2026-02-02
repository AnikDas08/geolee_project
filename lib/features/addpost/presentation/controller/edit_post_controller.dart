import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_response_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/controller/post_controller.dart';
import '../data/single_post_mode.dart';

class EditPostControllers extends GetxController {
  final isLoading = false.obs;
  String postId = ''; // ✅ Initialize as empty string

  // Image handling
  final selectedImages = <File>[].obs;
  final existingImageUrls = <String>[].obs;
  final descriptionController = TextEditingController();
  final selectedPricingOption = ''.obs;
  final selectedPriorityLevel = ''.obs;
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();
  final selectedGender = ''.obs;

  final List<String> priorityLevels = ['friend', 'public', 'only me'];
  final ImagePicker _picker = ImagePicker();

  Rxn<SinglePostData> mySinglePost = Rxn<SinglePostData>();

  // ✅ NEW: Initialize method to be called from screen
  void initialize(String id) {
    postId = id;
    debugPrint("🆔 Received Post ID in controller: $postId");
    if (postId.isNotEmpty) {
      fetchMyPostsById(postId);
    }
  }

  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
    print('Selected: $option');
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
        header: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("===============================${response.data}");

        final myPostModel = SinglePostModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        mySinglePost.value = myPostModel.data;

        _populateFieldsWithPostData();
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

  void _populateFieldsWithPostData() {
    if (mySinglePost.value != null) {
      final post = mySinglePost.value!;

      // Set description
      descriptionController.text = post.description ?? '';

      // Set clicker type
      selectedPricingOption.value = post.clickerType ?? '';

      // Set privacy
      selectedPriorityLevel.value = post.privacy ?? '';

      // Set existing image URLs
      if (post.photos != null && post.photos!.isNotEmpty) {
        existingImageUrls.assignAll(post.photos!);
      }

      // Update postId if needed
      if (post.id != null) {
        postId = post.id.toString();
      }

      debugPrint('✅ Fields populated with post data');
      debugPrint('Description: ${descriptionController.text}');
      debugPrint('Clicker Type: ${selectedPricingOption.value}');
      debugPrint('Privacy: ${selectedPriorityLevel.value}');
      debugPrint('Existing Images: ${existingImageUrls.length}');
      debugPrint('Post ID: $postId');

      update();
    }
  }

  final MyPostController _myPostController = Get.put(MyPostController());

  Future<void> editPost() async {
    isLoading.value = true;

    try {
      final url = "${ApiEndPoint.updatePost}$postId";

      Map<String, String> body = {
        'description': descriptionController.text.trim(),
        'clickerType': selectedPricingOption.value,
        'privacy': selectedPriorityLevel.value.toLowerCase(),
      };

      var response = await ApiService.multipartUpdate(
        url,
        body: body,
        imagePath: selectedImages.isNotEmpty ? selectedImages.first.path : null,
        imageName: "image",
      );

      if (response.statusCode == 200) {

        update();

        Utils.successSnackBar(
          "Post Updated",
          response.message,
        );
        selectedImages.clear();
        Get.back();
      } else {
        Utils.errorSnackBar(response.statusCode, response.message);
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }

    update();
  }

  void removeImageAtIndex(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      Get.snackbar(
        'Removed',
        'Image removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeExistingImageAtIndex(int index) {
    if (index >= 0 && index < existingImageUrls.length) {
      existingImageUrls.removeAt(index);
      Get.snackbar(
        'Removed',
        'Existing image removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
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
        File file = File(image.path);
        selectedImages.add(file);

        Get.snackbar(
          'Success',
          'Image selected (${selectedImages.length})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> pickImageFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  @override
  void onClose() {
    descriptionController.dispose();
    priceController.dispose();
    serviceTimeController.dispose();
    super.onClose();
  }
}