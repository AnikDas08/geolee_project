import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/component/pop_up/common_pop_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/enum/enum.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_keys.dart';
import '../../../home/presentation/screen/home_nav_screen.dart';
import '../screen/verify_user.dart';

class ServiceProviderController extends GetxController {
  // Observables
  var selectedCategory = ''.obs;
  var selectedSubCategory = ''.obs;
  var experience = ''.obs;
  var skills = <String>[].obs;
  var profileImagePath = ''.obs;

  // Timer & OTP
  var start = 180.obs;
  var time = "03:00".obs;
  var isResendEnabled = false.obs;
  Timer? _timer;

  // Text controllers
  var businessNameController = TextEditingController();
  var businessTypeController = TextEditingController();
  var businessLicenseNumberController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var bioController = TextEditingController();
  var otpController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'Electrician';
    selectedSubCategory.value = 'Electrician';
    experience.value = '5 Years';
    skills.value = ['Electrician', 'House', 'Wiring'];
  }
  //
  // @override
  // void onClose() {
  //   businessNameController.dispose();
  //   businessTypeController.dispose();
  //   businessLicenseNumberController.dispose();
  //   phoneNumberController.dispose();
  //   bioController.dispose();
  //   otpController.dispose();
  //   _timer?.cancel();
  //   super.onClose();
  // }

  // ================= Image Picker =================
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) profileImagePath.value = image.path;
  }

  // ================= Skills =================
  final skillController = TextEditingController();

  void addSkill() {
    if (skillController.text.trim().isNotEmpty &&
        !skills.contains(skillController.text.trim())) {
      skills.add(skillController.text.trim());
      skillController.clear();
    } else {
      Get.snackbar('Duplicate Skill', 'This skill is already added',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeSkill(String skill) => skills.remove(skill);

  // ================= Advertiser Info =================
  Future<void> completeAdvertiserInfo() async {
    try {
      // Validations
      if (businessNameController.text.isEmpty) {
        Get.snackbar('Validation Error', 'Please Enter Your Business Name');
        return;
      }
      if (bioController.text.isEmpty) {
        Get.snackbar('Validation Error', 'Please Enter a Bio');
        return;
      }
      if (phoneNumberController.text.isEmpty) {
        Get.snackbar('Validation Error', 'Please Enter your Phone Number');
        return;
      }
      if (businessLicenseNumberController.text.isEmpty) {
        Get.snackbar(
            'Validation Error', 'Please Enter your Business License Number');
        return;
      }
      if (businessTypeController.text.isEmpty) {
        Get.snackbar('Validation Error', 'Please Enter your Business Type');
        return;
      }
      if (profileImagePath.value.isEmpty) {
        Get.snackbar('Validation Error', 'Please Select an Image');
        return;
      }

      // API Body & Header
      final body = {
        "businessName": businessNameController.text.trim(),
        "bio": bioController.text.trim(),
        "phone": phoneNumberController.text.trim(),
        "licenseNumber": businessLicenseNumberController.text.trim(),
        "businessType": businessTypeController.text.trim(),
      };


      // API Call
      final response = await ApiService.multipart(
        ApiEndPoint.advertiserCompleteProfile,
        body: body,
        imagePath: profileImagePath.value,
        imageName: "image",
        method: "POST",
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Advertiser info updated successfully");

        LocalStorage.myRole = UserType.advertiser.name;
        LocalStorage.setString(LocalStorageKeys.myRole, LocalStorage.myRole);


        Get.offAll(ProviderVerifyUser());
        startTimer();
      } else {
        Get.snackbar("Error", "Something went wrong");
        debugPrint("Error: ${response.message}");
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
  }

  // ================= Timer =================
  void startTimer() {
    _timer?.cancel();
    start.value = 180;
    isResendEnabled.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start.value > 0) {
        start.value--;
        final minutes = (start.value ~/ 60).toString().padLeft(2, '0');
        final seconds = (start.value % 60).toString().padLeft(2, '0');
        time.value = "$minutes:$seconds";
      } else {
        _timer?.cancel();
        isResendEnabled.value = true;
      }
    });
  }

  // ================= Resend OTP =================

  void resendOtp() async {
    if (!isResendEnabled.value) return;

    try {
      final body = {"email": LocalStorage.myEmail.toString().trim()};

      ApiResponseModel response = await ApiService.post(

        ApiEndPoint.resendOtp,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('OTP', "OTP Sent Successfully");
        startTimer();
      } else {
        Get.snackbar('Error', "OTP send failed");
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
  }

  // ================= Verify OTP =================
  void verifyOtp() async {
    try {
      final body = {
        "email": LocalStorage.myEmail.toString().trim(),
        "oneTimeCode": int.parse(otpController.text.trim())
      };

      ApiResponseModel response = await ApiService.post(
        header: {
          'Content-Type': 'application/json',
        },
        ApiEndPoint.advertiserVerify,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Verify', "OTP Verify SuccessFull");

        final data=response.data;

        LocalStorage.myRole = UserType.advertiser.name;
        LocalStorage.setString(LocalStorageKeys.myRole, LocalStorage.myRole);


        successPopUps(message: 'Verify Success', onTap: (){
          Get.offAll(HomeNav());

        }, buttonTitle: "Go To Dashboard");


      } else {
        Get.snackbar('Error', "OTP verification failed");
        debugPrint("Error: ${response.message}");
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
  }
}
