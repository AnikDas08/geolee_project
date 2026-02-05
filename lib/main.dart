import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/services/storage/storage_keys.dart';
import 'package:giolee78/utils/enum/enum.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/storage_services.dart';
import 'main.dart' as GetStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetStorage.init();
  await LocalStorage.getAllPrefData();
  await init.tryCatch();
  initRole();
  runApp(const MyApp());
}

init() async {
  DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  SocketServices.connectToSocket();

  await Future.wait([
    LocalStorage.getAllPrefData(),
    cookieJarInit(),
    NotificationService.initLocalNotification(),
    dotenv.load(fileName: ".env").catchError((error) {
      debugPrint("Warning: Failed to load .env file - $error");
      return null;
    }),
  ]);
}


Future<void> initRole() async {
  String role = LocalStorage.myRole;

  if (role.isEmpty) {
    await LocalStorage.setRole(
      LocalStorageKeys.myRole,
      UserType.user.name,
    );
    LocalStorage.myRole = UserType.user.name;
  } else {
    LocalStorage.myRole = role;
  }
}
