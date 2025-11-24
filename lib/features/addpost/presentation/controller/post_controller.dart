import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostController extends GetxController {
  final isLoading = false.obs;

  // ➡️ UPDATED: Use a list for multiple images
  final selectedImages = <File>[].obs;
  final int maxImages = 4; // Define max image limit

  final descriptionController = TextEditingController();
  final selectedPricingOption = 'Great Vibes'.obs;
  final selectedPriorityLevel = ''.obs;
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();
  final selectedGender = ''.obs;
  final List<String> priorityLevels = ['Friend', 'Public', 'Only Me'];
  final ImagePicker _picker = ImagePicker();

  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void createPost() {
    isLoading.value = true;
    // Implement post creation logic here
    // Example: send selectedImages.value and other data
    // After logic: isLoading.value = false;
  }

  // ➡️ NEW: Method to remove an image by index
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

  // ➡️ UPDATED: Logic to add image to the list
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
        imageQuality: 70, // Slightly reduced quality for performance
      );

      if (image != null) {
        File file = File(image.path);
        selectedImages.add(file); // Add to the list

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
}