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
    // Initialize based on saved role
    refreshRoleState();
  }

  void refreshRoleState() {
    // Check if the role is 'user'
    bool isUser = LocalStorage.role == "user";
    isUserScreenActive.value = true; // Both roles start with HomeScreen (index 0)
    currentIndex.value = 0;
  }

  void changeIndex(int index) {
    currentIndex.value = index;

    bool isUser = LocalStorage.role == "user";

    if (isUser) {
      // Users always stay on userScreens
      isUserScreenActive.value = true;
    } else {
      // Advertisers:
      // index 0 -> Home (User Screen List)
      // index 1 & 2 -> Advertise Screen List
      isUserScreenActive.value = (index == 0);
    }

    // Navbar visibility logic (show for Home, Add/Ads, and Message/Dashboard)
    showNavBar.value = true;
  }
}