import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

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
    // Handle nested 'data' if it exists
    final Map<String, dynamic> data = (message is Map && message.containsKey('data') && message['data'] is Map)
        ? message['data'] as Map<String, dynamic>
        : (message is Map<String, dynamic> ? message : {});

    final String title = data['title'] ?? message['message'] ?? "New Notification";
    final String body = data['message'] ?? "";

    // Show in-app popup (Snackbar)
    Get.snackbar(
      title,
      body,
      backgroundColor: Colors.white.withOpacity(0.9),
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: const Icon(Icons.notifications_active, color: AppColors.primaryColor),
      duration: const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    );

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
          Random.secure().nextInt(10000), title, body, notificationDetails);
    });
  }
}
