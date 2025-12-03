import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/log/app_log.dart';

class HomeNavController extends GetxController {
  var currentIndex = 0.obs;

  // Tracks whether the IndexedStack should be displaying the userScreens list (true)
  // or the advertiseScreens list (false).
  late final RxBool isUserScreenActive;
  String argument="";

  @override
  void onInit() {
    super.onInit();

    // Determine if the user is a standard user
    final isUser = userType == UserType.user;
    argument=Get.arguments;
    // Initialize the screen list state
    isUserScreenActive = isUser.obs;

    // Initialize the index state (Run only once when the controller is first created)
    if (!isUser) {
      // Advertiser starts on Dashboard (index 2)
      currentIndex.value = 2;
    } else {
      // User starts on Home (index 0)
      currentIndex.value = 0;
    }
  }

  UserType get userType {
    final roleString = LocalStorage.myRole;
    final roleEnum = roleString == UserType.advertise.name
        ? UserType.advertise
        : UserType.user;

    appLog(roleEnum.toString());
    return roleEnum;
  }
}