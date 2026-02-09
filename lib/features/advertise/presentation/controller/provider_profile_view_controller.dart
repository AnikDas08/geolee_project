import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/advertise/presentation/screen/advertiser_edit_profile_screen.dart';
import 'package:giolee78/features/profile/data/model/user_profile_model.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/services/storage/storage_services.dart';

class ProviderProfileViewController extends GetxController {
  bool isLoading = false;
  UserProfileModel? profileModel;

  String _dateOfBirth = "";
  String _gender = "";


  // ================= USER DATA GETTERS =================

  String get userName => LocalStorage.myName.isNotEmpty ? LocalStorage.myName : "User Name";

  String get userImage => LocalStorage.myImage;
  String get businessLogo => LocalStorage.businessLogo;

  String get userEmail => LocalStorage.myEmail.isNotEmpty
      ? LocalStorage.myEmail
      : "example@mail.com";

  String get mobile => LocalStorage.mobile;

  String get dateOfBirth {if (LocalStorage.dateOfBirth.isEmpty) return "Not Selected";return LocalStorage.dateOfBirth.split('T').first;}

  String get gender => LocalStorage.gender.isNotEmpty ? LocalStorage.gender : "Not Selected";

  String get experience => LocalStorage.experience;

  String get bio => LocalStorage.bio.isNotEmpty ? LocalStorage.bio : "Bio Not Set Yet";

  double get balance => LocalStorage.balance;

  bool get verified => LocalStorage.verified;

  double get lat => LocalStorage.lat;

  double get log => LocalStorage.log;

  bool get accountInfoStatus => LocalStorage.accountInfoStatus;

  String get address => LocalStorage.address.isNotEmpty ? LocalStorage.address : "Not Set";


  String get about => bio;

  String get userId => LocalStorage.userId;

  String get businessName => LocalStorage.businessName;

  String get businessType => LocalStorage.businessType;
  String get phone => LocalStorage.phone;
  String get businessLicenceNumber => LocalStorage.businessLicenceNumber;
  String get advertiserBion => LocalStorage.advertiserBio?.isNotEmpty ?? false ? LocalStorage.advertiserBio! : "Bio Not Set Yet";



  // ================= LIFE CYCLE =================

  @override
  void onInit() {
    super.onInit();
    getAdvertiserData();
  }

  // ================= NAVIGATION =================

  void navigateToEditProfile() {
    Get.to(AdvertiserEditProfileScreen());
  }

  void goBack() {
    Get.back();
  }

  // ================= API CALL =================

  Future<void> getAdvertiserData() async {
    isLoading = true;
    update();

    try {
      final response = await ApiService.get(ApiEndPoint.advertiserProfile);

      if (response.statusCode == 200) {
        final Map<String, dynamic> res =
        response.data as Map<String, dynamic>;

        final advertiser = res['data'];
        if (advertiser == null) return;

        final user = advertiser['user'];

        // ---------- LOCATION ----------

        final coordinates =
            user?['location']?['coordinates'] ?? [0, 0];

        final double lat =
        coordinates.length > 1 ? coordinates[1].toDouble() : 0.0;
        final double log =
        coordinates.length > 0 ? coordinates[0].toDouble() : 0.0;

        // ---------- DATE ----------
        final String dob = user?['dob'] ?? "";
        final String createdAt = advertiser['createdAt'] ?? "";
        final String updatedAt = advertiser['updatedAt'] ?? "";

        // ---------- LOCAL STORAGE ----------
        LocalStorage.userId = user?['_id'] ?? "";
        LocalStorage.myName = user?['name'] ?? "";
        LocalStorage.myEmail = user?['email'] ?? "";
        LocalStorage.myImage = user?['image'] ?? "";
        LocalStorage.gender = user?['gender'] ?? "";
        LocalStorage.dateOfBirth = dob;
        LocalStorage.address = user?['address'] ?? "";

        LocalStorage.advertiserBio =
        (advertiser['bio'] != null && advertiser['bio'].toString().isNotEmpty)
            ? advertiser['bio']
            : "Bio Not Set Yet";

        LocalStorage.lat = lat;
        LocalStorage.log = log;

        LocalStorage.createdAt = createdAt;
        LocalStorage.updatedAt = updatedAt;

        // advertiser specific

        LocalStorage.businessName = advertiser['businessName'] ?? "";
        LocalStorage.businessType = advertiser['businessType'] ?? "";
        LocalStorage.businessLogo = advertiser['logo'] ?? "";
        LocalStorage.phone = advertiser['phone'] ?? "";
        LocalStorage.businessLicenceNumber = advertiser['licenseNumber'] ?? "";

        // ---------- SAVE PREF ----------

        await Future.wait([
          LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId),
          LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName),
          LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail),
          LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage),
          LocalStorage.setString(LocalStorageKeys.gender, LocalStorage.gender),
          LocalStorage.setString(LocalStorageKeys.dateOfBirth, LocalStorage.dateOfBirth),
          LocalStorage.setString(LocalStorageKeys.address, LocalStorage.address),
          LocalStorage.setDouble(LocalStorageKeys.lat, LocalStorage.lat),
          LocalStorage.setDouble(LocalStorageKeys.log, LocalStorage.log),
          LocalStorage.setString(LocalStorageKeys.createdAt, LocalStorage.createdAt),
          LocalStorage.setString(LocalStorageKeys.updatedAt, LocalStorage.updatedAt),
          LocalStorage.setString(LocalStorageKeys.businessName, LocalStorage.businessName),
          LocalStorage.setString(LocalStorageKeys.businessType, LocalStorage.businessType),
          LocalStorage.setString(LocalStorageKeys.businessLogo, LocalStorage.businessLogo),
          LocalStorage.setString(LocalStorageKeys.phone, LocalStorage.phone),
          LocalStorage.setString(LocalStorageKeys.advertiserBio, LocalStorage.advertiserBio),
        ]);

      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile");
    }

    isLoading = false;
    update();
  }


}
