import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

class OtherHelper {
  static RegExp emailRegexp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])*(\.[a-zA-Z]{2,})+$",
  );
  static RegExp passRegExp = RegExp(r'(?=.*[a-z])(?=.*[0-9])');

  static final RegExp urlRegexp =
  RegExp(r'^(https?:\/\/)(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})(\/\S*)?$');

  static String? urlValidator(value) {
    if (value == null || value.trim().isEmpty) {
      return "Website link is required";
    }

    if (!value.startsWith("http://") && !value.startsWith("https://")) {
      return "URL must start with http:// or https://";
    }

    if (!urlRegexp.hasMatch(value)) {
      return "Enter a valid website link (e.g., https://example.com)";
    }

    return null;
  }


  static String? validator(value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? phoneNumberValidator(value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }


    String cleanValue = value.replaceAll(' ', '').replaceAll('-', '');


    final bool hasPlus = cleanValue.startsWith('+');
    if (hasPlus) {
      cleanValue = cleanValue.substring(1);
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return "Phone number can only contain digits (and optional +)";
    }

    final int digitCount = cleanValue.length;
    if (digitCount < 10) {
      return "Phone number must be at least 10 digits";
    }
    if (digitCount > 15) {
      return "Phone number cannot exceed 15 digits";
    }

    return null;
  }

  static String? emailValidator(value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!emailRegexp.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? passwordValidator(value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    } else if (value.length < 8) {
      return "Password must be at least 8 characters";
    } else if (!passRegExp.hasMatch(value)) {
      return "Password must contain letters and numbers";
    }
    return null;
  }

  static String? confirmPasswordValidator(
      value,
      TextEditingController passwordController,
      ) {
    if (value == null || value.isEmpty) {
      return "Please confirm password";
    } else if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  static Future<String> openDatePickerDialog(
      TextEditingController controller,
      ) async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
        ),
        child: child!,
      ),
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      controller.text = "${picked.year}/${picked.month}/${picked.day}";
      return picked.toIso8601String();
    }
    return "";
  }

  static Future<String?> openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    return image?.path;
  }

  static Future<String?> openGalleryForProfile() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      return croppedFile?.path;
    }
    return null;
  }

  static Future<String?> pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    return video?.path;
  }

  static Future<String?> openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    return image?.path;
  }

  static Future<String> openTimePickerDialog(
      TextEditingController? controller,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final String formattedTime = formatTime(picked);
      controller?.text = formattedTime;
      return formattedTime;
    }
    return '';
  }

  static String formatTime(TimeOfDay time) {
    return "${time.hour > 12 ? (time.hour - 12).toString().padLeft(2, '0') : (time.hour == 0 ? 12 : time.hour).toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? "PM" : "AM"}";
  }
}