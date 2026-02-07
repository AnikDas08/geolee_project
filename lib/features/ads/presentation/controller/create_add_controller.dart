import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';

class CreateAdsController extends GetxController {
  /// ---------------- OBSERVABLES ----------------
  var coverImagePath = ''.obs;
  var selectedPricingPlan = 'weekly'.obs; // weekly | monthly
  var isLoading = false.obs;

  /// ---------------- TEXT CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final focusAreaController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final adStartDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// ---------------- PLAN IDS (BACKEND) ----------------
  /// এগুলো backend থেকে আসবে ideally
  final String weeklyPlanId = 'WEEKLY_PLAN_ID_HERE';
  final String monthlyPlanId = '6982d85cfcd98da54506b87';

  String get planId =>
      selectedPricingPlan.value == 'weekly'
          ? weeklyPlanId
          : monthlyPlanId;

  double get selectedPrice =>
      selectedPricingPlan.value == 'weekly' ? 10.0 : 50.0;

  void selectPricingPlan(String plan) {
    selectedPricingPlan.value = plan;
  }

  /// ---------------- IMAGE PICK ----------------
  Future<void> pickImage() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);
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
    return true;
  }

  /// ---------------- DATE HELPERS ----------------

  /// UI format → 07 Feb 2026
  /// API format → 2026-02-07
  DateTime _parseUiDate() {
    final parts = adStartDateController.text.split(' ');
    return DateTime(
      int.parse(parts[2]),
      _monthToNumber(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _formatIso(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String getIsoStartDate() {
    return _formatIso(_parseUiDate());
  }

  String getIsoEndDate() {
    int daysToAdd =
    selectedPricingPlan.value == 'weekly' ? 7 : 30;
    DateTime endDate =
    _parseUiDate().add(Duration(days: daysToAdd));
    return _formatIso(endDate);
  }

  int _monthToNumber(String month) {
    const map = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
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

  /// ---------------- CREATE ADS ----------------
  Future<void> createAds() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      ApiResponseModel response =
      await ApiService.multipartUpdate(
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
          "endAt": getIsoEndDate(),
          "plan": selectedPricingPlan.value,
        },
        imageName: 'image',
        imagePath: coverImagePath.value,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        _showSuccessPopup();
      } else {
        Get.snackbar(
            "Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint("Create Ads Error: $e");
      Get.snackbar("Error", "Failed to create ad");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- PAYMENT FLOW ----------------
  void submitAd(BuildContext context) {
    if (!_validate()) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Price: \$${selectedPrice.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              createAds();
            },
            child: const Text("Pay & Submit"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// ---------------- SUCCESS ----------------
  void _showSuccessPopup() {
    successPopUps(
      message:
      'Your Ad submitted successfully. Please wait for admin approval.',
      buttonTitle: 'Done',
      onTap: () {
        Get.offAllNamed(AppRoutes.homeNav);
      },
    );
  }

  /// ---------------- DATE PICKER ----------------
  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text =
      "${picked.day.toString().padLeft(2, '0')} "
          "${_month(picked.month)} "
          "${picked.year}";
    }
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
