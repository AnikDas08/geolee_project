import 'dart:convert';

import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/profile/data/model/user_profile_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';

class MyProfileController extends GetxController {
  bool isLoading = false;
  UserProfileModel? profileModel;

  /// User profile data
  String get userName =>
      LocalStorage.myName.isNotEmpty ? LocalStorage.myName : "Shakir Ahmed";

  String get userImage => LocalStorage.myImage;

  String get userEmail => LocalStorage.myEmail.isNotEmpty
      ? LocalStorage.myEmail
      : "Example@gmail.com";

  String get mobile => LocalStorage.mobile;
  String get dateOfBirth {
    if (LocalStorage.dateOfBirth.isEmpty) return "";
    // Extract only the date part (YYYY-MM-DD) from ISO timestamp
    return LocalStorage.dateOfBirth.split('T').first;
  }

  String get gender => LocalStorage.gender;
  String get experience => LocalStorage.experience;
  String get bio => LocalStorage.bio.isEmpty?LocalStorage.bio:"Bio Not Set Yet";
  double get balance => LocalStorage.balance;
  bool get verified => LocalStorage.verified;
  double get lat => LocalStorage.lat;
  double get log => LocalStorage.log;
  bool get accountInfoStatus => LocalStorage.accountInfoStatus;
  String get address => "Dhaka, Bangladesh";
   String get about => LocalStorage.bio.isNotEmpty ? LocalStorage.bio : "Bio Not Set yet";

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }

  /// Navigate to edit profile screen
  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  Future<void> getUserData() async {
    isLoading = true;
    update();

    try {
      var response = await ApiService.get(
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
        ApiEndPoint.profile,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        profileModel = UserProfileModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (profileModel?.data != null) {


          final data = profileModel!.data!;
          LocalStorage.userId = data.sId ?? "";
          LocalStorage.myName = data.name ?? "";
          LocalStorage.myEmail = data.email ?? "";
          LocalStorage.myRole = data.role ?? "";
          LocalStorage.myImage = data.image ?? "";
          LocalStorage.bio = data.bio ?? "Bio Yet Not Set";
          LocalStorage.gender = data.gender ?? "Not Selected";
          LocalStorage.dateOfBirth = data.dob ?? "Not Selected";
          LocalStorage.createdAt = data.createdAt ?? "";
          LocalStorage.updatedAt = data.updatedAt ?? "";
          LocalStorage.verified = data.isVerified ?? false;


          await LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
          await LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName);
          await LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail);
          await LocalStorage.setString(LocalStorageKeys.myRole, LocalStorage.myRole);
          await LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
          await LocalStorage.setBool(LocalStorageKeys.verified, LocalStorage.verified);



          // Save to SharedPreferences
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
      } else {
        Get.snackbar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    }

    isLoading = false;
    update();
  }

  /// Navigate back
  void goBack() {
    Get.back();
  }
}
