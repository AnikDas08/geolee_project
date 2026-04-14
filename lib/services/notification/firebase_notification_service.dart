import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:giolee78/firebase_options.dart';
import 'package:giolee78/services/notification/notification_service.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:giolee78/services/api/user_api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ═══════════════════════════════════════════════════════
  // 📦 PAYLOAD DEBUG — server ki pathaitase dekhun
  // ═══════════════════════════════════════════════════════
  debugPrint('📦 ===== FCM BACKGROUND PAYLOAD =====');
  debugPrint('📦 notification.title : ${message.notification?.title}');
  debugPrint('📦 notification.body  : ${message.notification?.body}');
  debugPrint('📦 data keys total    : ${message.data.length}');
  message.data.forEach((key, value) {
    debugPrint('📦   [$key] = $value');
  });
  debugPrint('📦 =====================================');

  await LocalStorage.getAllPrefData();
  if (!LocalStorage.isLogIn) {
    debugPrint("User is not logged in. Skipping notification banner.");
    return;
  }

  await NotificationService.initLocalNotification();

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

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false, // Don't show badge by default in foreground
      sound: true,
    );




    // ── Terminated app: user tapped notification that launched the app ──────
    // STORE here — splash's Get.offAllNamed(homeNav) would override immediate nav.
    // HomeNav.initState() consumes this after mounting.
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        final merged = _buildRoutingData(message);
        debugPrint("📬 Terminated launch — merged data: $merged");
        NotificationService.pendingNotificationData = merged;
      }
    });

    // ── Background app: user tapped notification banner ───────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final merged = _buildRoutingData(message);
      debugPrint("📬 onMessageOpenedApp — merged data: $merged");
      NotificationService.handleNotificationTap(merged);
    });


    // ── Foreground message ─────────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (!LocalStorage.isLogIn) {
        debugPrint("User is not logged in. Skipping foreground notification.");
        return;
      }

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

  /// Merges [message.notification] fields + [message.data] into one flat map.
  /// This ensures routing works whether the server sends a notification block,
  /// a data block, or both.
  static Map<String, dynamic> _buildRoutingData(RemoteMessage message) {
    final Map<String, dynamic> merged = {};

    // Start with the data payload (custom key-value pairs from backend)
    merged.addAll(message.data);

    // Add notification fields only if NOT already in data (data takes priority)
    if (message.notification != null) {
      merged.putIfAbsent('title', () => message.notification!.title ?? '');
      merged.putIfAbsent('body', () => message.notification!.body ?? '');
    }

    // Log every field so we can see exactly what the server sends
    debugPrint('🔔 ===== FCM RemoteMessage fields =====');
    debugPrint('   notification.title : ${message.notification?.title}');
    debugPrint('   notification.body  : ${message.notification?.body}');
    debugPrint('   data keys          : ${message.data.keys.toList()}');
    message.data.forEach((k, v) => debugPrint('   data.$k : $v'));
    debugPrint('🔔 ======================================');

    return merged;
  }
}
