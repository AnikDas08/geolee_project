import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:giolee78/services/auth/auth_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:giolee78/features/auth/sign%20up/presentation/widget/success_profile.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/helpers/other_helper.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/api/user_api_service.dart';
import '../../../../../services/notification/firebase_notification_service.dart';
import '../../../../../utils/app_utils.dart';

class SignUpController extends GetxController {
  bool isPopUpOpen = false;
  bool isLoading = false;
  bool isLoadingVerify = false;
  bool isResendingOtp = false;

  GoogleMapController? mapController;
  Position? currentPosition;
  var markers = <Marker>{};
  var initialCameraPosition = const CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 14.0,
  ).obs;

  Timer? _timer;
  int start = 0;

  String time = "";

  List<dynamic> selectedOption = ["User", "Consultant"];

  String selectRole = "USER";
  String countryCode = "+880";
  String? image;

  String signUpToken = '';

  static SignUpController get instance => Get.find();

  TextEditingController nameController = TextEditingController(
    text: kDebugMode ? "MD IBRAHIM  NAZMUL" : "",
  );
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'password123' : '',
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: kDebugMode ? 'password123' : '',
  );
  TextEditingController numberController = TextEditingController(
    text: kDebugMode ? '1865965581' : '',
  );
  TextEditingController otpController = TextEditingController();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dateOfBirthTEController=TextEditingController();

  String? selectedGender;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      update();
    }
  }

  void onCountryChange(Country value) {
    countryCode = value.dialCode.toString();
  }

  void setSelectedRole(value) {
    selectRole = value;
    update();
  }

  Future<void> openGallery() async {
    image = await OtherHelper.openGallery();
    update();
  }

  //============================================Social Login
  Future<void> signInWithGoogle() async {
    try {
      isLoading = true;
      update();

      final Map<String, dynamic>? authData = await AuthService.signInWithGoogle();

      if (authData != null && authData["userCredential"] != null) {
        final UserCredential userCredential = authData["userCredential"];
        final String idToken = authData["idToken"];
        
        debugPrint("✅ Google Sign-UP Token: $idToken");
        
        debugPrint("✅ Google Sign-UP Successful: ${userCredential.user!.email}");
        Utils.successSnackBar("Success", "Signed Up with ${userCredential.user!.email} Please Login again");

        // Navigate based on your app flow
        Get.offAllNamed(AppRoutes.signIn);
      }
    } catch (e) {
      debugPrint("❌ Google Sign-In Error in Controller: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading = true;
      update();

      final Map<String, dynamic>? authData = await AuthService.signInWithApple();

      if (authData != null && authData["userCredential"] != null) {
        final UserCredential userCredential = authData["userCredential"];
        final String idToken = authData["idToken"];

        debugPrint("✅ Apple Sign-UP Token: $idToken");

        debugPrint("✅ Apple Sign-In Successful: ${userCredential.user!.email}");
        Utils.successSnackBar("Success", "Signed in with ${userCredential.user!.email} Please Login again");
        Get.offAllNamed(AppRoutes.signIn);
      }
    } catch (e) {
      debugPrint("❌ Apple Sign-In Error in Controller: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  //============================================Sign Up


  Future<void> pickDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(

      context: Get.context!,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dateOfBirthTEController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      update();
    }
  }

  Future<void> signUpUser(GlobalKey<FormState> signUpFormKey) async {
    if (!signUpFormKey.currentState!.validate()) return;

    isLoading = true;
    update();

    try {
      final Map<String, String> body = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      debugPrint("📤 Signing up user: ${body['email']}");

      final response = await ApiService.post(ApiEndPoint.signUp, body: body);

      debugPrint("📦 Sign Up Response: ${response.statusCode}");
      debugPrint("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        startTimer();
        Get.toNamed(AppRoutes.verifyUser);
      } else if (response.statusCode == 400) {
        Utils.errorSnackBar(
          "Invalid Data",
          "Please check your information and try again",
        );
      } else if (response.statusCode == 401) {
        Utils.errorSnackBar(
          "Unauthorized",
          "You are not allowed to perform this action",
        );
      } else if (response.statusCode == 409) {
        Utils.errorSnackBar(
          "Account Exists",
          "This email is already registered",
        );
      } else if (response.statusCode >= 500) {
        Utils.errorSnackBar(
          "Server Error",
          "Something went wrong. Please try later",
        );
      } else {
        Utils.errorSnackBar("Sign Up Failed", response.message);
      }
    } catch (e) {
      debugPrint("Sign Up Error: $e");
      Utils.errorSnackBar(
        "Connection Error",
        "Unable to connect. Check your internet connection",
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  ///===========================================================================verify OTP

  Future<void> verifyOtpRepo() async {
    isLoadingVerify = true;
    update();

    try {
      debugPrint("📤 Verifying OTP for: ${emailController.text}");

      final Map<String, dynamic> body = {
        "email": emailController.text.trim(),
        "oneTimeCode": int.parse(otpController.text.trim()),
      };

      final Map<String, String> header = {'Content-Type': "application/json"};

      final response = await ApiService.post(
        ApiEndPoint.verifyEmail,
        body: body,
        header: header,
      );

      debugPrint("📦 Verify OTP Response: ${response.statusCode}");
      debugPrint("📦 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          // Stop timer
          _timer?.cancel();

          final dataMap = data['data'];
          final String bearerToken = dataMap['accessToken'];
          final userData = dataMap['user'] ?? dataMap;

          await LocalStorage.saveUserData(
            token: bearerToken,
            userId: userData['_id'] ?? '',
            name: userData['name'],
            email: userData['email'],
          );

          // Sync FCM Token
          try {
            final fcmToken = await FirebaseNotificationService().getFCMToken();
            if (fcmToken != null && LocalStorage.userId.isNotEmpty) {
              await UserApiService.sendTokenToServer(
                userId: LocalStorage.userId,
                token: fcmToken,
              );
              await LocalStorage.setString(LocalStorageKeys.fcmToken, fcmToken);
            }
          } catch (e) {
            debugPrint("Error syncing FCM token after signup: $e");
          }

          // Connect Socket immediately after verification
          SocketServices.connectToSocket();

          Utils.successSnackBar("Success", "Email verified successfully");

          Get.toNamed(AppRoutes.completeProfile);
        } else {
          Utils.errorSnackBar("Error", data['message'] ?? "Unknown error");
        }
      } else {
        Utils.errorSnackBar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      debugPrint("Verify OTP Error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingVerify = false;
      update();
    }
  }

  ///===================================================Resend OTP
  ///
  Future<void> resendOtp() async {
    if (start > 0) {
      Utils.errorSnackBar("Please Wait", "You can resend OTP in $time");
      return;
    }

    isResendingOtp = true;
    update();

    try {
      debugPrint("📤 Resending OTP to: ${emailController.text}");

      final Map<String, String> body = {"email": emailController.text.trim()};

      final response = await ApiService.post(ApiEndPoint.resendOtp, body: body);

      debugPrint("Resend OTP Response: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        otpController.clear();
        startTimer();
        Utils.successSnackBar(
          "OTP Resent",
          "A new OTP has been sent to your email",
        );
      } else {
        Utils.errorSnackBar("Error ", response.message);
      }
    } catch (e) {
      debugPrint("❌ Resend OTP Error: $e");

      try {
        debugPrint("📤 Trying alternative resend method...");

        final Map<String, String> body = {
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        };

        final response = await ApiService.post(ApiEndPoint.signUp, body: body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          otpController.clear();
          startTimer();

          Utils.successSnackBar(
            "OTP Resent",
            "A new OTP has been sent to your email",
          );
        } else {
          Utils.errorSnackBar("Error", response.message);
        }
      } catch (alternativeError) {
        debugPrint("Alternative Resend Error: $alternativeError");
        Utils.errorSnackBar("Error", "Failed to resend OTP");
      }
    } finally {
      isResendingOtp = false;
      update();
    }
  }

  ///========================================== Update Profile and Complete Profile====
  Future<void> updateProfile() async {

    isLoading = true;
    update();

    try {
      final dobText = dateOfBirthTEController.text.trim();
      String? dobIso;
      if (dobText.isNotEmpty) {
        final DateTime dobDate = DateTime.parse(dobText);
        dobIso = dobDate.toUtc().toIso8601String();
      }

      final Map<String, String> body = {
        if (selectedGender != null) "gender": selectedGender!.toLowerCase(),
        if (dobIso != null) "dob": dobIso,
        "address": addressController.text.isNotEmpty
            ? addressController.text
            : " ",
        "bio": bioController.text.trim(),
      };

      ApiResponseModel response;

      if (image != null && image!.isNotEmpty) {
        response = await ApiService.multipart(
          ApiEndPoint.updateProfile,
          body: body,
          imagePath: image!,
          method: "PATCH",
        );
      } else {
        response = await ApiService.patch(
          ApiEndPoint.updateProfile,
          body: body,
        );
      }

      if (response.statusCode == 200) {
        SuccessProfileDialogHere.show(
          Get.context!,
          title: "Your Registration Successfully Complete.",
        );

        // Unfocus keyboard before navigation
        FocusManager.instance.primaryFocus?.unfocus();

        Get.offAllNamed(AppRoutes.signIn);
      } else {
        Utils.errorSnackBar("Error", response.message);
      }
    } catch (e) {
      debugPrint("Update Profile Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void startTimer() {
    _timer?.cancel();
    start = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        final minutes = (start ~/ 60).toString().padLeft(2, '0');
        final seconds = (start % 60).toString().padLeft(2, '0');

        time = "$minutes:$seconds";

        update();
      } else {
        time = "00:00";
        _timer?.cancel();
        update();
      }
    });
  }

  // Location permission
  Future<void> _requestLocationPermission() async {
    try {
      var status = await Permission.location.status;

      if (status.isDenied || status.isRestricted || status.isLimited) {
        status = await Permission.location.request();
      }

      if (status.isGranted || status.isLimited) {
        await getCurrentLocation();
      } else if (status.isDenied) {
        Get.snackbar(
          "Permission Denied",
          "Location permission is needed to show your position",
          backgroundColor: AppColors.red.withValues(alpha: 0.9),
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
          isDismissible: true,
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              _requestLocationPermission();
            },
            child: const Text(
              "Retry",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Permission error: $e");
    }
  }

  // Location methods
  Future<void> getCurrentLocation() async {
    try {
      final permissionStatus = await Permission.location.status;
      if (!permissionStatus.isGranted) {
        await _requestLocationPermission();
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "Location Service",
          "Please enable location services in your device settings",
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
        );
        return;
      }

      Get.snackbar(
        "Getting Location",
        "Please wait...",
        backgroundColor: AppColors.secondary.withValues(alpha: 0.8),
        colorText: AppColors.white,
        duration: const Duration(seconds: 1),
        showProgressIndicator: true,
      );

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentPosition = position;

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );

      Get.snackbar(
        "Location Updated",
        "Moved to your current location",
        backgroundColor: AppColors.secondary,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to get location. Please check your GPS and try again.",
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    debugPrint("✅ Google Map Created Successfully");
  }

  Future<void> confirmLocation() async {
    try {
      debugPrint("🔵 confirmLocation called");

      if (mapController == null) {
        debugPrint("❌ Map controller is null");
        Get.snackbar(
          "Error",
          "Map is not ready. Please try again.",
          backgroundColor: AppColors.red,
          colorText: AppColors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      debugPrint("✅ Map controller exists");

      final LatLng center = await mapController!.getVisibleRegion().then(
        (bounds) => LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        ),
      );

      debugPrint("📍 Center location: ${center.latitude}, ${center.longitude}");

      currentPosition = Position(
        latitude: center.latitude,
        longitude: center.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      String address = "";
      bool geocodingSuccess = false;

      try {
        debugPrint("🔍 Attempting reverse geocoding...");
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          center.latitude,
          center.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks[0];
          debugPrint("📍 Placemark found: ${place.toString()}");

          final List<String> addressParts = [];

          if (place.street != null && place.street!.isNotEmpty) {
            addressParts.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty &&
              place.subAdministrativeArea != place.locality) {
            addressParts.add(place.subAdministrativeArea!);
          }
          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }

          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
            geocodingSuccess = true;
            debugPrint("✅ Reverse geocoding successful: $address");
          } else {
            debugPrint("⚠️ No address components found in placemark");
          }
        } else {
          debugPrint("⚠️ No placemarks returned");
        }
      } catch (e) {
        debugPrint("⚠️ Reverse geocoding failed: $e");
        geocodingSuccess = false;
      }

      if (!geocodingSuccess || address.isEmpty) {
        address =
            "Location: ${center.latitude.toStringAsFixed(4)}°N, ${center.longitude.toStringAsFixed(4)}°E";
        debugPrint("ℹ️ Using fallback address format");

        Get.snackbar(
          "Location Selected",
          "Address details unavailable. Please ensure you have internet connection for full address.",
          backgroundColor: AppColors.secondary,
          colorText: AppColors.white,
        );
      }

      addressController.text = address;
      debugPrint("✅ Address controller updated: ${addressController.text}");

      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: center,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Selected Location', snippet: address),
        ),
      );

      debugPrint("✅ Calling update()");
      update();
      update(['address_field']);

      if (geocodingSuccess) {
        Get.snackbar(
          "Location Confirmed",
          "Your location has been selected successfully",
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.white,
          duration: const Duration(seconds: 2),
        );
      }

      debugPrint("✅ Navigating back");
      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();
    } catch (e) {
      debugPrint("❌ Error in confirmLocation: $e");
      Get.snackbar(
        "Error",
        "Failed to confirm location: $e",
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    // Manual disposal of TextEditingControllers in onClose often causes race conditions
    // with unmounting widgets during navigation transitions. 
    // Letting the GC handle them or ensuring keyboard is unfocused is safer.
    super.onClose();
  }
}
