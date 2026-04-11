import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:giolee78/services/notification/notification_service.dart';

/// Top-level function for background and terminated notifications.
/// Must not be an anonymous function or a class method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processes
  await Firebase.initializeApp();
  debugPrint("Handling a background/terminated message: ${message.messageId}");




  //foreground message===============================================
/*
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      NotificationService.showNotification({
        'title': message.notification!.title,
        'message': message.notification!.body,
        'data': message.data,
      });
    }
  });
*/



  if (message.notification != null) {
    debugPrint('Message Title: ${message.notification?.title}');
    debugPrint('Message Body: ${message.notification?.body}');
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

    // 3. Optional: Listen to foreground messages and show local notifications using the existing NotificationService if they are in foreground.
    // The user explicitly requested "only background and terminated", 
    // but if the app is foreground, Firebase by default DOES NOT show a banner,
    // so we can suppress or just show a custom flutter_local_notification.



    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        // Provide the message mapping to existing NotificationService
        // NotificationService.showNotification({
        //  'title': message.notification!.title,
        //  'message': message.notification!.body,
        //  'data': message.data,
        // });
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

  // Listen for Token refreshes============================================
  void listenToTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token refreshed: $newToken");
      // TODO: Send new token to backend
    });
  }
}
