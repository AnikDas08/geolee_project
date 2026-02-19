import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_keys.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../profile/presentation/screen/dashboard_profile.dart';

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
    _initializeControllers();
    fetchAdvertiserProfile();
  }

  // ================= INITIALIZE CONTROLLERS =================
  void _initializeControllers() {
    businessNameController = TextEditingController();
    businessLicenceController = TextEditingController();
    businessTypeController = TextEditingController();
    phoneNumberController = TextEditingController();
    bioController = TextEditingController();
  }

  // ================= FETCH ADVERTISER PROFILE =================

  Future<void> fetchAdvertiserProfile() async {
    isLoading = true;
    update();

    try {
      print("🌐 Fetching advertiser profile...");

      final response = await ApiService.get(ApiEndPoint.advertiserProfile);

      print("📦 Response Status: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final advertiserData = response.data['data'] ?? {};


        debugPrint(" Advertiser Response Data Is: ${response.data}");

        // ========== UPDATE TEXT CONTROLLERS ==========
        businessNameController.text = advertiserData["businessName"] ?? '';
        businessLicenceController.text = advertiserData["licenseNumber"] ?? '';
        businessTypeController.text = advertiserData["businessType"] ?? '';
        phoneNumberController.text = advertiserData["phone"] ?? '';
        bioController.text = advertiserData["bio"] ?? '';

        // ========== SAVE TO LOCAL STORAGE ==========
        await _saveToLocalStorage(advertiserData);

        print("✅ Profile data loaded and saved successfully");
      } else {
        print("❌ Failed to fetch profile: ${response.message}");
        _loadFromLocalStorage();
      }
    } catch (e) {
      print("❌ Fetch Profile Error: $e");
      // Utils.errorSnackBar("Error", "Failed to load profile data");
      // Load from local storage as fallback
      _loadFromLocalStorage();
    } finally {
      isLoading = false;
      update();
    }
  }

  // ================= SAVE TO LOCAL STORAGE =================
  Future<void> _saveToLocalStorage(Map<String, dynamic> advertiserData) async {
    try {
      // Update LocalStorage variables
      LocalStorage.userId = advertiserData["_id"] ?? LocalStorage.userId;
      LocalStorage.businessName = advertiserData["businessName"] ?? '';
      LocalStorage.businessType = advertiserData["businessType"] ?? '';
      LocalStorage.businessLicenceNumber = advertiserData["licenseNumber"] ?? '';
      LocalStorage.phone = advertiserData["phone"] ?? '';
      LocalStorage.advertiserBio = advertiserData["bio"] ?? '';
      LocalStorage.businessLogo = advertiserData["logo"] ?? '';

      // Save to SharedPreferences
      await Future.wait([
        LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId),
        LocalStorage.setString(LocalStorageKeys.businessName, LocalStorage.businessName),
        LocalStorage.setString(LocalStorageKeys.businessType, LocalStorage.businessType),
        LocalStorage.setString(LocalStorageKeys.businessLicenceNumber, LocalStorage.businessLicenceNumber),
        LocalStorage.setString(LocalStorageKeys.phone, LocalStorage.phone),
        LocalStorage.setString(LocalStorageKeys.advertiserBio, LocalStorage.advertiserBio),
        LocalStorage.setString(LocalStorageKeys.businessLogo, LocalStorage.businessLogo),
      ]);

      print("✅ Data saved to local storage");
    } catch (e) {
      print("❌ Error saving to local storage: $e");
    }
  }

  // ================= LOAD FROM LOCAL STORAGE (FALLBACK) =================
  void _loadFromLocalStorage() {
    businessNameController.text = LocalStorage.businessName;
    businessLicenceController.text = LocalStorage.businessLicenceNumber;
    businessTypeController.text = LocalStorage.businessType;
    phoneNumberController.text = LocalStorage.phone;
    bioController.text = LocalStorage.advertiserBio;

    print("📂 Loaded data from local storage");
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final bool permissionGranted = await _requestImagePermission(source);
      if (!permissionGranted) {
        Get.snackbar(
          'Permission Required',
          'Please allow ${source == ImageSource.camera ? 'camera' : 'storage'} access',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
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
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
      print("📤 Updating advertiser profile...");

      final Map<String, String> body = {
        "businessName": businessNameController.text.trim(),
        "businessType": businessTypeController.text.trim(),
        "licenseNumber": businessLicenceController.text.trim(),
        "phone": phoneNumberController.text.trim(),
        "bio": bioController.text.trim(),
      };

      print("📦 Update Body: $body");
      print("🖼️ Image Path: ${selectedImage?.path}");

      final response = await ApiService.multipartUpdate(
        ApiEndPoint.advertiserUpdate,
        body: body,
        imagePath: selectedImage?.path,
      );

      print("📦📦📦📦📦📦📦 Response Status: ${response.statusCode}");
      print("📦📦📦📦📦📦📦 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final advertiserData = response.data['data'] ?? {};

        // ========== SAVE TO LOCAL STORAGE ==========

        await _saveToLocalStorage(advertiserData);

        // If image was uploaded, save the local path too
        if (selectedImage?.path != null) {
          LocalStorage.myImage = selectedImage!.path;
          await LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
        }

        Utils.successSnackBar(
          "Success",
          response.data['message'] ?? "Profile Updated Successfully",
        );

        print("✅ Profile updated successfully");

        Get.to(const DashBoardProfile());
      } else {
        Utils.errorSnackBar(
          response.statusCode.toString(),
          response.data['message'] ?? "Failed to update profile",
        );
      }
    } catch (e) {
      print("❌ Update Profile Error: $e");
      Utils.errorSnackBar("Error", "Failed to update profile: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  // ================= LIFE CYCLE =================
  // @override
  // void onClose() {
  //   businessNameController.dispose();
  //   bioController.dispose();
  //   phoneNumberController.dispose();
  //   businessLicenceController.dispose();
  //   businessTypeController.dispose();
  //   super.onClose();
  // }
}