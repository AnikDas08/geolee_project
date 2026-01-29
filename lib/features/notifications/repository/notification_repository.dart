import 'package:dio/dio.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import '../data/model/notification_response.dart';

class NotificationRepository {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.10.7.7:5006/api/v1",
      headers: {
        "Authorization": "Bearer ${LocalStorage.token}",
      },
    ),
  );

  Future<NotificationResponse> getNotifications(int page) async {
    final response = await dio.get(
      "/notifications/me",
      queryParameters: {
        "page": page,
        "limit": 10,
      },
    );

    return NotificationResponse.fromJson(response.data);
  }
}
