import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/route/app_routes.dart';
import '../../utils/log/app_log.dart';
import '../api/api_service.dart';
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
  static String role = "";   // General role
  static String activeRole = "";
  static String mobile = "";
  static String dateOfBirth = "";
  static String gender = "";
  static String experience = "";
  static double balance = 0.0;
  static bool verified = false;
  static String bio = "";
  static String advertiserBio = '';
  // Default coordinates: lat (23.8103), long (90.4125)
  static double lat = 23.8103;
  static double long = 90.4125;
  static String radius = "5";
  static bool accountInfoStatus = false;
  static String createdAt = "";
  static String updatedAt = "";

  static SharedPreferences? preferences;

  static Future<SharedPreferences> _getStorage() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  // Safe reader for numeric values stored in SharedPreferences.
  // SharedPreferences.getDouble will throw if the stored value is a String,
  // so this helper accepts double/int/String and parses accordingly.
  static double _getDoubleSafe(SharedPreferences prefs, String key, double defaultValue) {
    try {
      final dynamic raw = prefs.get(key);
      if (raw == null) return defaultValue;
      if (raw is double) return raw;
      if (raw is int) return raw.toDouble();
      if (raw is String) {
        // Try parsing with dot or comma
        var parsed = double.tryParse(raw);
        if (parsed != null) return parsed;
        parsed = double.tryParse(raw.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
    } catch (e) {
      debugPrint('LocalStorage._getDoubleSafe error for $key: $e');
    }
    return defaultValue;
  }

  /// ----------------------------------------------------------
  /// COOKIE HANDLING (Token Extraction)
  /// ----------------------------------------------------------
  static Future<void> printAllCookiesFromDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cookieDir = Directory("${dir.path}/.cookies/");
      if (!await cookieDir.exists()) return;

      await for (final entity in cookieDir.list(recursive: true)) {
        if (entity is File) {
          final content = await entity.readAsString();
          final accessToken = extractAccessToken(content);
          if (accessToken != null) {
            token = accessToken;
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("printAllCookiesFromDisk Error: $e");
    }
  }

  static String? extractAccessToken(String cookieFileContent) {
    try {
      final Map<String, dynamic> json = jsonDecode(cookieFileContent);
      final raw = json['/']?['accessToken'] as String?;
      if (raw == null) return null;
      final tokenPart = raw.split(';').first;
      return tokenPart.split('=').last;
    } catch (e) {
      return null;
    }
  }

  /// ----------------------------------------------------------
  /// READ DATA
  /// ----------------------------------------------------------
  static Future<void> getAllPrefData() async {
    final localStorage = await _getStorage();
    await printAllCookiesFromDisk();

    isLogIn = localStorage.getBool(LocalStorageKeys.isLogIn) ?? false;
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
    // Use safe reader to avoid exceptions when values were saved as strings
    balance = _getDoubleSafe(localStorage, LocalStorageKeys.balance, 0.0);
    verified = localStorage.getBool(LocalStorageKeys.verified) ?? false;
    bio = localStorage.getString(LocalStorageKeys.bio) ?? "";
    lat = _getDoubleSafe(localStorage, LocalStorageKeys.lat, lat);
    long = _getDoubleSafe(localStorage, LocalStorageKeys.long, long);
    accountInfoStatus = localStorage.getBool(LocalStorageKeys.accountInfoStatus) ?? false;
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

    // Clear Cookies
    try { await cookieJar.deleteAll(); } catch (_) {}

    _resetLocalStorageData();
    Get.offAllNamed(AppRoutes.signIn);
  }

  static void _resetLocalStorageData() {
    // Reset memory variables to prevent data leaks after logout
    token = "";
    role = "";
    myRole = "";
    activeRole = "";
    userId = "";
    isLogIn = false;
    myName = "";
    myEmail = "";
    balance = 0.0;
    // ... reset any others as needed
  }
}