import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData, Response;
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../home/presentation/controller/home_controller.dart';
import '../../../home/presentation/screen/home_nav_screen.dart';

class PostController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print(selectedPriorityLevel.value);
  }

  final isLoading = false.obs;

  // Image handling
  final selectedImages = <File>[].obs;
  final int maxImages = 4;

  // Form controllers
  final description = TextEditingController();
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();

  final selectedPricingOption = ''.obs;
  final selectedPriorityLevel = ''.obs;
  final selectedGender = ''.obs;

  final List<String> priorityLevels = ['Friends', 'Public', 'Only me'];

  /// ✅ Image mapping for privacy level
  final Map<String, String> privacyImages = {
    'Friends': 'assets/images/friend.png',
    'Public': 'assets/images/public.png',
    'Only me': 'assets/images/only_me.png',
  };

  /// ✅ Get image path for privacy
  String getPrivacyImage(String privacyLevel) {
    return privacyImages[privacyLevel] ?? 'assets/icons/only_me.png';
  }

  final ImagePicker _picker = ImagePicker();

  String toTitleCase(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // ============================ CREATE POST ============================

  Future<void> createPost() async {
    if (selectedPricingOption.value.isEmpty) {
      _showError('Please select a clicker type');
      return;
    }

    // if (description.text.isEmpty) {
    //   _showError('Please write a description');
    //   return;
    // }

    if (selectedPriorityLevel.value.isEmpty) {
      _showError('Please select privacy');
      return;
    }
    //
    // if (selectedImages.isEmpty) {
    //   _showError('Please select at least one image');
    //   return;
    // }

    isLoading.value = true;

    try {
      final HomeController homeController = Get.find<HomeController>();
      await homeController.getCurrentLocationAndUpdateProfile();

      final List<MultipartFile> imageFiles = [];
      for (var file in selectedImages) {
        imageFiles.add(await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ));
      }

      final FormData formData = FormData.fromMap({
        'description': description.text.trim(),
        'clickerType': selectedPricingOption.value,
        'privacy': selectedPriorityLevel.value.toLowerCase(),
        'image': imageFiles,
      });

      final response = await ApiService.post(
        ApiEndPoint.createPost,
        body: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        homeController.refresh();

        successPopUps(
          message: 'Your Post Successfully Uploaded. Thank You.',
          onTap: () => Get.offAll(HomeNav()),
          buttonTitle: "Got It",
        );

        description.clear();
        selectedImages.clear();
        selectedPricingOption.value = '';
        selectedPriorityLevel.value = '';
      } else {
        _showError('Failed to create post');
      }
    } catch (e) {
      _showError('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================ IMAGE ============================

  void removeImageAtIndex(int index) {
    selectedImages.removeAt(index);
    Get.snackbar(
      'Removed',
      'Image removed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (selectedImages.length >= maxImages) {
      _showError('Maximum $maxImages images allowed');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      selectedImages.add(File(image.path));
    }
  }

  Future<void> pickImageFromGallery() async => _pickImage(ImageSource.gallery);
  Future<void> pickImageFromCamera() async => _pickImage(ImageSource.camera);

  // ============================ COMMON ============================

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    description.dispose();
    priceController.dispose();
    serviceTimeController.dispose();
    super.onClose();
  }
}