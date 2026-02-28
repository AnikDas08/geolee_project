import 'package:flutter/material.dart';
import 'package:giolee78/utils/log/app_log.dart';
import '../../../services/api/api_service.dart';
import '../../../config/api/api_end_point.dart';
import '../data/model/chat_list_model.dart';

class ChatRepositoryResponse {
  final List<ChatModel> data;
  final int totalPage;
  final int total;
  final int currentPage;
  final int limit;

  ChatRepositoryResponse({
    required this.data,
    required this.totalPage,
    required this.total,
    required this.currentPage,
    required this.limit,
  });
}

Future<ChatRepositoryResponse> chatRepository(
    int page,
    String value,
    bool isGroup,
    ) async {
  appLog("Fetching for Search: $value");

  // Construct URL with searchTerm
  String url = "${ApiEndPoint.chats}/my-chats?page=$page&isGroupChat=${isGroup ? "true" : "false"}";

  // Re-enabled searchTerm
  if (value.trim().isNotEmpty) {
    url += "&searchTerm=${Uri.encodeComponent(value.trim())}";
  }

  print(">>>>>>>>>>>> 🌐 Fetching Chats: $url <<<<<<<<<<<<");

  final response = await ApiService.get(url);

  if (response.statusCode == 200) {
    final paginationData = response.data['pagination'] ?? {};
    final int totalPage = paginationData['totalPage'] ?? 1;
    final int total = paginationData['total'] ?? 0;
    final int currentPage = paginationData['page'] ?? page;
    final int limit = paginationData['limit'] ?? 10;

    final chatList = response.data['data'] ?? [];
    final List<ChatModel> list = [];

    for (var json in chatList) {
      try {
        list.add(ChatModel.fromJson(json));
      } catch (e) {
        print("❌ Parsing Error: $e");
      }
    }

    return ChatRepositoryResponse(
      data: list,
      totalPage: totalPage,
      total: total,
      currentPage: currentPage,
      limit: limit,
    );
  } else {
    return ChatRepositoryResponse(
      data: [], totalPage: 1, total: 0, currentPage: page, limit: 10,
    );
  }
}
