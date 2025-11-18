import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostController extends GetxController {
  final isLoading = false.obs;

  final selectedImage = Rxn<File>();
    var selectedImageName = ''.obs;

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

  selectGender(String gender) {
    selectedGender.value = gender;
  }

  createPost() {
    isLoading.value = true;
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        File file = File(image.path);
        selectedImage.value = file;
        selectedImageName.value = image.name;

        Get.back(); // Close bottom sheet

        Get.snackbar(
          'Success',
          'Image selected',
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

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        File file = File(image.path);
        selectedImage.value = file;
        selectedImageName.value = image.name;

        Get.back(); // Close bottom sheet

        Get.snackbar(
          'Success',
          'Photo captured',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Update subcategories when category is selected
}
