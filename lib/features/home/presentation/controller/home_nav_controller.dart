import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/log/app_log.dart';

class HomeNavController extends GetxController {
  var currentIndex = 0.obs;

  UserType get userType {
    final roleString = LocalStorage.myRole;
    final roleEnum = roleString == UserType.advertise.name
        ? UserType.advertise
        : UserType.user;
    appLog(roleEnum.toString());
    return roleEnum;
  }

}
