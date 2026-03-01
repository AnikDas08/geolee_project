import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_keys.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../profile/presentation/screen/dashboard_profile.dart';

class AdvertiserEditProfileController extends GetxController {
  // ================= VARIABLES =================
  List<String> languages = ["English", "French", "Arabic"];
  late GlobalKey<FormState> formKey;

  String selectedLanguage = "English";
  File? selectedImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // TextControllers
  late TextEditingController businessNameController;
  late TextEditingController businessLicenceController;
  late TextEditingController businessTypeController;
  late TextEditingController phoneNumberController;
  late TextEditingController bioController;

  String countryCode = "+65";
  String countryIsoCode = "SG";
  String fullPhoneNumber = '';
  String phoneNumberOnly = '';

  Key phoneFieldKey = UniqueKey();

  // ================= ON INIT =================
  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>(); // ✅ Fresh key every time controller is created
    _initializeControllers();
    fetchAdvertiserProfile();
  }

  // ================= INITIALIZE CONTROLLERS =================
  void _initializeControllers() {
    businessNameController = TextEditingController();
    businessLicenceController = TextEditingController();
    businessTypeController = TextEditingController();
    phoneNumberController = TextEditingController();
    bioController = TextEditingController();
  }

  // ================= FETCH ADVERTISER PROFILE =================
  Future<void> fetchAdvertiserProfile() async {
    isLoading = true;
    update();

    try {
      final response = await ApiService.get(ApiEndPoint.advertiserProfile);

      if (response.statusCode == 200) {
        final advertiserData = response.data['data'] ?? {};

        businessNameController.text = advertiserData["businessName"] ?? '';
        businessLicenceController.text = advertiserData["licenseNumber"] ?? '';
        businessTypeController.text = advertiserData["businessType"] ?? '';
        bioController.text = advertiserData["bio"] ?? '';

        final phoneFull = advertiserData["phone"] ?? '';
        _parseAndSetPhone(phoneFull);

        await _saveToLocalStorage(advertiserData);

        debugPrint("✅ Profile data loaded and saved successfully");
      } else {
        debugPrint("❌ Failed to fetch profile: ${response.message}");
        _loadFromLocalStorage();
      }
    } catch (e) {
      debugPrint("❌ Fetch Profile Error: $e");
      _loadFromLocalStorage();
    } finally {
      isLoading = false;
      update();
    }
  }

  void _parseAndSetPhone(String phoneFull) {
    if (phoneFull.isEmpty) {
      countryCode = "+65";
      countryIsoCode = "SG";
      phoneNumberOnly = '';
      fullPhoneNumber = '';
      phoneNumberController.text = '';
      phoneFieldKey = UniqueKey();
      return;
    }

    if (phoneFull.startsWith('+')) {
      final Map<String, String> dialToIso = {
        '+1': 'US',
        '+7': 'RU',
        '+20': 'EG',
        '+27': 'ZA',
        '+30': 'GR',
        '+31': 'NL',
        '+32': 'BE',
        '+33': 'FR',
        '+34': 'ES',
        '+36': 'HU',
        '+39': 'IT',
        '+40': 'RO',
        '+41': 'CH',
        '+43': 'AT',
        '+44': 'GB',
        '+45': 'DK',
        '+46': 'SE',
        '+47': 'NO',
        '+48': 'PL',
        '+49': 'DE',
        '+51': 'PE',
        '+52': 'MX',
        '+53': 'CU',
        '+54': 'AR',
        '+55': 'BR',
        '+56': 'CL',
        '+57': 'CO',
        '+58': 'VE',
        '+60': 'MY',
        '+61': 'AU',
        '+62': 'ID',
        '+63': 'PH',
        '+64': 'NZ',
        '+65': 'SG',
        '+66': 'TH',
        '+81': 'JP',
        '+82': 'KR',
        '+84': 'VN',
        '+86': 'CN',
        '+90': 'TR',
        '+91': 'IN',
        '+92': 'PK',
        '+93': 'AF',
        '+94': 'LK',
        '+95': 'MM',
        '+98': 'IR',
        '+212': 'MA',
        '+213': 'DZ',
        '+216': 'TN',
        '+218': 'LY',
        '+220': 'GM',
        '+221': 'SN',
        '+234': 'NG',
        '+251': 'ET',
        '+254': 'KE',
        '+255': 'TZ',
        '+256': 'UG',
        '+260': 'ZM',
        '+263': 'ZW',
        '+351': 'PT',
        '+352': 'LU',
        '+353': 'IE',
        '+354': 'IS',
        '+355': 'AL',
        '+356': 'MT',
        '+357': 'CY',
        '+358': 'FI',
        '+359': 'BG',
        '+370': 'LT',
        '+371': 'LV',
        '+372': 'EE',
        '+380': 'UA',
        '+381': 'RS',
        '+385': 'HR',
        '+386': 'SI',
        '+420': 'CZ',
        '+421': 'SK',
        '+880': 'BD',
        '+960': 'MV',
        '+966': 'SA',
        '+971': 'AE',
        '+972': 'IL',
        '+973': 'BH',
        '+974': 'QA',
        '+975': 'BT',
        '+976': 'MN',
        '+977': 'NP',
        '+992': 'TJ',
        '+993': 'TM',
        '+994': 'AZ',
        '+995': 'GE',
        '+996': 'KG',
        '+998': 'UZ',
      };

      String? matchedCode;
      String? matchedIso;

      for (int len in [4, 3, 2, 1]) {
        if (phoneFull.length > len) {
          final candidate = phoneFull.substring(0, len + 1);
          if (dialToIso.containsKey(candidate)) {
            matchedCode = candidate;
            matchedIso = dialToIso[candidate];
            break;
          }
        }
      }

      if (matchedCode != null && matchedIso != null) {
        countryCode = matchedCode;
        countryIsoCode = matchedIso;
        phoneNumberOnly = phoneFull.substring(matchedCode.length);
      } else {
        final reg = RegExp(r'^\+(\d{1,4})');
        final match = reg.firstMatch(phoneFull);
        if (match != null) {
          countryCode = '+${match.group(1)}';
          countryIsoCode = "SG";
          phoneNumberOnly = phoneFull.replaceFirst(countryCode, '');
        } else {
          countryCode = "+65";
          countryIsoCode = "SG";
          phoneNumberOnly = phoneFull;
        }
      }
    } else {
      countryCode = "+65";
      countryIsoCode = "SG";
      phoneNumberOnly = phoneFull;
    }

    fullPhoneNumber = phoneFull;
    phoneNumberController.text = phoneNumberOnly;
    phoneFieldKey = UniqueKey();

    debugPrint("Parsed → countryCode: $countryCode | isoCode: $countryIsoCode | number: $phoneNumberOnly");
  }

  // ================= SAVE TO LOCAL STORAGE =================
  Future<void> _saveToLocalStorage(Map<String, dynamic> advertiserData) async {
    try {
      LocalStorage.userId = advertiserData["_id"] ?? LocalStorage.userId;
      LocalStorage.businessName = advertiserData["businessName"] ?? '';
      LocalStorage.businessType = advertiserData["businessType"] ?? '';
      LocalStorage.businessLicenceNumber = advertiserData["licenseNumber"] ?? '';
      LocalStorage.phone = advertiserData["phone"] ?? '';
      LocalStorage.advertiserBio = advertiserData["bio"] ?? '';
      LocalStorage.businessLogo = advertiserData["logo"] ?? '';

      await Future.wait([
        LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId),
        LocalStorage.setString(LocalStorageKeys.businessName, LocalStorage.businessName),
        LocalStorage.setString(LocalStorageKeys.businessType, LocalStorage.businessType),
        LocalStorage.setString(LocalStorageKeys.businessLicenceNumber, LocalStorage.businessLicenceNumber),
        LocalStorage.setString(LocalStorageKeys.phone, LocalStorage.phone),
        LocalStorage.setString(LocalStorageKeys.advertiserBio, LocalStorage.advertiserBio),
        LocalStorage.setString(LocalStorageKeys.businessLogo, LocalStorage.businessLogo),
      ]);

      debugPrint("✅ Data saved to local storage");
    } catch (e) {
      debugPrint("❌ Error saving to local storage: $e");
    }
  }

  void _loadFromLocalStorage() {
    businessNameController.text = LocalStorage.businessName;
    businessLicenceController.text = LocalStorage.businessLicenceNumber;
    businessTypeController.text = LocalStorage.businessType;
    bioController.text = LocalStorage.advertiserBio;

    _parseAndSetPhone(LocalStorage.phone);

    debugPrint("Loaded data from local storage");
  }

  // ================= IMAGE PICKER =================
  Future<bool> _requestImagePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) return true;
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return false;
    }
  }

  Future<void> getProfileImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: Get.context!,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final bool permissionGranted = await _requestImagePermission(source);
      if (!permissionGranted) {
        Get.snackbar(
          'Permission Required',
          'Please allow ${source == ImageSource.camera ? 'camera' : 'storage'} access',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && pickedFile.path.isNotEmpty) {
        selectedImage = File(pickedFile.path);
        update();
        Get.snackbar(
          'Success',
          'Image selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ================= LANGUAGE SELECT =================
  void selectLanguage(int index) {
    selectedLanguage = languages[index];
    update();
    Get.back();
  }

  // ================= EDIT PROFILE API =================
  Future<void> editProfileRepo() async {
    if (!formKey.currentState!.validate()) return;
    if (!LocalStorage.isLogIn) return;

    isLoading = true;
    update();

    try {
      debugPrint("Updating advertiser profile...");

      final String phoneToSend = fullPhoneNumber.isNotEmpty
          ? fullPhoneNumber
          : '$countryCode${phoneNumberController.text.trim()}';

      final Map<String, String> body = {
        "businessName": businessNameController.text.trim(),
        "businessType": businessTypeController.text.trim(),
        "licenseNumber": businessLicenceController.text.trim(),
        "phone": phoneToSend,
        "bio": bioController.text.trim().isEmpty ? "  " : bioController.text.trim(),
      };

      debugPrint("📦 Update Body: $body");
      debugPrint("🖼️ Image Path: ${selectedImage?.path}");

      final response = await ApiService.multipartUpdate(
        ApiEndPoint.advertiserUpdate,
        body: body,
        imagePath: selectedImage?.path,
      );

      debugPrint("📦 Response Status: ${response.statusCode}");
      debugPrint("📦 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final advertiserData = response.data['data'] ?? {};

        await _saveToLocalStorage(advertiserData);

        if (selectedImage?.path != null) {
          LocalStorage.myImage = selectedImage!.path;
          await LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
        }

        Utils.successSnackBar(
          "Success",
          response.data['message'] ?? "Profile Updated Successfully",
        );

        debugPrint(" Profile updated successfully");

        Get.to(const DashBoardProfile());
      } else {
        Utils.errorSnackBar(
          "Error",
          response.data['message'] ?? "Failed to update profile",
        );
      }
    } catch (e) {
      debugPrint("❌ Update Profile Error: $e");
      Utils.errorSnackBar("Error", "Failed to update profile: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  // ================= LIFE CYCLE =================
  @override
  void onClose() {
    businessNameController.dispose();
    bioController.dispose();
    phoneNumberController.dispose();
    businessLicenceController.dispose();
    businessTypeController.dispose();
    super.onClose();
  }
}