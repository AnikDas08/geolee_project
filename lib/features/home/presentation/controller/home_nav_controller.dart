import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/log/app_log.dart';

class HomeNavController extends GetxController {
  /// Current selected index
  final RxInt currentIndex = 0.obs;

  /// true  -> userScreens
  /// false -> advertiseScreens
  late final RxBool isUserScreenActive;

  /// BottomNav + FAB visibility
  /// ONLY visible when index == 0 (Home)
  final RxBool showNavBar = true.obs;

  @override
  void onInit() {
    super.onInit();

    final bool isUser = userType == UserType.user;
    isUserScreenActive = isUser.obs;

    if (isUser) {
      // User starts from Home
      currentIndex.value = 0;
      showNavBar.value = true;
    }
    else if (isUser==false&&userType==UserType.advertise) {
      showNavBar.value = true;
    }
    else {
      // Advertiser starts from Dashboard
      currentIndex.value = 0;
      showNavBar.value = true;
    }
  }

  /// Central navigation handler
  void changeIndex(int index) {
    currentIndex.value = index;

    final bool isAdvertiser = userType == UserType.advertise;

    /// ✅ Show navbar rules
    /// Home (0) -> always show
    /// Dashboard (2) -> only for advertiser
    showNavBar.value =
        index == 0 || (isAdvertiser && index == 2);

    /// Screen list switching
    if (isAdvertiser) {
      // Advertiser:
      // Home -> userScreens
      // Others -> advertiseScreens
      isUserScreenActive.value = index == 0;
    } else {
      // Normal user always userScreens
      isUserScreenActive.value = true;
    }
  }


  /// Resolve user role
  UserType get userType {
    final roleString = LocalStorage.myRole;

    final roleEnum = roleString == UserType.advertise.name
        ? UserType.advertise
        : UserType.user;

    appLog('UserType: $roleEnum');
    return roleEnum;
  }
}
