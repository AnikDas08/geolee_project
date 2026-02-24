import 'package:giolee78/services/storage/storage_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api/api_end_point.dart';
import '../notification/notification_service.dart';

class SocketServices {
  static final Map<String, io.Socket> _sockets = {};

  /// Get or create a socket for a specific namespace
  static io.Socket getSocket(String namespace) {
    // If a namespace fails, we should ideally fallback to root
    // For now, let's try to return the requested one or root if it's messaging/notification
    if (_sockets[namespace] == null || !_sockets[namespace]!.connected) {
      connectToNamespace(namespace);
    }
    return _sockets[namespace]!;
  }

  ///<<<============ Connect with namespace ====================>>>
  static void connectToNamespace(String namespace) {
    String baseUrl = ApiEndPoint.socketUrl;
    if (baseUrl.endsWith("/")) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Standardize URL joining
    String namespacePath = namespace == "/"
        ? ""
        : (namespace.startsWith("/") ? namespace : "/$namespace");
    String fullUrl = "$baseUrl$namespacePath";

    print(
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
      print(
        ">>>>>>>>>>>> 🌐 Socket Connected [$namespace]: ID=${socket.id} <<<<<<<<<<<<",
      );
    });

    socket.on('connect_error', (data) {
      print(
        ">>>>>>>>>>>> ❌ Socket Connection Error [$namespace]: $data <<<<<<<<<<<<",
      );
    });

    socket.on('error', (data) {
      print(">>>>>>>>>>>> ⚠️ Socket Error [$namespace]: $data <<<<<<<<<<<<");
    });

    socket.on('disconnect', (data) {
      print(
        ">>>>>>>>>>>> 🔌 Socket Disconnected [$namespace]: $data <<<<<<<<<<<<",
      );
    });

    // Unified Event Listeners (Setup on all sockets as redundancy, but primarily targeted at '/')
    socket.on("notification:new", (data) {
      print(
        ">>>>>>>>>>>> 🔔 New Notification via socket [$namespace]: $data <<<<<<<<<<<<",
      );
      NotificationService.showNotification(data);
    });

    socket.on("message:new", (data) {
      print(
        ">>>>>>>>>>>> 📩 New Message via socket [$namespace]: $data <<<<<<<<<<<<",
      );
    });

    socket.on("chat:update", (data) {
      print(">>>>>>>>>>>> 🔄 Chat Update via socket [$namespace] <<<<<<<<<<<<");
    });

    _sockets[namespace] = socket;
    socket.connect();
  }

  /// Compatibility methods for existing code that uses the root namespace
  static io.Socket get socket => getSocket("/");

  static void connectToSocket() {
    // Connect to prioritized namespaces
    connectToNamespace("/");
    // We still try these as per user request, but logic will fallback in usage
    connectToNamespace("messaging");
    connectToNamespace("notification");
  }

  ///<<<============ Join Chat Room ====================>>>
  static void joinRoom(String chatId) {
    print(
      ">>>>>>>>>>>> 🚪 Joining Room: $chatId (Primary: root socket) <<<<<<<<<<<<",
    );
    // Emit on root as well because namespaces are failin
    getSocket("/").emit("room:join", chatId);

    // Also try messaging if it happens to connect later
    if (_sockets["messaging"]?.connected ?? false) {
      _sockets["messaging"]?.emit("room:join", chatId);
    }
  }

  ///<<<============ Leave Chat Room ====================>>>
  static void leaveRoom(String chatId) {
    print(">>>>>>>>>>>> 🚪 Leaving Room: $chatId <<<<<<<<<<<<");
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
    // If requested namespace is not connected, use root as fallback
    if (namespace != "/" && _sockets[namespace]?.connected != true) {
      print(
        ">>>>>>>>>>>> ⚠️ Namespace $namespace not connected, listening on root for $event <<<<<<<<<<<<",
      );
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
