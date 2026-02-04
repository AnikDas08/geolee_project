import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class AdvertiserEditProfileController extends GetxController {

  // final MyProfileController _myProfileController=MyProfileController();

  List<String> languages = ["English", "French", "Arabic"];

  final formKey = GlobalKey<FormState>();
  String selectedLanguage = "English";
  File? selectedImage;
  bool isLoading = false;
  UserProfileModel? profileModel;

  final ImagePicker _picker = ImagePicker();

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessLicenceController = TextEditingController();
  TextEditingController businessTypeController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController bioController = TextEditingController();



  Future<bool> _requestImagePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      // For gallery/photos
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
              Text('Choose Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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


  /// Select language
  void selectLanguage(int index) {
    selectedLanguage = languages[index];
    update();
    Get.back();
  }




  Future<void> editProfileRepo() async {
    if (!formKey.currentState!.validate()) return;
    if (!LocalStorage.isLogIn) return;

    isLoading = true;
    update();

    try {

      Map<String, String> body = {
        "name": businessNameController.text.trim(),
        "bio": bioController.text.trim(),

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
        LocalStorage.userId = data['data']?["_id"] ?? LocalStorage.userId;
        LocalStorage.myName = data['data']?["name"] ?? LocalStorage.myName;
        LocalStorage.myEmail = data['data']?["email"] ?? LocalStorage.myEmail;
        LocalStorage.myImage = data['data']?["image"] ?? LocalStorage.myImage;

        await Future.wait([
          LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId),
          LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage),
          LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName),
          LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail),
          LocalStorage.setString(LocalStorageKeys.bio, LocalStorage.bio),
          LocalStorage.setString(LocalStorageKeys.dateOfBirth, LocalStorage.dateOfBirth),
          LocalStorage.setString(LocalStorageKeys.gender, LocalStorage.gender),
        ]);

        // _myProfileController.getUserData();


        Utils.successSnackBar("Success", data['message'] ?? "Profile Updated Successfully");
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

  @override
  void onClose() {
    businessNameController.dispose();
    numberController.dispose();
    passwordController.dispose();
    bioController.dispose();
    super.onClose();
  }

}
