import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostController extends GetxController {
  final isLoading = false.obs;

  // Image handling
  final selectedImages = <File>[].obs;
  final int maxImages = 4; // Define max image limit

  // Form controllers
  final discriptions = TextEditingController();

  // ✅ FIXED: Empty initial value - no button selected by default
  final selectedPricingOption = ''.obs;

  final selectedPriorityLevel = ''.obs;
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();
  final selectedGender = ''.obs;

  final List<String> priorityLevels = ['Friend', 'Public', 'Only Me'];
  final ImagePicker _picker = ImagePicker();

  // ✅ This method now works for all 4 options
  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
    print('Selected: $option'); // Debug print
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void createPost() {
    // Validation


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

    isLoading.value = true;

    // TODO: Implement your API call here
    // Example data structure:
    Map<String, dynamic> postData = {
      'description': discriptions.text.trim(),
      'clicker_type': selectedPricingOption.value,
      'privacy': selectedPriorityLevel.value,
      'images': selectedImages.map((file) => file.path).toList(),
    };

    //print('Post Data: $postData');

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Post created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }

  // Image management methods
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
    if (selectedImages.length >= maxImages) {
      Get.snackbar(
        'Limit Reached',
        'You can only upload a maximum of $maxImages images.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade700,
        colorText: Colors.white,
      );
      return;
    }

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
          'Image selected (${selectedImages.length}/$maxImages)',
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
    //discriptions.dispose();
    priceController.dispose();
    serviceTimeController.dispose();
    super.onClose();
  }
}