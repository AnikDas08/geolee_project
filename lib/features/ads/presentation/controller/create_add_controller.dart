import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/button/common_button.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';

class CreateAdsController extends GetxController {
  // --- Observable State ---
  var coverImagePath = ''.obs;
  var selectedPricingPlan = 'weekly'.obs; // 'weekly' or 'monthly'

  // --- Text Controllers ---
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var focusAreaController = TextEditingController();
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var websiteLinkController = TextEditingController();
  var adStartDateController = TextEditingController(); // New controller for ad start date

  final ImagePicker _picker = ImagePicker();

  // --- Pricing Logic ---
  double get selectedPrice => selectedPricingPlan.value == 'weekly' ? 10.00 : 50.00;

  void selectPricingPlan(String plan) {
    selectedPricingPlan.value = plan;
  }

  // --- Image Picking Logic ---
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverImagePath.value = image.path;
      debugPrint('Image selected: ${image.path}');
    }
  }

  // --- Date/Time Picker Logic ---
  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.day.toString().padLeft(2, '0')} ${
          _getMonthAbbreviation(picked.month)} ${picked.year}";
    }
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  Future<void> selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final MaterialLocalizations localizations = MaterialLocalizations.of(context);
      controller.text = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
    }
  }

  // --- Payment & Dialog Logic ---
  void showPaymentConfirmationDialog(BuildContext context, double price) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Ad Creation & Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Your ad is ready to be submitted. Please confirm the price and proceed to payment:'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ad Price:',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${price.toStringAsFixed(2)}/${selectedPricingPlan.value == 'weekly' ? 'Weekly' : 'Monthly'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: CommonButton(
                  titleText: "Cancel",
                  onTap: () => Get.back(),
                  buttonColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  titleColor: Colors.black,
                  buttonHeight: 40,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CommonButton(
                  titleText: "Pay",
                  onTap: () {
                    Get.back();
                    _showSuccessPopup();
                  },
                  buttonColor: AppColors.primaryColor,
                  titleColor: Colors.white,
                  buttonHeight: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessPopup() {
    successPopUps(
      message:
      'Your Ad Submit successful. Please wait for admin approval before your ad goes live.',
      onTap: () {
        Get.offAllNamed(AppRoutes.homeNav);
      },
      buttonTitle: 'Done',
    );
  }

  void submitAd(BuildContext context) {
    showPaymentConfirmationDialog(context, selectedPrice);
  }

  @override
  void onClose() {
    // Dispose all text controllers properly
    titleController.dispose();
    descriptionController.dispose();
    focusAreaController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    websiteLinkController.dispose();
    adStartDateController.dispose();
    super.onClose();
  }
}