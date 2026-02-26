import 'package:giolee78/utils/log/app_log.dart';

import '../../../services/api/api_service.dart';
import '../../../config/api/api_end_point.dart';
import '../data/model/chat_list_model.dart';

Future<List<ChatModel>> chatRepository(
  int page,
  String value,
  bool isGroup,
) async {
  appLog("naimul");
  final String url =
      "${ApiEndPoint.chats}/my-chats?page=$page&isGroupChat=${isGroup ? "true" : "false"}";

  // Temporarily disabling searchTerm for debugging as per user request
  // if (value.isNotEmpty) {
  //   url += "&searchTerm=$value";
  // }
  print(">>>>>>>>>>>> 🌐 Fetching Chats: $url <<<<<<<<<<<<");

  final response = await ApiService.get(url);
  print(
    ">>>>>>>>>>>> 📥 Chat Repo Response (isGroup=$isGroup): Status=${response.statusCode} <<<<<<<<<<<<",
  );
  print(">>>>>>>>>>>> 📦 Raw Data: ${response.data} <<<<<<<<<<<<");

  if (response.statusCode == 200) {
    final chatList = response.data['data'] ?? [];
    print(
      ">>>>>>>>>>>> 📊 Items count in 'data': ${chatList.length} <<<<<<<<<<<<",
    );

    final List<ChatModel> list = [];

    for (var json in chatList) {
      try {
        list.add(ChatModel.fromJson(json));
      } catch (e) {
        print(
          ">>>>>>>>>>>> ❌ Chat Parsing Error for item: $json, error: $e <<<<<<<<<<<<",
        );
      }
    }

    return list;
  } else {
    return [];
  }
}
