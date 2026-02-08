import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';
import '../../data/plan_model.dart';

/// ---------------- CONTROLLER ----------------
class CreateAdsController extends GetxController {
  /// ---------------- OBSERVABLES ----------------
  var coverImagePath = ''.obs;
  var selectedPricingPlan = ''.obs; // weekly | monthly
  var isLoading = false.obs;

  var plans = <PlanModel>[].obs; // fetched plans
  var isPlansLoading = false.obs;

  /// ---------------- TEXT CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final focusAreaController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final adStartDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// ---------------- PLAN ID & PRICE ----------------
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
      Get.snackbar("Error", "Please select a valid pricing plan");
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

  // 🔥 FIX: Return ISO 8601 datetime string with timezone
  String _formatIsoDateTime(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // 🔥 FIX: Use datetime format instead of date-only
  String getIsoStartDate() {
    final selectedDate = _parseUiDate();
    // Set time to current time or beginning of day
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
    );
    return _formatIsoDateTime(dateTime);
  }

  String getIsoEndDate() {
    int daysToAdd = selectedPricingPlan.value.toLowerCase() == 'weekly' ? 7 : 30;
    final selectedDate = _parseUiDate();
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
    );
    DateTime endDate = dateTime.add(Duration(days: daysToAdd));
    return _formatIsoDateTime(endDate);
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m - 1];
  }

  /// ---------------- FETCH PLANS ----------------
  Future<void> fetchPlans() async {
    try {
      isPlansLoading.value = true;
      ApiResponseModel response = await ApiService.get(ApiEndPoint.getPlans);

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> res = response.data as Map<String, dynamic>;
        List<dynamic> dataList = res['data'] ?? [];

        plans.value = dataList.map((e) => PlanModel.fromJson(e)).toList();

        debugPrint("📦 Plans loaded: ${plans.length}");

        if (plans.isNotEmpty) {
          selectedPricingPlan.value = plans.first.name;
        }
      } else {
        Get.snackbar("Error", response.message ?? "Failed to load plans");
      }
    } catch (e) {
      debugPrint("❌ Fetch Plans Error: $e");
      Get.snackbar("Error", "Failed to load plans");
    } finally {
      isPlansLoading.value = false;
    }
  }

  /// ---------------- CREATE ADS ----------------
  Future<void> createAds() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      final startDate = getIsoStartDate();

      print("📅 Start Date (ISO): $startDate");
      print("💰 Plan ID: $planId");
      print("🖼️ Image Path: ${coverImagePath.value}");

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
          "startAt": startDate, // 🔥 Now sends full ISO 8601 datetime
          "plan": planId,
        },
        imageName: 'image',
        imagePath: coverImagePath.value,
      );

      print("📦 Response Status: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessPopup();
      } else {
        Get.snackbar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint("❌ Create Ads Error: $e");
      Get.snackbar("Error", "Failed to create ad");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- DATE PICKER ----------------
  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
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
      message: 'Your Ad submitted successfully. Please wait for admin approval.',
      buttonTitle: 'Done',
      onTap: () {
        Get.offAllNamed(AppRoutes.homeNav);
      },
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