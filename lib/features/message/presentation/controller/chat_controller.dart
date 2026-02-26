import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/chat_list_model.dart';
import '../../repository/chat_repository.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/enum/enum.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';

class ChatController extends GetxController {
  List<ChatModel> singleChats = [];
  List<ChatModel> chats = [];
  List<ChatModel> filteredChats = [];

  bool isSingleLoading = false;
  bool isGroupLoading = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNoData = false;
  int page = 0;

  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  static ChatController get instance => Get.put(ChatController());

  void clearSearch() {
    searchController.clear();
    filteredChats = chats;
    update();
  }

  void searchChats(v) {
    getChatRepos(showLoading: false);
  }

  void moreChats() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (isLoadingMore || hasNoData) return;
        isLoadingMore = true;
        update();
        page++;
        final List<ChatModel> list = await chatRepository(
          page,
          searchController.text.trim(),
          true,
        );

        final joinedGroups = list
            .where((item) =>
        item.isGroup &&
            item.participants.any((p) => p.sId == LocalStorage.userId))
            .toList();

        chats.addAll(joinedGroups);
        filteredChats = chats;
        isLoadingMore = false;
        update();
      }
    });
  }

  Future<void> getChatRepos({
    bool showLoading = true,
    bool isGroup = false,
  }) async {
    try {
      if (showLoading) {
        if (isGroup) {
          isGroupLoading = true;
        } else {
          isSingleLoading = true;
        }
        isLoading = true;
        update();
      }

      page = 1;
      final List<ChatModel> list = await chatRepository(
        page,
        searchController.text.trim(),
        isGroup,
      );

      if (isGroup) {
        chats.clear();
        final myGroups = list
            .where((item) =>
        item.isGroup &&
            item.participants.any((p) => p.sId == LocalStorage.userId))
            .toList();
        chats.addAll(myGroups);
        filteredChats = chats;
      } else {
        singleChats.clear();
        singleChats.addAll(list.where((item) => !item.isGroup).toList());

        // ✅ Chat load হওয়ার পর friendship status check করো
        await _markFriendStatus();
      }
    } catch (e) {
      print(">>>>>>>>>>>> ❌ getChatRepos Error: $e <<<<<<<<<<<<");
    } finally {
      if (isGroup) {
        isGroupLoading = false;
      } else {
        isSingleLoading = false;
      }
      isLoading = isSingleLoading || isGroupLoading;
      update();
    }
  }

  // ================================================
  // ✅ প্রতিটা single chat participant এর friendship
  // status parallel এ check করো এবং ChatModel update করো
  // ================================================
  Future<void> _markFriendStatus() async {
    if (singleChats.isEmpty) return;

    final List<Future> checks = singleChats.map((chat) async {
      if (chat.participant.sId.isEmpty) return;

      try {
        final response = await ApiService.get(
          "${ApiEndPoint.checkFriendStatus}${chat.participant.sId}",
        );

        bool isFriend = false;
        if (response.statusCode == 200) {
          final data = response.data['data'];
          isFriend = data['isAlreadyFriend'] == true;
        }
        // 400 = not friends → isFriend stays false

        final index = singleChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          singleChats[index] =
              singleChats[index].copyWith(isFriend: isFriend);
        }
      } catch (_) {
        // error হলে false রাখো (white দেখাবে)
        final index = singleChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          singleChats[index] =
              singleChats[index].copyWith(isFriend: false);
        }
      }
    }).toList();

    await Future.wait(checks);
    update();
  }

  Status get status {
    if (isGroupLoading && chats.isEmpty) return Status.loading;
    if (filteredChats.isEmpty && hasNoData) return Status.error;
    return Status.completed;
  }

  Future<void> listenChat() async {
    SocketServices.on("chat:update", (data) {
      getChatRepos(showLoading: false);
      getChatRepos(showLoading: false, isGroup: true);
    });

    final String eventName = "update-chatlist::${LocalStorage.userId}";
    SocketServices.on(eventName, (data) {
      page = 0;
      chats.clear();
      singleChats.clear();
      filteredChats.clear();
      hasNoData = false;

      for (var item in data) {
        try {
          final chat = ChatModel.fromJson(item);
          if (chat.isGroup) {
            if (chat.participants.any((p) => p.sId == LocalStorage.userId)) {
              chats.add(chat);
            }
          } else {
            singleChats.add(chat);
          }
        } catch (e) {
          print(">>>>>>>>>>>> ❌ Socket Data Parsing Error: $e <<<<<<<<<<<<");
        }
      }

      filteredChats = chats;
      update();
      _markFriendStatus(); // socket update এও re-check
    });
  }

  void markChatAsSeen(String chatId) {
    int index = singleChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      singleChats[index] = singleChats[index].copyWith(unreadCount: 0);
      update();
      return;
    }

    index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      chats[index] = chats[index].copyWith(unreadCount: 0);
      filteredChats = chats;
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    listenChat();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      getChatRepos(),
      getChatRepos(isGroup: true),
    ]);
  }
}