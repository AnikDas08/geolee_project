import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giolee78/features/profile/data/model/html_model.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/enum/enum.dart';

class HelpSupportController extends GetxController {
  /// Api status check here
  Status status = Status.completed;
  File? image;

  ///  HTML model initialize here
  HtmlModel data = HtmlModel.fromJson({});
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  /// Privacy Policy Controller instance create here
  static HelpSupportController get instance => Get.put(HelpSupportController());

  /// Image picker here
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      update();
    }
  }

  Future<void> supportAdminRepo() async {

    if (titleController.text.trim().isEmpty) {
      Utils.errorSnackBar(400, "Please enter issue title");
      return;
    }

    if (messageController.text.trim().isEmpty) {
      Utils.errorSnackBar(400, "Please enter description");
      return;
    }

    // if (image == null) {
    //   Utils.errorSnackBar(400, "Please attach a file");
    //   return;
    // }

    status = Status.loading;
    update();

    final response = await ApiService.multipart(
      ApiEndPoint.support,
      body: {
        "title": titleController.text.trim(),
        "message": messageController.text.trim(),
      },
      imagePath: image?.path,
    );

    if (response.statusCode == 200) {
      status = Status.completed;
      update();

      titleController.clear();
      messageController.clear();
      image = null;
      showSuccessDialog();

    } else {
      Utils.errorSnackBar("Error", response.message);
      status = Status.error;
      debugPrint("Response Is : >>>>>>>>>>>>>>>>>>>>>>>>>>${response.message}");
      update();
    }
  }


  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                "Success!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              const Text(
                "Thank you for your inquiry. Our team is looking into this and will get back to you soon.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Full-width Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
