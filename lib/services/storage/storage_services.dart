import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api/api_end_point.dart';
import '../../config/route/app_routes.dart';
import '../../features/message/presentation/controller/chat_controller.dart';
import '../../utils/log/app_log.dart';
import '../notification/firebase_notification_service.dart';
import 'storage_keys.dart';

class LocalStorage {
  static String token = "";
  static String businessLicenceNumber = "";
  static String forgotPasswordToken = "";
  static bool isLogIn = false;
  static String userId = "";
  static String businessName = "";
  static String businessType = "";
  static String businessLogo = "";
  static String phone = "";
  static String address = "";
  static String myImage = "";
  static String myName = "";
  static String myEmail = "";
  static String myRole = "";
  static String role = "";
  static String activeRole = "";
  static String mobile = "";
  static String dateOfBirth = "";
  static String gender = "";
  static String experience = "";
  static double balance = 0.0;
  static bool verified = false;
  static String bio = "";
  static String advertiserBio = '';
  static double lat = 90.4125;
  static double long = 23.8103;
  static String radius = "5";
  static bool accountInfoStatus = false;
  static String createdAt = "";
  static String updatedAt = "";
  static bool isLocationVisible = false;
  static String fcmToken = '';

  static SharedPreferences? preferences;

  static Future<SharedPreferences> _getStorage() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  static Future<void> getAllPrefData() async {
    final localStorage = await _getStorage();

    isLogIn = localStorage.getBool(LocalStorageKeys.isLogIn) ?? false;
    token = localStorage.getString(LocalStorageKeys.token) ?? "";
    userId = localStorage.getString(LocalStorageKeys.userId) ?? "";
    myImage = localStorage.getString(LocalStorageKeys.myImage) ?? "";
    myName = localStorage.getString(LocalStorageKeys.myName) ?? "";
    myEmail = localStorage.getString(LocalStorageKeys.myEmail) ?? "";
    myRole = localStorage.getString(LocalStorageKeys.myRole) ?? "";
    role = localStorage.getString(LocalStorageKeys.role) ?? "";
    activeRole = localStorage.getString(LocalStorageKeys.activeRole) ?? "";
    mobile = localStorage.getString(LocalStorageKeys.mobile) ?? "";
    dateOfBirth = localStorage.getString(LocalStorageKeys.dateOfBirth) ?? "";
    gender = localStorage.getString(LocalStorageKeys.gender) ?? "";
    experience = localStorage.getString(LocalStorageKeys.experience) ?? "";
    balance = localStorage.getDouble(LocalStorageKeys.balance) ?? 0.0;
    verified = localStorage.getBool(LocalStorageKeys.verified) ?? false;
    bio = localStorage.getString(LocalStorageKeys.bio) ?? "";
    lat = localStorage.getDouble(LocalStorageKeys.lat) ?? 0.0;
    long = localStorage.getDouble(LocalStorageKeys.long) ?? 0.0;
    accountInfoStatus =
        localStorage.getBool(LocalStorageKeys.accountInfoStatus) ?? false;
    createdAt = localStorage.getString(LocalStorageKeys.createdAt) ?? "";
    updatedAt = localStorage.getString(LocalStorageKeys.updatedAt) ?? "";
    isLocationVisible =
        localStorage.getBool(LocalStorageKeys.isLocationVisible) ?? false;
    radius = localStorage.getString(LocalStorageKeys.radius) ?? "5";
    appLog(token, source: "Local Storage Data Loaded");
  }

  static Future<void> setString(String key, String value) async {
    final localStorage = await _getStorage();
    await localStorage.setString(key, value);

    if (key == LocalStorageKeys.role) role = value;
    if (key == LocalStorageKeys.myRole) myRole = value;
    if (key == LocalStorageKeys.activeRole) activeRole = value;
    if (key == LocalStorageKeys.myName) myName = value;
    if (key == LocalStorageKeys.myEmail) myEmail = value;
    if (key == LocalStorageKeys.token) token = value;
    if (key == LocalStorageKeys.radius) radius = value;
  }

  static Future<void> setBool(String key, bool value) async {
    final localStorage = await _getStorage();
    await localStorage.setBool(key, value);
    if (key == LocalStorageKeys.isLogIn) isLogIn = value;
    if (key == LocalStorageKeys.verified) verified = value;
    if (key == LocalStorageKeys.isLocationVisible) isLocationVisible = value;
  }

  static Future<void> setDouble(String key, double value) async {
    final localStorage = await _getStorage();
    await localStorage.setDouble(key, value);
    if (key == LocalStorageKeys.balance) balance = value;
  }

  /// ===========================================
  // LOGOUT & RESET
  ///============================================

  static Future<void> removeAllPrefData() async {
    try {
      final prefs = await _getStorage();

      final token = prefs.getString(LocalStorageKeys.fcmToken);
      final userId = prefs.getString(LocalStorageKeys.userId) ?? "";

      // 1. REMOVE TOKEN FROM SERVER

      if (token != null && token.isNotEmpty && userId.isNotEmpty) {
        final response = await ApiService.delete(
          ApiEndPoint.deleteFcmToken,
          body: {"token": token},
        );

        if (response.statusCode == 200) {
          debugPrint("FCM Token deleted successfully");
        } else {
          debugPrint("FCM delete response: ${response.statusCode}");
        }
      }

      await FirebaseMessaging.instance.deleteToken();

      await prefs.clear();

      _resetLocalStorageData();

      // 5. CLEAR CONTROLLERS
      if (Get.isRegistered<ChatController>()) {
        Get.delete<ChatController>(force: true);
      }

      // 6. NAVIGATE
      Get.offAllNamed(AppRoutes.signIn);
    } catch (e) {
      debugPrint("❌ Logout error: $e");
    }
  }

  static void _resetLocalStorageData() {
    token = "";
    role = "";
    myRole = "";
    activeRole = "";
    userId = "";
    isLogIn = false;
    myName = "";
    myEmail = "";
    myImage = "";
    businessLicenceNumber = "";
    forgotPasswordToken = "";
    businessName = "";
    businessType = "";
    businessLogo = "";
    phone = "";
    address = "";
    balance = 0.0;
    verified = false;
    bio = "";
    advertiserBio = '';
    lat = 90.4125;
    long = 23.8103;
    radius = "5";
    accountInfoStatus = false;
    createdAt = "";
    updatedAt = "";
    dateOfBirth = "";
    gender = "";
    experience = "";
    isLocationVisible = false;
  }
}
