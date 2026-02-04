import 'dart:convert';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api/api_end_point.dart';
import '../../config/route/app_routes.dart';
import '../../utils/log/app_log.dart';
import '../api/api_service.dart';
import 'storage_keys.dart';
import 'dart:io';

class LocalStorage {
  static String token = "";
  static String forgotPasswordToken = "";
  static bool isLogIn = false;
  static String userId = "";
  static String myImage = "";
  static String myName = "";
  static String myEmail = "";
  static String myRole = "";
  static String activeRole = "";
  static String mobile = "";
  static String dateOfBirth = "";
  static String gender = "";
  static String experience = "";
  static double balance = 0.0;
  static bool verified = false;
  static String bio = "";
  static double lat = 0.0;
  static double log = 0.0;
  static bool accountInfoStatus = false;
  static String createdAt = "";
  static String updatedAt = "";

  static SharedPreferences? preferences;

  /// Get SharedPreferences Instance
  static Future<SharedPreferences> _getStorage() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  static Future<void> printAllCookiesFromDisk() async {
    final dir = await getApplicationDocumentsDirectory();
    final cookieDir = Directory("${dir.path}/.cookies/");

    await for (final entity in cookieDir.list(recursive: true)) {
      if (entity is File) {
        final content = await entity.readAsString();

        final accessToken = extractAccessToken(content);

        if (accessToken != null) {
          print('🔥 Access Token Found: $accessToken');

          /// 👉 store it somewhere
          token = accessToken;
          break; // token পেয়ে গেলে stop
        }
      }
    }
  }

  static String? extractAccessToken(String cookieFileContent) {
    try {
      final Map<String, dynamic> json = jsonDecode(cookieFileContent);

      final raw = json['/']?['accessToken'] as String?;
      if (raw == null) return null;

      // accessToken=XXXX; Path=/; HttpOnly...
      final tokenPart = raw.split(';').first; // accessToken=XXXX
      final token = tokenPart.split('=').last;

      return token;
    } catch (e) {
      print('❌ Failed to extract accessToken: $e');
      return null;
    }
  }

  /// Get All Data From SharedPreferences
  static Future<void> getAllPrefData() async {
    final localStorage = await _getStorage();
    final cookies = await cookieJarInit();
    print(cookies.toString);
    await printAllCookiesFromDisk();

    isLogIn = localStorage.getBool(LocalStorageKeys.isLogIn) ?? false;
    userId = localStorage.getString(LocalStorageKeys.userId) ?? "";
    myImage = localStorage.getString(LocalStorageKeys.myImage) ?? "";
    myName = localStorage.getString(LocalStorageKeys.myName) ?? "";
    myEmail = localStorage.getString(LocalStorageKeys.myEmail) ?? "";
    myRole = localStorage.getString(LocalStorageKeys.myRole) ?? "";
    activeRole =
        localStorage.getString(LocalStorageKeys.activeRole) ??
        ""; // Read activeRole
    mobile = localStorage.getString(LocalStorageKeys.mobile) ?? "";
    dateOfBirth = localStorage.getString(LocalStorageKeys.dateOfBirth) ?? "";
    gender = localStorage.getString(LocalStorageKeys.gender) ?? "";
    experience = localStorage.getString(LocalStorageKeys.experience) ?? "";
    balance = localStorage.getDouble(LocalStorageKeys.balance) ?? 0.0;
    verified = localStorage.getBool(LocalStorageKeys.verified) ?? false;
    bio = localStorage.getString(LocalStorageKeys.bio) ?? "";
    lat = localStorage.getDouble(LocalStorageKeys.lat) ?? 0.0;
    log = localStorage.getDouble(LocalStorageKeys.log) ?? 0.0;
    accountInfoStatus =
        localStorage.getBool(LocalStorageKeys.accountInfoStatus) ?? false;
    createdAt = localStorage.getString(LocalStorageKeys.createdAt) ?? "";
    updatedAt = localStorage.getString(LocalStorageKeys.updatedAt) ?? "";
    appLog(token, source: "Local Storage");
  }

  /// Remove All Data From SharedPreferences
  static Future<void> removeAllPrefData() async {
    final localStorage = await _getStorage();
    await localStorage.clear();
    await cookieJar.deleteAll();

    _resetLocalStorageData();
    Get.offAllNamed(AppRoutes.signIn);
    await getAllPrefData();
  }

  // Reset LocalStorage Data
  static void _resetLocalStorageData() {
    final localStorage = preferences!;
    localStorage.setString(LocalStorageKeys.token, "");
    localStorage.setString(LocalStorageKeys.refreshToken, "");
    localStorage.setString(LocalStorageKeys.userId, "");
    localStorage.setString(LocalStorageKeys.myImage, "");
    localStorage.setString(LocalStorageKeys.myName, "");
    localStorage.setString(LocalStorageKeys.myEmail, "");
    localStorage.setString(LocalStorageKeys.myRole, "");
    localStorage.setString(LocalStorageKeys.activeRole, ""); // Reset activeRole
    localStorage.setString(LocalStorageKeys.mobile, "");
    localStorage.setString(LocalStorageKeys.dateOfBirth, "");
    localStorage.setString(LocalStorageKeys.gender, "");
    localStorage.setString(LocalStorageKeys.experience, "");
    localStorage.setDouble(LocalStorageKeys.balance, 0.0);
    localStorage.setBool(LocalStorageKeys.verified, false);
    localStorage.setString(LocalStorageKeys.bio, "");
    localStorage.setDouble(LocalStorageKeys.lat, 0.0);
    localStorage.setDouble(LocalStorageKeys.log, 0.0);
    localStorage.setBool(LocalStorageKeys.accountInfoStatus, false);
    localStorage.setString(LocalStorageKeys.createdAt, "");
    localStorage.setString(LocalStorageKeys.updatedAt, "");
    localStorage.setBool(LocalStorageKeys.isLogIn, false);
  }

  // Save Data To SharedPreferences

  static Future<void> setRole(String key, String value) async {
    myRole = value;
    final localStorage = await _getStorage();
    await localStorage.setString(key, value);
  }

  static Future<void> setString(String key, String value) async {
    if (key == LocalStorageKeys.myRole) return;
    final localStorage = await _getStorage();
    await localStorage.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    final localStorage = await _getStorage();
    await localStorage.setBool(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    final localStorage = await _getStorage();
    await localStorage.setInt(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    final localStorage = await _getStorage();
    await localStorage.setDouble(key, value);
  }
}
