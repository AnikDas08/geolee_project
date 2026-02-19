import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    final iosInitializationSettings = const DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      // print("Route");
      // Get.toNamed(AppRoute.notification);
    });
  }

  static Future<void> showNotification(dynamic message) async {

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        "High Importance Notification",
        importance: Importance.max);

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: "your channel Description",
            importance: Importance.high,
            priority: Priority.high,
            ticker: "ticker");

    final DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          0, message['message'], message['type'], notificationDetails);
    });
  }
}
