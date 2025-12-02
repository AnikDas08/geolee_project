import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';

class CreateAdsController extends GetxController {
  // --- Observable State ---
  var coverImagePath = ''.obs; // Holds the file path of the selected image

  // --- Text Controllers ---
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var focusAreaController = TextEditingController();
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var websiteLinkController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  // --- Image Picking Logic ---
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverImagePath.value = image.path;
      debugPrint('Image selected: ${image.path}');
    }
  }

  // --- Date Picker Logic ---
  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Start from today
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Format the date as 'DD Mon YYYY' (e.g., 01 Jan 2020)
      controller.text = "${picked.day.toString().padLeft(2, '0')} ${
          _getMonthAbbreviation(picked.month)} ${picked.year}";
    }
  }

  // Helper to get month abbreviation
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
      // Format the time as 'hh:mm AM/PM'
      final MaterialLocalizations localizations = MaterialLocalizations.of(context);
      controller.text = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
    }
  }

  void submitAd(BuildContext context) {
    successPopUps(
      message:
      'Your Asd Submit successful. Please wait for admin approval before your ad goes live.',
      onTap: () {
        Get.offAllNamed(AppRoutes.homeNav);
      },
      buttonTitle: 'Done',
    );
  }

}