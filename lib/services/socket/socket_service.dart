import 'package:flutter/material.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api/api_end_point.dart';
import '../../features/notifications/data/model/notification_model.dart';
import '../../features/notifications/presentation/controller/notifications_controller.dart';
import '../../features/message/presentation/controller/message_controller.dart';
import '../../features/friend/presentation/controller/my_friend_controller.dart';
import '../notification/notification_service.dart';
import 'package:get/get.dart';




class SocketServices {
  static final Map<String, io.Socket> _sockets = {};

  static io.Socket getSocket(String namespace) {
    if (_sockets[namespace] == null || !_sockets[namespace]!.connected) {
      connectToNamespace(namespace);
    }
    return _sockets[namespace]!;
  }

  static final Set<String> _processedNotificationIds = {};

  static void connectToNamespace(String namespace) {
    String baseUrl = ApiEndPoint.socketUrl;
    if (baseUrl.endsWith("/")) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    final String namespacePath = namespace == "/"
        ? ""
        : (namespace.startsWith("/") ? namespace : "/$namespace");
    final String fullUrl = "$baseUrl$namespacePath";

    debugPrint(
      ">>>>>>>>>>>> 🔌 Connecting to Namespace: '$namespace' via $fullUrl <<<<<<<<<<<<",
    );

    _sockets[namespace]?.dispose();

    final socket = io.io(
      fullUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setExtraHeaders({'Authorization': 'Bearer ${LocalStorage.token}'})
          .setAuth({'token': LocalStorage.token})
          .setQuery({'token': LocalStorage.token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    socket.on('connect', (data) {
      debugPrint(
        ">>>>>>>>>>>> 🌐 Socket Connected [$namespace]: ID=${socket.id} <<<<<<<<<<<<",
      );
    });

    socket.on('connect_error', (data) {
      debugPrint(
        ">>>>>>>>>>>>  Socket Connection Error [$namespace]: $data <<<<<<<<<<<<",
      );
    });

    socket.on('error', (data) {
      debugPrint(
        ">>>>>>>>>>>> ⚠ Socket Error [$namespace]: $data <<<<<<<<<<<<",
      );
    });

    socket.on('disconnect', (data) {
      debugPrint(
        ">>>>>>>>>>>> 🔌 Socket Disconnected [$namespace]: $data <<<<<<<<<<<<",
      );
    });

    socket.on("notification:new", (data) {
      _onNotificationReceived(data, namespace, "notification:new");
    });

    // Add user specific notification listener
    if (LocalStorage.userId.isNotEmpty) {
      final String userNotifEvent = "notification::${LocalStorage.userId}";
      socket.on(userNotifEvent, (data) {
        _onNotificationReceived(data, namespace, userNotifEvent);
      });
    }

    socket.on("message:new", (data) {
      debugPrint(
        ">>>>>>>>>>>> 📩 New Message via socket [$namespace]: $data <<<<<<<<<<<<",
      );
      print(">>>>>>>>>>>> 📩 RAW MESSAGE DATA: $data <<<<<<<<<<<<");
      _handleNewMessageNotification(data);
    });

    socket.on("chat:update", (data) {
      debugPrint(
        ">>>>>>>>>>>> 🔄 Chat Update via socket [$namespace] <<<<<<<<<<<<",
      );
    });

    _sockets[namespace] = socket;
    socket.connect();
  }

  static void _onNotificationReceived(dynamic data, String namespace, String event) {
    try {
      final Map<String, dynamic> notifData = (data is Map && data.containsKey('data') && data['data'] is Map)
          ? data['data'] as Map<String, dynamic>
          : (data is Map<String, dynamic> ? data : {});

      final String id = notifData['_id'] ?? notifData['id'] ?? '';

      if (id.isNotEmpty) {
        if (_processedNotificationIds.contains(id)) {
          debugPrint("🚫 Duplicate notification ignored: ID=$id from namespace=$namespace via event=$event");
          return;
        }
        _processedNotificationIds.add(id);
        
        // Safety: Keep the set small
        if (_processedNotificationIds.length > 50) {
          _processedNotificationIds.remove(_processedNotificationIds.first);
        }
      }

      debugPrint(
        ">>>>>>>>>>>> 🔔 New UNIQUE Notification via socket [$namespace] ($event): $data <<<<<<<<<<<<",
      );
      
      NotificationService.showNotification(data);
      _handleNewNotification(data);
    } catch (e) {
      debugPrint("Error in _onNotificationReceived: $e");
    }
  }

  //Notification handle
  static void _handleNewNotification(dynamic data) {
    try {
      final NotificationsController controller =
          Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : Get.put(NotificationsController());

      final newNotification = NotificationModel.fromJson(
        data as Map<String, dynamic>,
      );

      // Secondary check: avoid adding if ID already exists in the list
      if (controller.notifications.any((n) => n.id == newNotification.id)) {
        debugPrint("🚫 Skipping list insert: notification ${newNotification.id} already exists");
        return;
      }

      controller.notifications.insert(0, newNotification);
      controller.unreadCount.value++;
      controller.update();

      // Check if this is a friend request notification
      // We check title or message keywords like 'friend request' or 'friendship'
      final title = newNotification.title.toLowerCase();
      final body = newNotification.message.toLowerCase();

      if (title.contains('friend request') ||
          body.contains('friend request') ||
          title.contains('friendship') ||
          body.contains('friendship')) {
        debugPrint("🔄 Friend request detected in notification, refreshing MyFriendController...");
        if (Get.isRegistered<MyFriendController>()) {
          Get.find<MyFriendController>().fetchFriendRequests();
        } else {
          // If not registered, we can't refresh, but usually it's used in home
          // Alternatively, put it to ensure it's loaded if needed
          final myFriendController = Get.put(MyFriendController());
          myFriendController.fetchFriendRequests();
        }
      }
    } catch (e) {
      debugPrint("Error handling notification: $e");
    }
  }


  static void _handleNewMessageNotification(dynamic data) {
    try {
      final Map<String, dynamic> messageData = data as Map<String, dynamic>;

      final String incomingChatId = messageData['chat'] is String
          ? messageData['chat']
          : messageData['chat']?['_id'] ?? '';

      final String senderId = messageData['sender'] is Map
          ? messageData['sender']['_id'] ?? ''
          : messageData['sender']?.toString() ?? '';

      if (senderId.isNotEmpty && 
          LocalStorage.userId.isNotEmpty && 
          senderId.trim() == LocalStorage.userId.trim()) {
        debugPrint("👤 Self-message via socket, skipping notification.");
        return;
      }

      String currentOpenChatId = '';
      if (Get.isRegistered<MessageController>()) {
        currentOpenChatId = Get.find<MessageController>().chatId;
      }

      if (currentOpenChatId == incomingChatId) return;

      final String senderName = messageData['sender'] is Map
          ? messageData['sender']['name'] ?? 'Someone'
          : 'Someone';

      final String type = messageData['type'] ?? 'text';
      final String body = type == 'text'
          ? (messageData['text'] ?? messageData['content'] ?? 'Sent a message')
          : type == 'image'
          ? '📷 Sent an image'
          : type == 'document'
          ? '📄 Sent a document'
          : '📎 Sent a file';

      NotificationService.showNotification({
        'title': senderName,
        'message': body,
      });

      // ==========================================

      if (Get.isRegistered<NotificationsController>()) {
        final controller = Get.find<NotificationsController>();
        controller.unreadCount.value++;
        controller.update();
      }

      debugPrint("✅ Message notification shown from: $senderName");

    } catch (e) {

      debugPrint("❌ Error handling message notification: $e");

    }
  }

  static io.Socket get socket => getSocket("/");

  static void connectToSocket() {
    connectToNamespace("/");
    connectToNamespace("messaging");
    connectToNamespace("notification");
    connectToNamespace("notifications");
  }

  static void joinRoom(String chatId) {
    debugPrint(">>>>>>>>>>>> 🚪 Joining Room: $chatId <<<<<<<<<<<<");
    getSocket("/").emit("room:join", chatId);
    if (_sockets["messaging"]?.connected ?? false) {
      _sockets["messaging"]?.emit("room:join", chatId);
    }
  }

  static void leaveRoom(String chatId) {
    debugPrint(">>>>>>>>>>>> 🚪 Leaving Room: $chatId <<<<<<<<<<<<");
    getSocket("/").emit("room:leave", chatId);
    if (_sockets["messaging"]?.connected ?? false) {
      _sockets["messaging"]?.emit("room:leave", chatId);
    }
  }

  static void on(
    String event,
    Function(dynamic data) handler, {
    String namespace = "/",
  }) {
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      debugPrint(
        ">>>>>>>>>>>> ⚠️ Namespace $namespace not connected, listening on root for $event <<<<<<<<<<<<",
      );
      getSocket("/").on(event, handler);
    } else {
      getSocket(namespace).on(event, handler);
    }
  }

  static void off(String event, {String namespace = "/"}) {
    _sockets[namespace]?.off(event);
  }

  static void emit(String event, dynamic data, {String namespace = "/"}) {
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      getSocket("/").emit(event, data);
    } else {
      getSocket(namespace).emit(event, data);
    }
  }

  static void emitWithAck(
    String event,
    dynamic data,
    Function(dynamic data) handler, {
    String namespace = "/",
  }) {
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      getSocket("/").emitWithAck(event, data, ack: handler);
    } else {
      getSocket(namespace).emitWithAck(event, data, ack: handler);
    }
  }
}
