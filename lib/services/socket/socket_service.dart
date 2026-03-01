import 'package:giolee78/services/storage/storage_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api/api_end_point.dart';
import '../../features/notifications/data/model/notification_model.dart';
import '../../features/notifications/presentation/controller/notifications_controller.dart';
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

  static void connectToNamespace(String namespace) {
    String baseUrl = ApiEndPoint.socketUrl;
    if (baseUrl.endsWith("/")) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    final String namespacePath = namespace == "/"
        ? ""
        : (namespace.startsWith("/") ? namespace : "/$namespace");
    final String fullUrl = "$baseUrl$namespacePath";

    print(">>>>>>>>>>>> 🔌 Connecting to Namespace: '$namespace' via $fullUrl <<<<<<<<<<<<");

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
      print(">>>>>>>>>>>> 🌐 Socket Connected [$namespace]: ID=${socket.id} <<<<<<<<<<<<");
    });

    socket.on('connect_error', (data) {
      print(">>>>>>>>>>>> ❌ Socket Connection Error [$namespace]: $data <<<<<<<<<<<<");
    });

    socket.on('error', (data) {
      print(">>>>>>>>>>>> ⚠️ Socket Error [$namespace]: $data <<<<<<<<<<<<");
    });

    socket.on('disconnect', (data) {
      print(">>>>>>>>>>>> 🔌 Socket Disconnected [$namespace]: $data <<<<<<<<<<<<");
    });


    socket.on("notification:new", (data) {
      print(">>>>>>>>>>>> 🔔 New Notification via socket [$namespace]: $data <<<<<<<<<<<<");
      NotificationService.showNotification(data);
      _handleNewNotification(data); // 👈 Added
    });

    socket.on("message:new", (data) {
      print(">>>>>>>>>>>> 📩 New Message via socket [$namespace]: $data <<<<<<<<<<<<");
    });

    socket.on("chat:update", (data) {
      print(">>>>>>>>>>>> 🔄 Chat Update via socket [$namespace] <<<<<<<<<<<<");
    });

    _sockets[namespace] = socket;
    socket.connect();
  }

  // ✅ CORRECT PLACE — inside the class, outside connectToNamespace
  static void _handleNewNotification(dynamic data) {
    try {
      if (Get.isRegistered<NotificationsController>()) {
        final controller = Get.find<NotificationsController>();
        final newNotification = NotificationModel.fromJson(data as Map<String, dynamic>);
        controller.notifications.insert(0, newNotification);
        controller.unreadCount.value++;
        controller.update();
      }
    } catch (e) {
      print("Error handling new notification in controller: $e");
    }
  }

  static io.Socket get socket => getSocket("/");

  static void connectToSocket() {
    connectToNamespace("/");
    connectToNamespace("messaging");
    connectToNamespace("notification");
  }

  static void joinRoom(String chatId) {
    print(">>>>>>>>>>>> 🚪 Joining Room: $chatId <<<<<<<<<<<<");
    getSocket("/").emit("room:join", chatId);
    if (_sockets["messaging"]?.connected ?? false) {
      _sockets["messaging"]?.emit("room:join", chatId);
    }
  }

  static void leaveRoom(String chatId) {
    print(">>>>>>>>>>>> 🚪 Leaving Room: $chatId <<<<<<<<<<<<");
    getSocket("/").emit("room:leave", chatId);
    if (_sockets["messaging"]?.connected ?? false) {
      _sockets["messaging"]?.emit("room:leave", chatId);
    }
  }

  static void on(String event, Function(dynamic data) handler, {String namespace = "/"}) {
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      print(">>>>>>>>>>>> ⚠️ Namespace $namespace not connected, listening on root for $event <<<<<<<<<<<<");
      getSocket("/").on(event, handler);
    } else {
      getSocket(namespace).on(event, handler);
    }
  }

  static void emit(String event, dynamic data, {String namespace = "/"}) {
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      getSocket("/").emit(event, data);
    } else {
      getSocket(namespace).emit(event, data);
    }
  }

  static void emitWithAck(String event, dynamic data, Function(dynamic data) handler, {String namespace = "/"}) {
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      getSocket("/").emitWithAck(event, data, ack: handler);
    } else {
      getSocket(namespace).emitWithAck(event, data, ack: handler);
    }
  }
}