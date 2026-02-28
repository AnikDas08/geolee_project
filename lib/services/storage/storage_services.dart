import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/route/app_routes.dart';
import '../../features/message/presentation/controller/chat_controller.dart';
import '../../utils/log/app_log.dart';
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
  static String myRole = ""; // User's specific role
  static String role = ""; // General role
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

  static SharedPreferences? preferences;

  static Future<SharedPreferences> _getStorage() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  /// ----------------------------------------------------------
  /// COOKIE HANDLING (Token Extraction)
  /// ----------------------------------------------------------

  /// ----------------------------------------------------------
  /// READ DATA
  /// ----------------------------------------------------------
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

    appLog(token, source: "Local Storage Data Loaded");
  }

  /// ----------------------------------------------------------
  /// WRITE DATA (Fixed Role Saving)
  /// ----------------------------------------------------------

  static Future<void> setString(String key, String value) async {
    final localStorage = await _getStorage();
    await localStorage.setString(key, value);

    // Update memory variables immediately
    if (key == LocalStorageKeys.role) role = value;
    if (key == LocalStorageKeys.myRole) myRole = value;
    if (key == LocalStorageKeys.activeRole) activeRole = value;
    if (key == LocalStorageKeys.myName) myName = value;
    if (key == LocalStorageKeys.myEmail) myEmail = value;
    if (key == LocalStorageKeys.token) token = value;
  }

  static Future<void> setBool(String key, bool value) async {
    final localStorage = await _getStorage();
    await localStorage.setBool(key, value);
    if (key == LocalStorageKeys.isLogIn) isLogIn = value;
    if (key == LocalStorageKeys.verified) verified = value;
  }

  static Future<void> setDouble(String key, double value) async {
    final localStorage = await _getStorage();
    await localStorage.setDouble(key, value);
    if (key == LocalStorageKeys.balance) balance = value;
  }

  /// ----------------------------------------------------------
  /// LOGOUT & RESET
  /// ----------------------------------------------------------
  static Future<void> removeAllPrefData() async {
    final localStorage = await _getStorage();
    await localStorage.clear();

    try {
      // ✅ Disk থেকেও cookie folder delete করুন
      final dir = await getApplicationDocumentsDirectory();
      final cookieDir = Directory("${dir.path}/.cookies/");
      if (await cookieDir.exists()) {
        await cookieDir.delete(recursive: true);
        debugPrint("🗑️ Cookie directory deleted from disk");
      }
    } catch (e) {
      debugPrint("❌ Cookie clear error: $e");
    }

    _resetLocalStorageData();
    Get.delete<ChatController>(force: true);
    Get.offAllNamed(AppRoutes.signIn);
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
    balance = 0.0;
  }
}
