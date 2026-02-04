import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/log/app_log.dart';

class HomeNavController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isUserScreenActive = true.obs;
  final RxBool showNavBar = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshState();
  }

  /// Refreshes state based on LocalStorage
  void refreshState() {
    final bool isUser = userType == UserType.user;
    isUserScreenActive.value = isUser;

    // Set default starting point if it's the first initialization
    if (isUser) {
      if (currentIndex.value == 1 || (currentIndex.value == 2 && !isUser)) {
         // Optionally reset if coming from a different role state
      }
    }
    
    appLog('HomeNavController Initialized. Role: ${LocalStorage.myRole}, isUser: $isUser');
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    showNavBar.value = (index == 0 || index == 2);
    
    // Always sync with storage to be safe
    isUserScreenActive.value = (userType == UserType.user);
  }

  UserType get userType {
    final roleString = LocalStorage.myRole;
    return roleString == UserType.advertiser.name
        ? UserType.advertiser
        : UserType.user;
  }
}
