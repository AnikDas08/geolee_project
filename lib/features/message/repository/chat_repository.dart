import 'package:giolee78/utils/log/app_log.dart';

import '../../../services/api/api_service.dart';
import '../../../config/api/api_end_point.dart';
import '../data/model/chat_list_model.dart';

Future<List<ChatModel>> chatRepository(int page, String value) async {
  appLog("naimul");
  String url = "${ApiEndPoint.chatRoom}?page=$page";

  if (value.isNotEmpty) {
    url += "&searchTerm=$value";
  }
  final response = await ApiService.get(url);

  if (response.statusCode == 200) {
    final chatList = response.data['data'] ?? [];

    final List<ChatModel> list = [];

    for (var chat in chatList) {
      list.add(ChatModel.fromJson(chat));
    }

    return list;
  } else {
    return [];
  }
}
