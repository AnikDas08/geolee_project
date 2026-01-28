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

class ProfileController extends GetxController {
  /// Language List here
  List languages = ["English", "French", "Arabic"];

  /// form key here
  final formKey = GlobalKey<FormState>();

  /// select Language here
  String selectedLanguage = "English";

  /// select image here
  String? image;

  /// edit button loading here
  bool isLoading = false;

  UserProfileModel? profileModel;

  /// Image picker instance
  final ImagePicker _picker = ImagePicker();

  /// all controller here
  TextEditingController nameController = TextEditingController()
    ..text = LocalStorage.myName;
  TextEditingController numberController = TextEditingController()
    ..text = LocalStorage.mobile;
  TextEditingController passwordController = TextEditingController();
  TextEditingController aboutController = TextEditingController()
    ..text = LocalStorage.bio;
  TextEditingController dateOfBirthController = TextEditingController()
    ..text = LocalStorage.dateOfBirth.split('T').first;
  TextEditingController genderController = TextEditingController()
    ..text = LocalStorage.gender;
  TextEditingController addressController = TextEditingController();

  /// Request permission based on platform and Android version
  Future<bool> _requestImagePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      // For gallery/photos
      if (Platform.isAndroid) {
        // Check Android version
        final androidInfo = await Permission.storage.status;

        // Android 13+ uses Permission.photos
        if (await Permission.photos.status.isDenied) {
          final status = await Permission.photos.request();
          if (status.isGranted) return true;
        }

        // Android 12 and below uses Permission.storage
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return false;
    }
  }

  /// Select image from gallery or camera
  /// Select image from gallery or camera
  Future<void> getProfileImage() async {
    try {
      print('=== Starting getProfileImage ===');

      // Show bottom sheet to choose source
      final ImageSource? source = await Get.bottomSheet<ImageSource>(
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
        isDismissible: true,
      );

      print('Selected source: $source');
      if (source == null) {
        print('No source selected');
        return;
      }

      // Request permissions
      bool permissionGranted = false;

      if (source == ImageSource.camera) {
        print('Requesting camera permission');
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
        }
        permissionGranted = status.isGranted;
      } else {
        print('Requesting storage/photos permission');

        // Try photos permission first (Android 13+)
        var photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
        }

        if (photosStatus.isGranted) {
          permissionGranted = true;
        } else {
          // Fallback to storage permission (Android 12 and below)
          var storageStatus = await Permission.storage.status;
          if (!storageStatus.isGranted) {
            storageStatus = await Permission.storage.request();
          }
          permissionGranted = storageStatus.isGranted;
        }
      }

      print('Permission granted: $permissionGranted');

      if (!permissionGranted) {
        print('Permission denied');
        Get.snackbar(
          'Permission Required',
          'Please allow ${source == ImageSource.camera ? 'camera' : 'storage'} access to continue',
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

      print('Opening image picker...');

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      print('Image picker result: ${pickedFile?.path}');

      if (pickedFile != null && pickedFile.path.isNotEmpty) {
        image = pickedFile.path;
        print('✅ Image selected successfully: $image');
        update();

        Get.snackbar(
          'Success',
          'Image selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print('❌ No image selected');
      }
    } catch (e, stackTrace) {
      print('=== ERROR ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');
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

  /// select language  function here
  selectLanguage(int index) {
    selectedLanguage = languages[index];
    update();
    Get.back();
  }

  Future<void> pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // API format
      dateOfBirthController.text =
      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      update();
    }
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// select gender function here
  void selectGender(String gender) {
    genderController.text = gender;
    update();
  }

  /// select address function here
  Future<void> selectAddress() async {
    // This would typically open a location picker
    // For now, we'll just allow manual input
  }

  /// update profile function here
  Future<void> editProfileRepo() async {
    // Get.toNamed(AppRoutes.homeNav);
    // return;
    if (!formKey.currentState!.validate()) return;

    if (!LocalStorage.isLogIn) return;
    isLoading = true;
    update();

    Map<String, String> body = {
      "name": nameController.text,
      "phone": numberController.text,
      "bio": aboutController.text,
      "birthDate": dateOfBirthController.text,
      "gender": genderController.text,
      "lat": "23.8103",
      "log": "90.4125",
    };

    var response =
    await ApiService.patch(ApiEndPoint.updateProfile, body: body);

    if (response.statusCode == 200) {
      var data = response.data;

      LocalStorage.userId = data['data']?["_id"] ?? "";
      LocalStorage.myName = data['data']?["name"] ?? "";
      LocalStorage.myEmail = data['data']?["email"] ?? "";
      LocalStorage.dateOfBirth = data['data']?['dob'] ?? "Not Selected";
      LocalStorage.bio = data['data']?['bio'] ?? "Not Selected";
      LocalStorage.gender = data['data']?['gender'] ?? "Not Selected";

      LocalStorage.setString("userId", LocalStorage.userId);
      LocalStorage.setString("myImage", LocalStorage.myImage);
      LocalStorage.setString("myName", LocalStorage.myName);
      LocalStorage.setString("myEmail", LocalStorage.myEmail);
      LocalStorage.setString(LocalStorageKeys.bio, LocalStorage.bio);
      LocalStorage.setString(
          LocalStorageKeys.dateOfBirth, LocalStorage.dateOfBirth);
      LocalStorage.setString(LocalStorageKeys.gender, LocalStorage.gender);

      Utils.successSnackBar("Successfully Profile Updated", response.message);
      Get.toNamed(AppRoutes.profile);
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
    }

    isLoading = false;
    update();
  }

  /// delete account function here
  Future<void> deleteAccountRepo() async {
    if (!formKey.currentState!.validate()) return;

    if (!LocalStorage.isLogIn) return;
    isLoading = true;
    update();

    Map<String, String> body = {"password": passwordController.text};

    var response = await ApiService.post(ApiEndPoint.user, body: body);

    if (response.statusCode == 200) {
      profileModel = UserProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (profileModel?.data != null) {
        final data = profileModel!.data!;

        LocalStorage.userId = data.sId ?? "";
        LocalStorage.myImage = data.image ?? "";
        LocalStorage.myName = data.name ?? "";
        LocalStorage.myEmail = data.email ?? "";
        LocalStorage.myRole = data.role ?? "";
        LocalStorage.dateOfBirth = data.dob ?? "";
        LocalStorage.gender = data.gender ?? "";
        LocalStorage.bio = data.bio ?? "";

        LocalStorage.createdAt = data.createdAt ?? "";
        LocalStorage.updatedAt = data.updatedAt ?? "";

        await LocalStorage.setBool(
          LocalStorageKeys.isLogIn,
          LocalStorage.isLogIn,
        );
        await LocalStorage.setString(
          LocalStorageKeys.userId,
          LocalStorage.userId,
        );
        await LocalStorage.setString(
          LocalStorageKeys.myImage,
          LocalStorage.myImage,
        );
        await LocalStorage.setString(
          LocalStorageKeys.myName,
          LocalStorage.myName,
        );
        await LocalStorage.setString(
          LocalStorageKeys.myEmail,
          LocalStorage.myEmail,
        );
        await LocalStorage.setString(
          LocalStorageKeys.myRole,
          LocalStorage.myRole,
        );
        await LocalStorage.setString(
          LocalStorageKeys.dateOfBirth,
          LocalStorage.dateOfBirth,
        );
        await LocalStorage.setString(
          LocalStorageKeys.gender,
          LocalStorage.gender,
        );
        await LocalStorage.setString(
          LocalStorageKeys.experience,
          LocalStorage.experience,
        );
        await LocalStorage.setDouble(
          LocalStorageKeys.balance,
          LocalStorage.balance,
        );
        await LocalStorage.setBool(
          LocalStorageKeys.verified,
          LocalStorage.verified,
        );
        await LocalStorage.setString(LocalStorageKeys.bio, LocalStorage.bio);
        await LocalStorage.setDouble(LocalStorageKeys.lat, LocalStorage.lat);
        await LocalStorage.setDouble(LocalStorageKeys.log, LocalStorage.log);
        await LocalStorage.setBool(
          LocalStorageKeys.accountInfoStatus,
          LocalStorage.accountInfoStatus,
        );
        await LocalStorage.setString(
          LocalStorageKeys.createdAt,
          LocalStorage.createdAt,
        );
        await LocalStorage.setString(
          LocalStorageKeys.updatedAt,
          LocalStorage.updatedAt,
        );
      }
      Utils.successSnackBar("Successfully Account Deleted", response.message);
      Get.back();
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
    }

    isLoading = false;
    update();
  }
}