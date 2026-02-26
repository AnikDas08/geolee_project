import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:image_picker/image_picker.dart';

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import '../../../../component/pop_up/common_pop_menu.dart';
import '../../data/plan_model.dart';
import '../../data/single_ads_model.dart';

class UpdateAdsController extends GetxController {
  /// ---------------- OBSERVABLES ----------------
  var coverImagePath = ''.obs;
  var selectedPricingPlan = ''.obs; // weekly | monthly
  var isLoading = false.obs;

  var plans = <PlanModel>[].obs;
  var isPlansLoading = false.obs;

  late String adsId;
  SingleAdvertisement? ad;

  /// ---------------- TEXT CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final focusAreaController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final adStartDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    adsId = Get.arguments;
    _loadInitialData();
  }

  /// ---------------- LOAD INITIAL DATA ----------------
  Future<void> _loadInitialData() async {
    await Future.wait([
      fetchAdById(),
      fetchPlans(),
    ]);
  }

  /// ---------------- FETCH SINGLE AD ----------------
  Future<void> fetchAdById() async {
    isLoading.value = true;

    try {
      final endpoint = "${ApiEndPoint.getAdvertisementById}$adsId";
      print("🌐 Fetching ad from: $endpoint");

      final ApiResponseModel response = await ApiService.get(endpoint);

      print("📦 Response Status: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        ad = SingleAdvertisement.fromJson(response.data['data']);

        print("✅ Ad loaded: ${ad?.title}");

        // Set text fields
        titleController.text = ad?.title ?? '';
        descriptionController.text = ad?.description ?? '';
        focusAreaController.text = ad?.focusArea ?? '';
        websiteLinkController.text = ad?.websiteUrl ?? '';

        // Handle date
        print("📅 Raw startAt: ${ad?.startAt}");

        String? dateString;
        if (ad?.startAt != null) {
          if (ad!.startAt is String) {
            dateString = ad!.startAt as String;
          } else {
            dateString = ad!.startAt.toString();
          }
        }

        print("📅 Date String: $dateString");

        final parsedDate = _safeParseDate(dateString)?.toLocal();
        print("📅 Parsed Date: $parsedDate");

        if (parsedDate != null) {
          adStartDateController.text =
          "${parsedDate.day.toString().padLeft(2, '0')} "
              "${_month(parsedDate.month)} "
              "${parsedDate.year}";
          print("📅 Formatted Date: ${adStartDateController.text}");
        } else {
          print("❌ Date parsing failed!");
        }

        // Handle image
        appLog("🖼️ Raw image: ${ad?.image}");

        if (ad?.image != null && ad!.image.isNotEmpty) {
          // Store only the image path/filename, not the full URL
          coverImagePath.value = ad!.image;
          appLog("🖼️ Image Path: ${coverImagePath.value}");
        } else {
          appLog("❌ No image found!");
        }

        // Handle plan
        appLog("💰 Raw plan: ${ad?.plan}");
        if (ad?.plan != null && ad!.plan.isNotEmpty) {
          selectedPricingPlan.value = ad!.plan.toLowerCase().trim();
          appLog("💰 Selected Plan: ${selectedPricingPlan.value}");
        }
      } else {
        appLog("❌ Invalid response");
        Get.snackbar("Error", "Failed to load ad data");
      }
    } catch (e, stackTrace) {
      appLog("❌ Fetch Ad Error: $e");
      appLog("❌ Stack Trace: $stackTrace");
      Get.snackbar("Error", "Failed to load ad data: $e");
    }

    isLoading.value = false;
    update();
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
      print("🖼️ New image picked: ${coverImagePath.value}");
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
  DateTime _parseUiDate() {
    final parts = adStartDateController.text.split(' ');
    return DateTime(
      int.parse(parts[2]),
      _monthToNumber(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _formatIsoDateTime(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  String getIsoStartDate() {
    final selectedDate = _parseUiDate();
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
    final int daysToAdd = selectedPricingPlan.value.toLowerCase() == 'weekly' ? 7 : 30;
    final selectedDate = _parseUiDate();
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
    );
    final DateTime endDate = dateTime.add(Duration(days: daysToAdd));
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
      'Dec',
    ];
    return months[m - 1];
  }

  /// ---------------- FETCH PLANS ----------------
  Future<void> fetchPlans() async {
    try {
      isPlansLoading.value = true;
      final ApiResponseModel response = await ApiService.get(ApiEndPoint.getPlans);

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = response.data as Map<String, dynamic>;
        final List<dynamic> dataList = res['data'] ?? [];

        plans.value = dataList.map((e) => PlanModel.fromJson(e)).toList();

        debugPrint("📦 Plans loaded: ${plans.length}");

        // Don't override selectedPricingPlan if already set from ad data
        if (plans.isNotEmpty && selectedPricingPlan.value.isEmpty) {
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

  /// ---------------- UPDATE ADS ----------------
  Future<void> updateAds() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      appLog("📤 Updating ad: $adsId");
      appLog("🖼️ Image path: ${coverImagePath.value}");

      // যদি image path local file path না হয়, শুধু text body পাঠাও
      final bool isLocalImage = File(coverImagePath.value).existsSync();

      final ApiResponseModel response = await ApiService.multipartUpdate(
        ApiEndPoint.updateAdvertisementById + adsId,
        body: {
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "focusArea": focusAreaController.text.trim(),
          "latitude": "23.810332",
          "longitude": "90.4125181",
          "websiteUrl": websiteLinkController.text.trim(),
        },
        imagePath: isLocalImage ? coverImagePath.value : null,
      );

      print("📦 Update Response: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessPopup();
      } else {
        debugPrint("Error Is 😜 ${response.message}");
        Get.snackbar("Error", response.message ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint("❌ Update Ads Error: $e");
      Get.snackbar("Error", "Failed to update ad");
    } finally {
      isLoading.value = false;
    }
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
      "${picked.day.toString().padLeft(2, '0')} ${_month(picked.month)} ${picked.year}";
      print("📅 Date selected: ${controller.text}");
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




  /// ---------------- DISPOSE ----------------
  @override
  void onClose() {
    // titleController.dispose();
    // descriptionController.dispose();
    // focusAreaController.dispose();
    // websiteLinkController.dispose();
    // adStartDateController.dispose();
    super.onClose();
  }
}