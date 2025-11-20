import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceProviderController extends GetxController {
  // Observable variables
  var selectedCategory = ''.obs;
  var selectedSubCategory = ''.obs;
  var experience = ''.obs;
  var skillInput = ''.obs;
  var skills = <String>[].obs;

  Timer? _timer;
  int start = 0;

  String time = "";

  var businessNameController = TextEditingController();
  var businessTypeController = TextEditingController();
  var businessLicenseNumberController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var bioController = TextEditingController();
  var emailController = TextEditingController();
  var otpController = TextEditingController();

  // Dropdown options
  final categories = ['Electrician', 'Plumber', 'Carpenter', 'Painter'].obs;
  final subCategories = [
    'Electrician',
    'Home Electrician',
    'Industrial Electrician',
  ].obs;

  // Text controller for skill input
  final skillController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values from screenshot
    selectedCategory.value = 'Electrician';
    selectedSubCategory.value = 'Electrician';
    experience.value = '5 Years';
    skills.value = ['Electrician', 'House', 'Wiring'];
  }

  @override
  void onClose() {
    skillController.dispose();
    super.onClose();
  }

  // Method to add skill
  void addSkill() {
    if (skillController.text.trim().isNotEmpty) {
      if (!skills.contains(skillController.text.trim())) {
        skills.add(skillController.text.trim());
        skillController.clear();
      } else {
        Get.snackbar(
          'Duplicate Skill',
          'This skill is already added',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Method to remove skill
  void removeSkill(String skill) {
    skills.remove(skill);
  }

  // Method to confirm and submit
  void confirmInfo() {
    if (selectedCategory.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedSubCategory.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a sub category',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (experience.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your experience',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (skills.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please add at least one skill',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    debugPrint('Category: ${selectedCategory.value}');
    debugPrint('Sub Category: ${selectedSubCategory.value}');
    debugPrint('Experience: ${experience.value}');
    debugPrint('Skills: ${skills.join(", ")}');

    Get.snackbar(
      'Success',
      'Service provider info updated successfully',
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.back();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    start = 180; // Reset the start value
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        final minutes = (start ~/ 60).toString().padLeft(2, '0');
        final seconds = (start % 60).toString().padLeft(2, '0');

        time = "$minutes:$seconds";

        update();
      } else {
        _timer?.cancel();
      }
    });
  }
}
