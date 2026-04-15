import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/utils/constants/app_colors.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Holds notification data from a terminated-state launch.
  /// HomeNav reads & clears this after mounting to navigate to the right screen.
  static Map<String, dynamic>? pendingNotificationData;

  static Future<void> initLocalNotification() async {
    // Note: requestNotificationsPermission is called in UI isolate elsewhere.
    // Calling it here causes crashes in background isolates.
    
    final androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    final iosInitializationSettings = const DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payloadStr = response.payload;
        if (payloadStr != null && payloadStr.isNotEmpty) {
          try {
            final Map<String, dynamic> data =
                jsonDecode(payloadStr) as Map<String, dynamic>;
            handleNotificationTap(data);
          } catch (e) {
            debugPrint('Error decoding notification payload: $e');
            Get.toNamed(AppRoutes.notifications);
          }
        } else {
          Get.toNamed(AppRoutes.notifications);
        }
      },
    );

    // Create the high importance channel for general notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel", 
      "High Importance Notifications",
      importance: Importance.max,
      description: "This channel is used for important notifications.",
    );

    // Create a dedicated channel for messages that doesn't show a badge
    const AndroidNotificationChannel messageChannel = AndroidNotificationChannel(
      "message_channel", 
      "Chat Messages",
      importance: Importance.max,
      description: "This channel is used for chat message banners without badges.",
      showBadge: false, // Suppress icon badge for messages
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(messageChannel);
  }

  static Future<void> showNotification(dynamic message) async {
    // Global Guard: Only show notifications if the user is logged in.
    // In background isolates (like firebaseMessagingBackgroundHandler), 
    // static variables might lose their state, so we check/reload if needed.
    if (!LocalStorage.isLogIn) {
      // Small optimization: If we are in background, try to reload once just to be sure.
      try {
        if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
          await LocalStorage.getAllPrefData();
        }
      } catch (_) {}
      
      if (!LocalStorage.isLogIn) {
        debugPrint("Skipping notification: User is not logged in.");
        return;
      }
    }

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
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        barBlur: 20,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        borderWidth: 1,
        borderColor: Colors.white.withValues(alpha: 0.5),
        leftBarIndicatorColor: AppColors.primaryColor,
        icon: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        mainButton: TextButton(
          onPressed: () {
            if (Get.isSnackbarOpen) Get.back();
            handleNotificationTap(data);
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
        timeoutAfter: isMessage ? 5000 : null,
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

      // Encode data as payload so tapping the tray notification can navigate
      final String payload = jsonEncode(data);

      flutterLocalNotificationsPlugin.show(
        Random.secure().nextInt(10000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    }
  }




  static void handleNotificationTap(Map<String, dynamic> data) {
    if (!LocalStorage.isLogIn) return;

    //Log every field==============================
    debugPrint('🔔 ===== Notification Tapped =====');
    data.forEach((key, value) => debugPrint('   [$key] = $value'));
    debugPrint('🔔 =================================');

    //Normalize type to lowercase==============================
    final String type = (data['type'] ?? '').toString().toLowerCase().trim();

    //isGroupChat comes as String "true"/"false" from backend==============================
    final dynamic rawIsGroup = data['isGroupChat'] ?? data['is_group_chat'];
    final bool isGroupChat = rawIsGroup != null && 
        (rawIsGroup.toString().toLowerCase() == 'true' || rawIsGroup == true);

    debugPrint('🔔 type="$type" | isGroupChat=$isGroupChat | rawWas=$rawIsGroup');

    //FRIEND_REQUEST → Friend Pending Screen==============================
    if (type == 'friend_request') {
      debugPrint('🔔 → FriendPendingScreen');
      Get.toNamed(AppRoutes.friendRequestScreen, arguments: data);
      return;
    }

    //Group message → Group Message Screen==============================
    if (type == 'text' && isGroupChat == true) {
      debugPrint('🔔 → GroupMessageScreen');
      Get.toNamed(AppRoutes.chat, arguments: data);
      return;
    }

    //Direct message → Chat List Screen==============================
    if (type == 'text' && isGroupChat == false) {
      debugPrint('🔔 → ChatListScreen');
      Get.toNamed(AppRoutes.chat, arguments: data);
      return;
    }

    //Direct message without isGroupChat fallback==============================
    if (type == 'text' && data.containsKey('chat')) {
      debugPrint('🔔 → ChatListScreen (no isGroupChat fallback)');
      Get.toNamed(AppRoutes.chat, arguments: data);
      return;
    }

    //FRIEND_REQUEST_ACCEPTED / AD_ACTIVATED / AD_DEACTIVATED → Notifications==============================
    debugPrint('🔔 → NotificationsScreen (type="$type")');
    Get.toNamed(AppRoutes.notifications);
  }
}
