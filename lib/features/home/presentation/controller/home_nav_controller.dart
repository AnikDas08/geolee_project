import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';

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
    final bool isUser = LocalStorage.role == "user";
    isUserScreenActive.value = true; // Both roles start with HomeScreen (index 0)
    currentIndex.value = 0;
  }

  void changeIndex(int index) {
    currentIndex.value = index;

    final bool isUser = LocalStorage.role == "user";

    if (isUser) {
      isUserScreenActive.value = true;
    } else {
      isUserScreenActive.value = (index == 0);
    }

    // BottomNav control
    if (index == 1) {   // Clicker / AddPost
      showNavBar.value = false;
    } else {
      showNavBar.value = true;
    }
  }
}