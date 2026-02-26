import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/profile/presentation/controller/my_profile_controller.dart';
import 'package:giolee78/utils/app_utils.dart';
import 'package:giolee78/utils/log/app_log.dart';
import 'package:giolee78/utils/log/error_log.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../services/storage/storage_services.dart';
import '../../../../../services/socket/socket_service.dart';
import '../../../../profile/data/model/user_profile_model.dart';

class SignInController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    setInfo();
  }

  /// Sign in Button Loading variable
  bool isLoading = false;

  /// email and password Controller here
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void setInfo() {
    if (!kDebugMode) return;
    emailController.text = 'developernaimul00@gmail.com';
    passwordController.text = 'hello123';
  }

  Future<void> signInUser() async {
    try {
      isLoading = true;
      update();

      final body = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };
      final response = await ApiService.post(ApiEndPoint.signIn, body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'] ?? {};
        final token = data["accessToken"] ?? "";
        final Map<String, dynamic> user = data["user"] ?? {};

        LocalStorage.setUser = UserModel.fromJson(user);
        if (LocalStorage.user.id.isEmpty) {
          MyProfileController.instance.getUserData();
        }
        final userId = LocalStorage.user.id;
        LocalStorage.token = token;
        LocalStorage.userId = userId;
        LocalStorage.setString(LocalStorageKeys.token, token);
        LocalStorage.setString(LocalStorageKeys.userId, userId);
        SocketService.connect();
        Utils.successSnackBar("Welcome Back", "Logged In Successfully");
        Get.toNamed(AppRoutes.homeNav);
        emailController.clear();
        passwordController.clear();
      } else {
        Utils.errorSnackBar('Invalid Credential', "${response.message}");
      }
    } catch (e, s) {
      Utils.errorSnackBar("Error", 'Something went wrong');

      errorLog(s.toString());
    } finally {
      isLoading = false;
      update();
    }
  }
}
