import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/storage_services.dart';
import 'main.dart' as GetStorage;
import 'utils/log/global_log.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        globalError(details.exception, details.stack);
      };

      await GetStorage.init();
      runApp(const MyApp());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await init();
      });
    },
    (error, stack) {
      globalError(error, stack);
    },
  );
}

Future<void> init() async {
  final DependencyInjection dI = DependencyInjection();
  dI.dependencies();

  SocketService.connect();

  await Future.wait([
    NotificationService.initLocalNotification(),
    LocalStorage.getAllPrefData(),
    dotenv.load().catchError((error) {
      debugPrint("Warning: Failed to load .env file - $error");
      return null;
    }),
  ]);
}
