import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:giolee78/firebase_options.dart';
import 'package:giolee78/services/notification/notification_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/services/api/user_api_service.dart';

/// Top-level function for background and terminated notifications.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolates need their own initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background/terminated message: ${message.messageId}");

  // Ensure local storage is loaded to check login status
  await LocalStorage.getAllPrefData();
  if (!LocalStorage.isLogIn) {
    debugPrint("User is not logged in. Skipping notification banner.");
    return;
  }

  await NotificationService.initLocalNotification();
  
  // Only show manual notification if the payload DOES NOT have a notification object.
  // If message.notification exists, the Android OS shows it automatically in background/terminated mode.
  if (message.notification == null && message.data.isNotEmpty) {
     await NotificationService.showNotification(message.data);
  }
}





class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initializes the Firebase Messaging service============================

  Future<void> initNotifications() async {
    // Request permissions for iOS and newer Androids=======================
    await requestPermission();

    //  Set the background message handler============================
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Set foreground presentation options for iOS to show banners
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false, // Don't show badge by default in foreground
      sound: true,
    );

    // 3. Optional: Listen to foreground messages and show local notifications
    // using the existing NotificationService if they are in foreground.
    // The user explicitly requested "only background and terminated", 
    // but if the app is foreground, Firebase by default DOES NOT show a banner,
    // so we can suppress or just show a custom flutter_local_notification.



    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (!LocalStorage.isLogIn) {
        debugPrint("User is not logged in. Skipping foreground notification.");
        return;
      }

      // Filter: Silence message banners in foreground as Socket handles the UI/badge.
      final String type = message.data['type']?.toString().toLowerCase() ?? '';
      final bool isMessage = type == 'message' || 
                             type == 'chat' || 
                             message.data.containsKey('chat') || 
                             message.data.containsKey('text') || 
                             message.data.containsKey('content');

      if (isMessage) {
        debugPrint("💬 Foreground message detected. Skipping banner as requested.");
        return; 
      }

      if (message.notification != null) {
        NotificationService.showNotification({
          'title': message.notification!.title,
          'message': message.notification!.body,
          'data': message.data,
        });
      } else if (message.data.isNotEmpty) {
        NotificationService.showNotification(message.data);
      }
    });

    //  Listen for Token refreshes=========================================
    listenToTokenRefresh();
  }

  // Request User Permission for push notifications=========================

  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  //Get the FCM Device Token===============================================
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("Firebase Messaging Token (FCM): $token");
      return token;
    } catch (e) {
      debugPrint("Error fetching FCM Token: $e");
      return null;
    }
  }

  // Listen for Token refreshes===================================
  void listenToTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token refreshed: $newToken");
      if (LocalStorage.userId.isNotEmpty) {
        UserApiService.sendTokenToServer(
          userId: LocalStorage.userId,
          token: newToken,
        );
      }
    });
  }
}
