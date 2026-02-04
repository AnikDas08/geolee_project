import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/log/app_log.dart';
import '../../../../services/storage/storage_keys.dart';

class HomeNavController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool showNavBar = true.obs;
  
  // Observable mode to track if we are viewing as User or Advertiser
  final Rx<UserType> currentMode = UserType.user.obs;

  @override
  void onInit() {
    super.onInit();
    refreshMode();
  }

  /// Refreshes the mode based on the user's explicit preference stored in activeRole
  void refreshMode() {
    // We use activeRole to track the current UI state independently of the account role
    final activeRole = LocalStorage.activeRole;
    
    if (activeRole == UserType.advertiser.name) {
       currentMode.value = UserType.advertiser;
       currentIndex.value = 2; // Dashboard for Advertisers
    } else {
       currentMode.value = UserType.user;
       currentIndex.value = 0;
    }
    
    appLog('UI Mode refreshed to: ${currentMode.value}');
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    showNavBar.value = (index == 0 || index == 2);
  }

  /// Explicitly switch the viewing mode
  Future<void> switchMode(UserType mode) async {
    currentMode.value = mode;
    await LocalStorage.setString(LocalStorageKeys.activeRole, mode.name);
    await LocalStorage.getAllPrefData();
    
    if (mode == UserType.user) {
      currentIndex.value = 0;
    } else {
      currentIndex.value = 2;
    }
  }
}
