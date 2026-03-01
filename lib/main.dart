import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await init.tryCatch();
  runApp(const MyApp());
}

Future<void> init() async {
  // Load storage first so token is available for DI and Sockets
  await LocalStorage.getAllPrefData();
  
  final DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  
  // Connect socket if token exists
  if (LocalStorage.token.isNotEmpty) {
    SocketServices.connectToSocket();
  }

  await Future.wait([
    NotificationService.initLocalNotification(),
    dotenv.load().catchError((error) {
      debugPrint("Warning: Failed to load .env file - $error");
      return null;
    }),
  ]);
}
