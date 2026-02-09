import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/profile/presentation/controller/my_profile_controller.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giolee78/features/profile/data/model/user_profile_model.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/log/app_log.dart';
import '../../../home/presentation/controller/home_nav_controller.dart';

class ProfileController extends GetxController {

  /// Language List here
  List<String> languages = ["English", "French", "Arabic"];

  /// Form key
  final formKey = GlobalKey<FormState>();

  /// Selected language
  String selectedLanguage = "English";

  /// Selected image
  File? selectedImage;

  /// Loading state
  bool isLoading = false;

  UserProfileModel? profileModel;

  /// Image picker instance
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadAdvertiserStatus();
  }

  String? advertiserToken;
  bool isLoadingRole = true;

  Future<void> _loadAdvertiserStatus() async {
    advertiserToken = await getUserDataForRole();
    isLoadingRole = false;
    update(); 
  }

  /// Controllers
  TextEditingController nameController = TextEditingController()
    ..text = LocalStorage.myName;
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController aboutController = TextEditingController()
    ..text = LocalStorage.bio;
  TextEditingController dateOfBirthController = TextEditingController()
    ..text = LocalStorage.dateOfBirth.isNotEmpty
        ? LocalStorage.dateOfBirth.split('T').first
        : "";
  TextEditingController genderController = TextEditingController()
    ..text = LocalStorage.gender;
  TextEditingController addressController = TextEditingController();

  /// Request permission
  Future<bool> _requestImagePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) return true;

        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return false;
    }
  }

  /// Pick profile image
  Future<void> getProfileImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: Get.context!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      bool permissionGranted = await _requestImagePermission(source);
      if (!permissionGranted) {
        Get.snackbar(
          'Permission Required',
          'Please allow access',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && pickedFile.path.isNotEmpty) {
        selectedImage = File(pickedFile.path);
        update();
      }
    } catch (e) {
      appLog("Pick Image Error: $e");
    }
  }

  /// Pick date of birth
  Future<void> pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dateOfBirthController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      update();
    }
  }

  /// Select gender
  void selectGender(String gender) {
    genderController.text = gender;
    update();
  }

  /// Edit profile API
  Future<void> editProfileRepo() async {
    if (!formKey.currentState!.validate()) return;
    if (!LocalStorage.isLogIn) return;

    isLoading = true;
    update();

    try {
      DateTime? dobDate = DateTime.tryParse(dateOfBirthController.text.trim());
      if (dobDate == null) {
        Utils.errorSnackBar("Error", "Invalid Date of Birth");
        isLoading = false;
        update();
        return;
      }

      String formattedDob = dobDate.toUtc().toIso8601String();

      Map<String, String> body = {
        "name": nameController.text.trim(),
        "bio": aboutController.text.trim(),
        "dob": formattedDob,
        "gender": genderController.text.trim(),
      };

      var response = await ApiService.multipart(
        ApiEndPoint.updateProfile,
        method: "PATCH",
        body: body,
        imageName: 'image',
        imagePath: selectedImage?.path,
      );

      if (response.statusCode == 200) {
        var data = response.data;
        LocalStorage.myName = data['data']?["name"] ?? LocalStorage.myName;
        LocalStorage.myImage = data['data']?["image"] ?? LocalStorage.myImage;
        LocalStorage.bio = data['data']?['bio'] ?? LocalStorage.bio;
        LocalStorage.gender = data['data']?['gender'] ?? LocalStorage.gender;
        LocalStorage.dateOfBirth = data['data']?['dob'] ?? LocalStorage.dateOfBirth;

        await Future.wait([
          LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName),
          LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage),
          LocalStorage.setString(LocalStorageKeys.bio, LocalStorage.bio),
          LocalStorage.setString(LocalStorageKeys.gender, LocalStorage.gender),
          LocalStorage.setString(LocalStorageKeys.dateOfBirth, LocalStorage.dateOfBirth),
        ]);

        // ✅ FIXED: Use Get.find to update the actual UI controller instance
        if (Get.isRegistered<MyProfileController>()) {
          Get.find<MyProfileController>().getUserData();
        }

        // Refresh Navigation UI if needed
        if (Get.isRegistered<HomeNavController>()) {
          Get.find<HomeNavController>().update();
        }

        Utils.successSnackBar("Success", data['message'] ?? "Profile Updated Successfully");
        Get.back(); // Go back to profile screen
      } else {
        Utils.errorSnackBar("Error", response.data['message'] ?? "Failed to update profile");
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to update profile: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  String advToken = "";
  String userId = '';

  Future<String?> getUserDataForRole() async {
    try {
      var response = await ApiService.get(ApiEndPoint.profile).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        var data = response.data;
        advToken = data['data']?['advertiser']?.toString() ?? "";
        userId = data['data']?['_id']?.toString() ?? "";
        return advToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> changeRole(String newRole) async {
    LocalStorage.myRole = newRole;
    await LocalStorage.setString(LocalStorageKeys.myRole, newRole);
    update();
  }

  Future<void> deleteAccount() async {
    if (userId.isEmpty) return;
    isLoading = true;
    update();
    try {
      ApiResponseModel response = await ApiService.delete(ApiEndPoint.deleteAccount);
      if (response.statusCode == 200) {
        LocalStorage.removeAllPrefData();
        Get.offAllNamed(AppRoutes.signIn);
      }
    } catch (e) {
      appLog("Delete error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }
}
