import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditPostControllers extends GetxController {
  final isLoading = false.obs;
  late String postId;

  // Image handling
  final selectedImages = <File>[].obs;

  // Form controllers
  final descriptionController = TextEditingController();

  // ✅ FIXED: Single selection for all 4 options (empty initially)
  final selectedPricingOption = ''.obs;

  final selectedPriorityLevel = ''.obs;
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();
  final selectedGender = ''.obs;

  final List<String> priorityLevels = ['friend', 'public', 'only me'];
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    postId = args['postId'];
    debugPrint("🆔 Received Post ID: $postId");
  }


  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
    print('Selected: $option'); // Debug print
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void createPost() {
    // Validation
    if (selectedImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedPricingOption.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a clicker type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedPriorityLevel.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select privacy level',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // TODO: Implement your API call here
    // Example data structure:
    Map<String, dynamic> postData = {
      'description': descriptionController.text.trim(),
      'clicker_type': selectedPricingOption.value,
      'privacy': selectedPriorityLevel.value,
      'images': selectedImages.map((file) => file.path).toList(),
    };

    print('Post Data: $postData');

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.back(); // Go back after posting
      Get.snackbar(
        'Success',
        'Post created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  //===========================================================post update
  void updatePost(String postId) {
    isLoading.value = true;

    Map<String, dynamic> postData = {
      'description': descriptionController.text.trim(),
      'clicker_type': selectedPricingOption.value,
      'privacy': selectedPriorityLevel.value,
      'images': selectedImages.map((file) => file.path).toList(),
    };

    print('====================================>>>>>>>>>>>>Post Data: $postData');

    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        'Success',
        'Post Updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
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