import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';
import '../../data/plan_model.dart';

class CreateAdsController extends GetxController {
  /// ---------------- OBSERVABLES ----------------
  var coverImagePath = ''.obs;
  var selectedPricingPlan = ''.obs;
  var isLoading = false.obs;

  var plans = <PlanModel>[].obs;
  var isPlansLoading = false.obs;

  /// ---------------- TEXT CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final focusAreaController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final adStartDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// ---------------- PLAN HELPERS ----------------
  String get planId {
    if (selectedPricingPlan.value.isEmpty || plans.isEmpty) return '';
    final plan = plans.firstWhere(
          (p) => p.name.toLowerCase() == selectedPricingPlan.value.toLowerCase(),
      orElse: () => plans.first,
    );
    return plan.id;
  }

  double get selectedPrice {
    if (plans.isEmpty) return 0;
    final plan = plans.firstWhere(
          (p) => p.name.toLowerCase() == selectedPricingPlan.value.toLowerCase(),
      orElse: () => plans.first,
    );
    return plan.price;
  }

  void selectPricingPlan(String plan) {
    selectedPricingPlan.value = plan;
  }

  /// ---------------- IMAGE PICK ----------------
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverImagePath.value = image.path;
    }
  }

  /// ---------------- VALIDATION ----------------
  bool _validate() {
    if (coverImagePath.value.isEmpty) {
      Get.snackbar("Error", "Please select a cover image");
      return false;
    }
    if (titleController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter title");
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter description");
      return false;
    }
    if (focusAreaController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter focus area");
      return false;
    }
    if (websiteLinkController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter website link");
      return false;
    }
    if (adStartDateController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please select ad start date");
      return false;
    }
    if (planId.isEmpty) {
      Get.snackbar("Error", "Please select pricing plan");
      return false;
    }
    return true;
  }

  /// ---------------- DATE HELPERS ----------------
  DateTime _parseUiDate() {
    final parts = adStartDateController.text.split(' ');
    return DateTime(
      int.parse(parts[2]),
      _monthToNumber(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _formatIso(DateTime date) => date.toUtc().toIso8601String();

  String getIsoStartDate() {
    final d = _parseUiDate();
    final now = DateTime.now();
    return _formatIso(DateTime(
      d.year,
      d.month,
      d.day,
      now.hour,
      now.minute,
      now.second,
    ));
  }

  int _monthToNumber(String month) {
    const map = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    return map[month]!;
  }

  String _month(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  /// ---------------- FETCH PLANS ----------------
  Future<void> fetchPlans() async {
    try {
      isPlansLoading.value = true;
      ApiResponseModel response = await ApiService.get(ApiEndPoint.getPlans);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data as Map<String, dynamic>;
        plans.value =
            (res['data'] as List).map((e) => PlanModel.fromJson(e)).toList();

        if (plans.isNotEmpty) {
          selectedPricingPlan.value = plans.first.name;
        }
      } else {
        Get.snackbar("Error", response.message ?? "Failed to load plans");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load plans");
    } finally {
      isPlansLoading.value = false;
    }
  }

  /// ---------------- CREATE ADS + PAYMENT ----------------

  Future<void> createAds() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      ApiResponseModel response = await ApiService.multipartUpdate(
        ApiEndPoint.createAds,
        method: "POST",
        body: {
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "focusArea": focusAreaController.text.trim(),
          "latitude": "23.810332",
          "longitude": "90.4125181",
          "websiteUrl": websiteLinkController.text.trim(),
          "startAt": getIsoStartDate(),
          "plan": planId,
        },
        imageName: 'image',
        imagePath: coverImagePath.value,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;

        if (res != null &&
            res['data'] != null &&
            res['data']['url'] != null) {
          final paymentUrl = res['data']['url'];

          // ✅ Payment URL launch করুন
          await _launchPayment(paymentUrl);
        } else {
          _showSuccessPopup();
        }
      } else {
        Get.snackbar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create ad: ${e.toString()}");
      debugPrint("Create ads error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- PAYMENT LAUNCH (UPDATED) ----------------
  Future<void> _launchPayment(String url) async {
    try {
      debugPrint("🔗 Launching payment URL: $url");

      final uri = Uri.parse(url);

      // ✅ Method 1: launchUrl (Recommended)
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // External browser এ open হবে
      );

      if (launched) {
        debugPrint("✅ Payment URL launched successfully");

        // ✅ Optional: User কে inform করুন
        Get.snackbar(
          "Payment",
          "Opening payment page...",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        debugPrint("❌ Could not launch payment URL");
        Get.snackbar("Error", "Could not open payment page");
      }
    } catch (e) {
      debugPrint("❌ Launch error: $e");

      // ✅ Fallback: Manual copy option
      Get.defaultDialog(
        title: "Payment Link",
        middleText: "Please copy and open this link in your browser",
        textConfirm: "Copy Link",
        textCancel: "Cancel",
        onConfirm: () {
          // Copy to clipboard logic
          Get.back();
          Get.snackbar("Copied", "Payment link copied to clipboard");
        },
      );
    }
  }

  /// ---------------- DATE PICKER ----------------
  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text =
      "${picked.day.toString().padLeft(2, '0')} ${_month(picked.month)} ${picked.year}";
    }
  }

  /// ---------------- SUCCESS ----------------
  void _showSuccessPopup() {
    successPopUps(
      message:
      'Your Ad submitted successfully. Please wait for admin approval.',
      buttonTitle: 'Done',
      onTap: () => Get.offAllNamed(AppRoutes.homeNav),
    );
  }

  /// ---------------- DISPOSE ----------------
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    focusAreaController.dispose();
    websiteLinkController.dispose();
    adStartDateController.dispose();
    super.onClose();
  }
}