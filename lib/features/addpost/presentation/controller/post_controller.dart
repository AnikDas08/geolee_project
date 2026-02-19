import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData, Response;
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:image_picker/image_picker.dart';

import '../../../home/presentation/controller/home_controller.dart';

class PostController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    print(selectedPriorityLevel);
  }

  final isLoading = false.obs;

  // Image handling
  final selectedImages = <File>[].obs;
  final int maxImages = 4; // Define max image limit

  // Form controllers
  final description = TextEditingController();


  final selectedPricingOption = ''.obs;

  final selectedPriorityLevel = ''.obs;
  final priceController = TextEditingController();
  final serviceTimeController = TextEditingController();
  final selectedGender = ''.obs;

  final List<String> priorityLevels = ['friends', 'public', 'only me'];
  final ImagePicker _picker = ImagePicker();

  // ✅ This method now works for all 4 options

  void selectPricingOption(String option) {
    selectedPricingOption.value = option;
    print('Selected: $option'); // Debug print
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  //==================================================== Create Post=========================
  Future<void> createPost() async {
    if (selectedPricingOption.value.isEmpty) {
      Get.snackbar(
        'Field Missing',
        'Please select a clicker type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (description.value.text.isEmpty) {
      Get.snackbar(
        'Field Missing',
        'Please Write a description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedPricingOption.value.isEmpty) {
      Get.snackbar(
        'Field Missing',
        'Please Select a clicker type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedPriorityLevel.value.isEmpty) {
      Get.snackbar(
        'Field Missing',
        'Please Select Privacy ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final HomeController _homeController = Get.find<HomeController>();
      await _homeController.getCurrentLocationAndUpdateProfile();

      final List<MultipartFile> imageFiles = [];
      for (var file in selectedImages) {
        imageFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      if (imageFiles.isEmpty) {
        Get.snackbar(
          "Field Missing",
          "Please Select an image",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final FormData formData = FormData.fromMap({
        'description': description.text.trim(),
        'clickerType': selectedPricingOption.value,
        'privacy': selectedPriorityLevel.value.toLowerCase(),
        'image': imageFiles,
      });

      // Response response = await Dio().post(
      //   'https://yourapi.com/posts', // এখানে তোমার API URL
      //   data: formData,
      // );

      final url = "${ApiEndPoint.createPost}";

      final response = await ApiService.post(url, body: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Post created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear after successful post
        description.clear();
        selectedImages.clear();
        selectedPricingOption.value = '';
        selectedPriorityLevel.value = '';
      } else {
        debugPrint('Response  is =>>>>>>>>>>>>>>>>>>>>>>$response');
        Get.snackbar(
          'Error',
          'Failed to create post',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
        final File file = File(image.path);
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
