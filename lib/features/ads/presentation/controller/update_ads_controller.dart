import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';
import '../../data/single_ads_model.dart';

class UpdateAdsController extends GetxController {
  /// ---------------- OBSERVABLES ----------------
  RxString coverImagePath = ''.obs;
  RxString selectedPricingPlan = 'weekly'.obs;
  RxBool isLoading = false.obs;

  late String adsId;
  SingleAdvertisement? ad;

  /// ---------------- TEXT CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final focusAreaController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final adStartDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  /// ---------------- PLAN IDS ----------------
  final String weeklyPlanId = 'WEEKLY_PLAN_ID_HERE';
  final String monthlyPlanId = '6982d85cfcd98da54506b87';

  String get planId =>
      selectedPricingPlan.value == 'weekly' ? weeklyPlanId : monthlyPlanId;

  double get selectedPrice =>
      selectedPricingPlan.value == 'weekly' ? 10.0 : 50.0;

  @override
  void onInit() {
    super.onInit();
    adsId = Get.arguments;
    fetchAdById(); // 🔥 update এর আগে data load
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
    return true;
  }

  /// ---------------- SAFE DATE PARSE ----------------
  DateTime? _safeParseDate(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }

  String _formatIso(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  String getIsoStartDate() {
    final parts = adStartDateController.text.split(' ');
    final date = DateTime(
      int.parse(parts[2]),
      _monthToNumber(parts[1]),
      int.parse(parts[0]),
    );
    return _formatIso(date);
  }

  String getIsoEndDate() {
    int days = selectedPricingPlan.value == 'weekly' ? 7 : 30;
    final start = DateTime.parse(getIsoStartDate());
    return _formatIso(start.add(Duration(days: days)));
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
      'Dec',
    ];
    return months[m - 1];
  }

  /// ---------------- FETCH SINGLE AD ----------------
  Future<void> fetchAdById() async {
    isLoading.value = true;
    update();

    try {
      final endpoint = "${ApiEndPoint.getAdvertisementById}$adsId";
      ApiResponseModel response = await ApiService.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        ad = SingleAdvertisement.fromJson(response.data['data']);

        titleController.text = ad?.title ?? '';
        descriptionController.text = ad?.description ?? '';
        focusAreaController.text = ad?.focusArea ?? '';
        websiteLinkController.text = ad?.websiteUrl ?? '';

        // 🔥 Fix: Parse and format date properly
        final parsedDate = _safeParseDate(ad!.startAt as String?)?.toLocal();

        if (parsedDate != null) {
          adStartDateController.text =
          "${parsedDate.day.toString().padLeft(2, '0')} "
              "${_month(parsedDate.month)} "
              "${parsedDate.year}";
        }

            coverImagePath.value = ad!.image;

        update();
        if (ad?.plan != null) {
          selectedPricingPlan.value = ad!.plan.toLowerCase();
        }

        update();

        debugPrint("✅ Image Path: ${coverImagePath.value}");
        debugPrint("✅ Start Date: ${adStartDateController.text}");
      }
    } catch (e) {
      debugPrint("❌ Fetch Ad Error: $e");
    }

    isLoading.value = false;
    update();
  }

  /// ---------------- UPDATE ADS ----------------
  Future<void> updateAds() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      ApiResponseModel response = await ApiService.multipartUpdate(
        ApiEndPoint.updateAdvertisementById + adsId,
        method: "PATCH",
        body: {
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "focusArea": focusAreaController.text.trim(),
          "latitude": "23.810332",
          "longitude": "90.4125181",
          "websiteUrl": websiteLinkController.text.trim(),
        },
        imageName: 'image',
        imagePath: coverImagePath.value,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessPopup();
      } else {
        Get.snackbar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint("Create Ads Error: $e");
      Get.snackbar("Error", "Failed to update ad");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- SUCCESS ----------------
  void _showSuccessPopup() {
    successPopUps(
      message: 'Your Ad updated successfully. Please wait for admin approval.',
      buttonTitle: 'Done',
      onTap: () {
        Get.back();
      },
    );
  }

  /// ---------------- DATE PICKER ----------------
  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
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