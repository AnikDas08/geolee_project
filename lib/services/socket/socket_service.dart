import 'package:giolee78/utils/log/app_log.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/api/api_end_point.dart';
import '../notification/notification_service.dart';

class SocketServices {
  static late io.Socket _socket;
  bool show = false;

  ///<<<============ Connect with socket ====================>>>
  static void connectToSocket() {
    _socket = io.io(
      ApiEndPoint.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((data) => appLog("=============> Connection $data"));
    _socket.onConnectError((data) => appLog("========>Connection Error $data"));
    _socket.connect();

    // Listen for new notifications
    _socket.on("notification:new", (data) {
      appLog("================> New Notification via socket: $data");
      NotificationService.showNotification(data);
    });
  }

  ///<<<============ Join Chat Room ====================>>>
  static void joinRoom(String chatId) {
    if (!_socket.connected) {
      connectToSocket();
    }
    appLog("=============> Joining Room: $chatId");
    _socket.emit("room:join", chatId);
  }

  ///<<<============ Leave Chat Room ====================>>>
  static void leaveRoom(String chatId) {
    if (_socket.connected) {
      appLog("=============> Leaving Room: $chatId");
      _socket.emit("room:leave", chatId);
    }
  }

  static void on(String event, Function(dynamic data) handler) {
    if (!_socket.connected) {
      connectToSocket();
    }
    _socket.on(event, handler);
  }

  static void emit(String event, Function(dynamic data) handler) {
    if (!_socket.connected) {
      connectToSocket();
    }
    _socket.emit(event, handler);
  }

  static void emitWithAck(
    String event,
    dynamic data,
    Function(dynamic data) handler,
  ) {
    if (!_socket.connected) {
      connectToSocket();
    }
    _socket.emitWithAck(event, data, ack: handler);
  }
}
