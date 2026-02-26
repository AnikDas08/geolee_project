import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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
import '../../../../../utils/app_utils.dart';

class SignUpController extends GetxController {

  /// Sign Up Form Key
  ///
  bool isPopUpOpen = false;
  bool isLoading = false;
  bool isLoadingVerify = false;
  bool isResendingOtp = false;

  GoogleMapController? mapController;
  Position? currentPosition;
  var markers = <Marker>{};
  var initialCameraPosition = const CameraPosition(
    target: LatLng(23.8103, 90.4125), // Dhaka, Bangladesh default
    zoom: 14.0,
  ).obs;

  Timer? _timer;
  int start = 0;

  String time = "";

  List selectedOption = ["User", "Consultant"];

  String selectRole = "USER";
  String countryCode = "+880";
  String? image;

  String signUpToken = '';

  static SignUpController get instance => Get.put(SignUpController());

  TextEditingController nameController = TextEditingController(
    text: kDebugMode ? "Md Ibrahim Nazmul" : "",
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

  String? selectedGender;
  final List<String> genderOptions = ['male', 'female', 'other'];

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

  ///============================================Sign Up

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

      print("📤 Signing up user: ${body['email']}");

      final response = await ApiService.post(ApiEndPoint.signUp, body: body);

      print("📦 Sign Up Response: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Start OTP timer
        startTimer();

        Utils.successSnackBar("Success", "OTP has been sent to your email");

        Get.toNamed(AppRoutes.verifyUser);
      } else {
        Utils.errorSnackBar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      print("❌ Sign Up Error: $e");
      Utils.errorSnackBar("Error", e.toString());
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

      print("📦 Verify OTP Response: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          // Stop timer
          _timer?.cancel();

          final String bearerToken = data['data']['accessToken'];

          Utils.successSnackBar("Success", "Email verified successfully");

          Get.toNamed(AppRoutes.completeProfile);
        } else {
          Utils.errorSnackBar("Error", data['message'] ?? "Unknown error");
        }
      } else {
        Utils.errorSnackBar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      print("❌ Verify OTP Error: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingVerify = false;
      update();
    }
  }

  ///===================================================Resend OTP
  Future<void> resendOtp() async {
    // Don't allow resend if timer is still running
    if (start > 0) {
      Utils.errorSnackBar("Please Wait", "You can resend OTP in $time");
      return;
    }

    isResendingOtp = true;
    update();

    try {
      print("📤 Resending OTP to: ${emailController.text}");

      final Map<String, String> body = {"email": emailController.text.trim()};

      final response = await ApiService.post(ApiEndPoint.resendOtp, body: body);

      print("📦 Resend OTP Response: ${response.statusCode}");
      print("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear current OTP
        otpController.clear();

        // Restart timer
        startTimer();

        Utils.successSnackBar(
          "OTP Resent",
          "A new OTP has been sent to your email",
        );
      } else {
        Utils.errorSnackBar(
          "Error ${response.statusCode}",
          response.message ?? "Failed to resend OTP",
        );
      }
    } catch (e) {
      print("❌ Resend OTP Error: $e");

      // If resend endpoint doesn't exist, try using signup endpoint
      try {
        print("📤 Trying alternative resend method...");

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
          Utils.errorSnackBar(
            "Error",
            response.message ?? "Failed to resend OTP",
          );
        }
      } catch (alternativeError) {
        print("❌ Alternative Resend Error: $alternativeError");
        Utils.errorSnackBar("Error", "Failed to resend OTP");
      }
    } finally {
      isResendingOtp = false;
      update();
    }
  }

  ///===================================================Update Profile and Complete Profile
  Future<void> updateProfile() async {
    isLoading = true;
    update();

    String formattedDob = "";


    if (image == null || image!.isEmpty) {
      Get.snackbar('Validation Error', 'Please select a profile image');
      return;
    }

    if (bioController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a bio');
      return;
    }

    if (ageController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please select your age');
      return;
    }

    if (selectedGender == null || selectedGender!.isEmpty) {
      Get.snackbar('Validation Error', 'Please select your gender');
      return;
    }



    if (dateController.text.isNotEmpty) {
      try {
        final DateTime parsedDate = DateFormat(
          'dd MMMM yyyy',
        ).parse(dateController.text.trim());
        formattedDob = parsedDate.toUtc().toIso8601String();
      } catch (e) {
        debugPrint("❌ Invalid DOB format: ${dateController.text}");
        formattedDob = "";
      }
    }




    final Map<String, String> body = {
      "gender": selectedGender!.toLowerCase(),
      "dob": formattedDob.isNotEmpty
          ? formattedDob
          : "2000-11-24T12:44:23.000Z",
      'address': addressController.text.isNotEmpty
          ? addressController.text
          : "Dhaka",
      "bio": bioController.text.toString(),
    };

    try {
      ApiResponseModel response;

      if (image != null && image!.isNotEmpty) {
        debugPrint("📸 Uploading profile image: $image");
        response = await ApiService.multipart(
          ApiEndPoint.updateProfile,
          body: body,
          imagePath: image!,
          method: "PATCH",
        );
      } else {
        debugPrint("⚠️ No image selected, updating profile without image");
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

        Get.offAllNamed(AppRoutes.signIn);
      } else {
        Utils.errorSnackBar("Error ${response.statusCode}", response.message);
        debugPrint(
          "error is =>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${response.message}",
        );
      }
    } catch (e) {
      debugPrint("error is =>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${e.toString()}");
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void startTimer() {
    _timer?.cancel();
    start = 180; // 3 minutes
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
          backgroundColor: AppColors.red.withOpacity(0.9),
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
        backgroundColor: AppColors.secondary.withOpacity(0.8),
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
  void dispose() {
    _timer?.cancel();
    // mapController?.dispose();
    super.dispose();
  }
}
