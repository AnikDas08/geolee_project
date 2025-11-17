import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init.tryCatch();

  runApp(const MyApp());
}

init() async {
  DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  SocketServices.connectToSocket();

  await Future.wait([
    LocalStorage.getAllPrefData(),
    NotificationService.initLocalNotification(),
    dotenv.load(fileName: ".env").catchError((error) {
      debugPrint("Warning: Failed to load .env file - $error");
      return null;
    }),
  ]);
}
