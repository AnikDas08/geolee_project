import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giolee78/services/api/api_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/storage_services.dart';
import 'main.dart' as GetStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetStorage.init();
  await init.tryCatch();
  runApp(const MyApp());
}

Future<void> init() async {
  final DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  await LocalStorage.getAllPrefData();
  SocketServices.connectToSocket();

  await Future.wait([
    NotificationService.initLocalNotification(),
    dotenv.load().catchError((error) {
      debugPrint("Warning: Failed to load .env file - $error");
      return null;
    }),
  ]);
}
