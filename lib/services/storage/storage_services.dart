import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/route/app_routes.dart';
import '../../features/profile/data/model/user_profile_model.dart';
import '../../utils/log/app_log.dart';
import 'storage_keys.dart';

class LocalStorage {
  static String token = "";
  static String businessLicenceNumber = "";
  static String forgotPasswordToken = "";

  static String userId = "";

  static UserModel? _user;

  static UserModel get user => _user ?? UserModel.fromJson({});

  static bool get isUser => user.role.toLowerCase() == 'user';

  static set setUser(UserModel user) => _user = user;

  static SharedPreferences? preferences;

  static bool get isLogIn => token.isNotEmpty;

  static Future<SharedPreferences> _getStorage() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  static Future<void> getAllPrefData() async {
    final localStorage = await _getStorage();

    userId = localStorage.getString(LocalStorageKeys.userId) ?? "";
    token = localStorage.getString(LocalStorageKeys.token) ?? "";
    appLog(token, source: "Local Storage Data Loaded");
  }

  static Future<void> setString(String key, String value) async {
    final localStorage = await _getStorage();
    await localStorage.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    final localStorage = await _getStorage();
    await localStorage.setBool(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    final localStorage = await _getStorage();
    await localStorage.setDouble(key, value);
  }

  /// ----------------------------------------------------------
  /// LOGOUT & RESET
  /// ----------------------------------------------------------
  static Future<void> removeAllPrefData() async {
    final localStorage = await _getStorage();
    await localStorage.clear();
    Get.offAllNamed(AppRoutes.signIn);
  }
}
