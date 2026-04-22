import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:giolee78/services/location/location_service.dart';
import 'package:giolee78/services/socket/socket_service.dart';
import 'package:giolee78/utils/extensions/extension.dart';
import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'services/notification/notification_service.dart';
import 'services/storage/storage_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification/firebase_notification_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await init.tryCatch();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Analytics
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logAppOpen();
  
  await FirebaseNotificationService().initNotifications();
  runApp(MyApp(analytics: analytics));
}

Future<void> init() async {
  await LocalStorage.getAllPrefData();

  final DependencyInjection dI = DependencyInjection();
  dI.dependencies();

  if (LocalStorage.token.isNotEmpty) {
    SocketServices.connectToSocket();
  }

  await Future.wait([
    NotificationService.initLocalNotification(),
    LocationService.inti(),
    dotenv.load().catchError((error) {
      debugPrint("Warning: Failed to load .env file - $error");
      return null;
    }),
  ]);
}
