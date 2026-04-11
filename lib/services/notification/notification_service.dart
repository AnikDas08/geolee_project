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

    // Create the high importance channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel", 
      "High Importance Notifications",
      importance: Importance.max,
      description: "This channel is used for important notifications.",
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showNotification(dynamic message) async {
    // Handle nested 'data' if it exists
    final Map<String, dynamic> data = (message is Map && message.containsKey('data') && message['data'] is Map)
        ? message['data'] as Map<String, dynamic>
        : (message is Map<String, dynamic> ? message : {});

    final String title = data['title'] ?? message['title'] ?? data['message'] ?? message['message'] ?? "New Notification";
    final String body = data['body'] ?? message['body'] ?? data['message'] ?? message['message'] ?? "";

    // Determine if we should show a snackbar (foreground) or a system notification (background)
    bool isResumed = false;
    try {
      isResumed = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    } catch (_) {
      // In background isolates, WidgetsBinding might not be fully initialized or accessible
    }

    if (isResumed) {
      // Show premium in-app notification (Snackbar)
      Get.snackbar(
        "", // Empty title as we are using titleText
        "", // Empty message as we are using messageText
        titleText: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        messageText: Text(
          body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.7),
        barBlur: 20,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        borderWidth: 1,
        borderColor: Colors.white.withOpacity(0.5),
        leftBarIndicatorColor: AppColors.primaryColor,
        icon: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        duration: const Duration(seconds: 4),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        mainButton: TextButton(
          onPressed: () {
            if (Get.isSnackbarOpen) Get.back();
          },
          child: const Text(
            "View",
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // When in background or from background isolate, show system Tray notification
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        "high_importance_channel",
        "High Importance Notifications",
        importance: Importance.max,
        description: "This channel is used for important notifications.",
        playSound: true,
      );

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
              ticker: "ticker");

      final DarwinNotificationDetails darwinNotificationDetails =
          const DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true);

      final NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: darwinNotificationDetails);

      flutterLocalNotificationsPlugin.show(
          Random.secure().nextInt(10000), title, body, notificationDetails);
    }
  }
}
