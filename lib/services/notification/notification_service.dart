import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotification() async {
    // Note: requestNotificationsPermission is called in UI isolate elsewhere.
    // Calling it here causes crashes in background isolates.
    
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

    // Create the high importance channel for general notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel", 
      "High Importance Notifications",
      importance: Importance.max,
      description: "This channel is used for important notifications.",
      playSound: true,
    );

    // Create a dedicated channel for messages that doesn't show a badge
    const AndroidNotificationChannel messageChannel = AndroidNotificationChannel(
      "message_channel", 
      "Chat Messages",
      importance: Importance.max,
      description: "This channel is used for chat message banners without badges.",
      playSound: true,
      showBadge: false, // Suppress icon badge for messages
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(messageChannel);
  }

  static Future<void> showNotification(dynamic message) async {
    // Handle nested 'data' if it exists
    final Map<String, dynamic> data = (message is Map && message.containsKey('data') && message['data'] is Map)
        ? message['data'] as Map<String, dynamic>
        : (message is Map<String, dynamic> ? message : {});

    final String title = data['title'] ?? message['title'] ?? data['message'] ?? message['message'] ?? "New Notification";
    final String body = data['body'] ?? message['body'] ?? data['message'] ?? message['message'] ?? "";

    // Detect if this is a chat message
    final String type = (data['type'] ?? '').toString().toLowerCase();
    final bool isMessage = type == 'chat' || 
                           type == 'message' || 
                           title.toLowerCase().contains('message') || 
                           body.toLowerCase().contains('message');

    // Determine if we should show a snackbar (foreground) or a system notification (background)
    bool isResumed = false;
    try {
      isResumed = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    } catch (_) {
      // In background isolates, WidgetsBinding might not be fully initialized
    }

    if (isResumed) {
      // Show premium in-app notification (Snackbar)
      // Note: We skip this for messages if handled by Socket.
      // But if showNotification is called, it means we want to show it.
      
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
      // System Tray notification logic
      final String channelId = isMessage ? "message_channel" : "high_importance_channel";
      final String channelName = isMessage ? "Chat Messages" : "High Importance Notifications";

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        channelId, 
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        ticker: "ticker",
        timeoutAfter: isMessage ? 5000 : null, // Auto-remove from list after 5s for messages
      );

      final DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: isMessage ? false : true,
        presentSound: true,
        presentList: isMessage ? false : true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: darwinNotificationDetails);

      flutterLocalNotificationsPlugin.show(
          Random.secure().nextInt(10000), title, body, notificationDetails);
    }
  }
}
