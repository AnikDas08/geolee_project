import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/features/profile/data/model/user_profile_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:intl/intl.dart';

class MyProfileController extends GetxController {
  bool isLoading = false;
  bool isLocationVisible = true; // Added state
  UserProfileModel? profileModel;

  String _dateOfBirth = "";
  String _gender = "";
  // ================= USER DATA GETTERS =================

  String get userName =>
      LocalStorage.myName.isNotEmpty ? LocalStorage.myName : "User Name";

  String get userImage => LocalStorage.myImage;

  String get userEmail => LocalStorage.myEmail.isNotEmpty
      ? LocalStorage.myEmail
      : "example@mail.com";

  String get mobile => LocalStorage.mobile;

  String get dateOfBirth {
    if (LocalStorage.dateOfBirth.isEmpty) return "Not Selected";
    try {
      final utcDate = DateTime.parse(LocalStorage.dateOfBirth);
      final localDate = utcDate.toLocal(); // UTC → User এর local time এ convert
      return DateFormat('yyyy-MM-dd').format(localDate);
    } catch (e) {
      return LocalStorage.dateOfBirth.split('T').first;
    }
  }

  String get gender =>
      LocalStorage.gender.isNotEmpty ? LocalStorage.gender : "Not Selected";

  String get experience => LocalStorage.experience;

  String get bio =>
      LocalStorage.bio.isNotEmpty ? LocalStorage.bio : "Bio Not Set Yet";

  double get balance => LocalStorage.balance;

  bool get verified => LocalStorage.verified;

  double get lat => LocalStorage.lat;

  double get log => LocalStorage.long;

  bool get accountInfoStatus => LocalStorage.accountInfoStatus;

  String get address => "Dhaka, Bangladesh";

  String get about => bio;

  // ================= LIFE CYCLE =================

  @override
  void onInit() {
    super.onInit();
    // Initialize from local storage first for better UX
    isLocationVisible = LocalStorage.isLocationVisible;
    getUserData();
  }

  // ================= NAVIGATION =================

  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void goBack() {
    Get.back();
  }

  // ================= API CALL =================


  Future<void> getUserData() async {
    if(LocalStorage.token.isEmpty){
      return;
    }
    isLoading = true;
    update();

    try {
      final response = await ApiService.get(
        ApiEndPoint.profile,

      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        profileModel = UserProfileModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        final data = profileModel?.data;
        if (data == null) return;

        // ---------- SAFE DATE HANDLING ----------
        _dateOfBirth = data.dob.toIso8601String();

        _gender = data.gender;

        // ---------- LOCAL MEMORY ----------
        LocalStorage.userId = data.id;
        LocalStorage.myName = data.name;
        LocalStorage.myEmail = data.email;
        LocalStorage.role = data.role;
        LocalStorage.myImage = data.image;
        LocalStorage.bio = data.bio.isNotEmpty ? data.bio : "Bio Not Set Yet";
        LocalStorage.gender = data.gender;
        LocalStorage.dateOfBirth = _dateOfBirth;
        LocalStorage.createdAt = data.createdAt.toIso8601String() ?? "";
        LocalStorage.updatedAt = data.updatedAt.toIso8601String() ?? "";
        LocalStorage.verified = data.isVerified;

        // Update local visibility state from API if available
        // Note: The model doesn't have isLocationVisible yet based on your JSON, 
        // but we'll use LocalStorage as source of truth for now or assume it's true.
        // If the backend adds it, we can map it here.

        // ---------- SAVE TO SHARED PREF ----------
        await Future.wait([
          LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn),
          LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId),
          LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName),
          LocalStorage.setString(
            LocalStorageKeys.myEmail,
            LocalStorage.myEmail,
          ),
          LocalStorage.setString(LocalStorageKeys.myRole, LocalStorage.myRole),
          LocalStorage.setString(
            LocalStorageKeys.myImage,
            LocalStorage.myImage,
          ),
          LocalStorage.setString(LocalStorageKeys.bio, LocalStorage.bio),
          LocalStorage.setString(LocalStorageKeys.gender, LocalStorage.gender),
          LocalStorage.setString(
            LocalStorageKeys.dateOfBirth,
            LocalStorage.dateOfBirth,
          ),
          LocalStorage.setString(
            LocalStorageKeys.experience,
            LocalStorage.experience,
          ),
          LocalStorage.setDouble(
            LocalStorageKeys.balance,
            LocalStorage.balance,
          ),
          LocalStorage.setBool(
            LocalStorageKeys.verified,
            LocalStorage.verified,
          ),
          LocalStorage.setDouble(LocalStorageKeys.lat, LocalStorage.lat),
          LocalStorage.setDouble(LocalStorageKeys.long, LocalStorage.long),
          LocalStorage.setBool(
            LocalStorageKeys.accountInfoStatus,
            LocalStorage.accountInfoStatus,
          ),
          LocalStorage.setString(
            LocalStorageKeys.createdAt,
            LocalStorage.createdAt,
          ),
          LocalStorage.setString(
            LocalStorageKeys.updatedAt,
            LocalStorage.updatedAt,
          ),
        ]);

      }
    } catch (e) {
      debugPrint("Failed To Load Profile: ${e.toString()}");
    }

    isLoading = false;
    update();
  }

  // ================= TOGGLE PRIVACY =================
  Future<void> toggleLocationVisibility(bool value) async {
    isLocationVisible = value;
    update();

    try {
      final response = await ApiService.patch(
        ApiEndPoint.updateProfile,
        body: {"isLocationVisible": value},
      );

      if (response.statusCode == 200) {
        await LocalStorage.setBool(LocalStorageKeys.isLocationVisible, value);
        debugPrint("Privacy mode updated: $value");
      } else {
        // Rollback on failure
        isLocationVisible = !value;
        update();
        debugPrint("Failed to update privacy mode");
      }
    } catch (e) {
      isLocationVisible = !value;
      update();
      debugPrint("Error updating privacy mode: $e");
    }
  }



}
