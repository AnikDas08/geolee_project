import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_keys.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';

class AdvertiserEditProfileController extends GetxController {
  // ================= VARIABLES =================
  List<String> languages = ["English", "French", "Arabic"];
  final formKey = GlobalKey<FormState>();
  String selectedLanguage = "English";
  File? selectedImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // TextControllers
  late TextEditingController businessNameController;
  late TextEditingController businessLicenceController;
  late TextEditingController businessTypeController;
  late TextEditingController phoneNumberController;
  late TextEditingController bioController;

  // ================= ON INIT =================
  @override
  void onInit() {
    super.onInit();
    _loadLocalStorageData();
  }

  // ================= LOAD FROM LOCAL STORAGE =================
  void _loadLocalStorageData() {
    businessNameController =
        TextEditingController(text: LocalStorage.businessName);
    businessLicenceController =
        TextEditingController(text: LocalStorage.businessLicenceNumber);
    businessTypeController =
        TextEditingController(text: LocalStorage.businessType);
    phoneNumberController =
        TextEditingController(text: LocalStorage.phone);
    bioController = TextEditingController(text: LocalStorage.advertiserBio);

    // Optional: language load if saved before

  }

  // ================= IMAGE PICKER =================
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
          'Please allow ${source == ImageSource.camera ? 'camera' : 'storage'} access',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
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
        Get.snackbar(
          'Success',
          'Image selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // ================= LANGUAGE SELECT =================
  void selectLanguage(int index) {
    selectedLanguage = languages[index];

    update();
    Get.back();
  }

  // ================= EDIT PROFILE API =================
  Future<void> editProfileRepo() async {
    if (!formKey.currentState!.validate()) return;
    if (!LocalStorage.isLogIn) return;

    isLoading = true;
    update();

    try {
      Map<String, String> body = {
        "businessName": businessNameController.text.trim(),
        "bio": bioController.text.trim(),
        "businessType": businessTypeController.text.trim(),
        "licenseNumber": businessLicenceController.text.trim(),
        "phone": phoneNumberController.text.trim(),
      };

      var response = await ApiService.multipart(
        ApiEndPoint.advertiserUpdate,
        method: "PATCH",
        body: body,
        imageName: 'image',
        imagePath: selectedImage?.path,
      );

      if (response.statusCode == 200) {
        var advertiserData = response.data['data'] ?? {};

        // ========== LOCAL STORAGE UPDATE ==========
        LocalStorage.userId = advertiserData["_id"] ?? LocalStorage.userId;
        LocalStorage.businessName =
            advertiserData["businessName"] ?? LocalStorage.businessName;
        LocalStorage.businessType =
            advertiserData["businessType"] ?? LocalStorage.businessType;
        LocalStorage.phone = advertiserData["phone"] ?? LocalStorage.phone;
        LocalStorage.advertiserBio = advertiserData["bio"] ?? LocalStorage.advertiserBio;
        LocalStorage.businessLogo =
            advertiserData["logo"] ?? LocalStorage.businessLogo;
        LocalStorage.myImage = selectedImage?.path ?? LocalStorage.myImage;

        // ========== SAVE TO SHARED PREFERENCES ==========
        await Future.wait([
          LocalStorage.setString(
              LocalStorageKeys.businessName, LocalStorage.businessName),
          LocalStorage.setString(
              LocalStorageKeys.businessType, LocalStorage.businessType),
          LocalStorage.setString(LocalStorageKeys.phone, LocalStorage.phone),
          LocalStorage.setString(
              LocalStorageKeys.businessLogo, LocalStorage.businessLogo),
          LocalStorage.setString(LocalStorageKeys.advertiserBio, LocalStorage.advertiserBio),
          LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage),
        ]);

        Utils.successSnackBar(
            "Success", response.data['message'] ?? "Profile Updated Successfully");

        Get.toNamed(AppRoutes.profile);
      } else {
        Utils.errorSnackBar(
          response.statusCode.toString(),
          response.data['message'] ?? "Failed to update profile",
        );
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to update profile: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  // ================= LIFE CYCLE =================
  @override
  void onClose() {
    businessNameController.dispose();
    businessLicenceController.dispose();
    businessTypeController.dispose();
    phoneNumberController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
