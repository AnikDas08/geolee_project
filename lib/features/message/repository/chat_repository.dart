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
  appLog("naimul");
  final String url =
      "${ApiEndPoint.chats}/my-chats?page=$page&isGroupChat=${isGroup ? "true" : "false"}";

  // Temporarily disabling searchTerm for debugging as per user request
  // if (value.isNotEmpty) {
  //   url += "&searchTerm=$value";
  // }
  print(">>>>>>>>>>>> 🌐 Fetching Chats (page=$page, isGroup=$isGroup): $url <<<<<<<<<<<<");

  final response = await ApiService.get(url);
  print(
    ">>>>>>>>>>>> 📥 Chat Repo Response (isGroup=$isGroup): Status=${response.statusCode} <<<<<<<<<<<<",
  );
  print(">>>>>>>>>>>> 📦 Raw Data: ${response.data} <<<<<<<<<<<<");

  if (response.statusCode == 200) {
    // Extract pagination info
    final paginationData = response.data['pagination'] ?? {};
    final int totalPage = paginationData['totalPage'] ?? 1;
    final int total = paginationData['total'] ?? 0;
    final int currentPage = paginationData['page'] ?? page;
    final int limit = paginationData['limit'] ?? 10;

    debugPrint("📊 Pagination Info: page=$currentPage, totalPage=$totalPage, total=$total, limit=$limit");

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

    return ChatRepositoryResponse(
      data: list,
      totalPage: totalPage,
      total: total,
      currentPage: currentPage,
      limit: limit,
    );
  } else {
    print(">>>>>>>>>>>> ❌ API Error: Status=${response.statusCode} <<<<<<<<<<<<");
    return ChatRepositoryResponse(
      data: [],
      totalPage: 1,
      total: 0,
      currentPage: page,
      limit: 10,
    );
  }
}
