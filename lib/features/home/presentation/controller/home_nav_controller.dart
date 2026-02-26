import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';

class HomeNavController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isUserScreenActive = true.obs;
  final RxBool showNavBar = true.obs;

  @override
  void onInit() {
    super.onInit();

    refreshRoleState();
  }

  void refreshRoleState() {
    isUserScreenActive.value = true;
    currentIndex.value = 0;
  }

  void changeIndex(int index) {
    currentIndex.value = index;

    if (LocalStorage.isUser) {
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
