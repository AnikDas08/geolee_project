import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/log/app_log.dart';
import '../../data/model/chat_list_model.dart';
import '../../repository/chat_repository.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/enum/enum.dart';

class ChatController extends GetxController {
  /// Chat List here
  List<ChatModel> singleChats = [];
  List<ChatModel> chats = [];
  List<ChatModel> filteredChats = []; // For search results

  /// Chat Loading Bar
  bool isLoading = false;

  /// Chat more Data Loading Bar
  bool isLoadingMore = false;

  /// No more chat data
  bool hasNoData = false;

  /// page no here
  int page = 0;

  /// Chat Scroll Controller
  ScrollController scrollController = ScrollController();

  /// Search Controller
  TextEditingController searchController = TextEditingController();

  /// Chat Controller Instance create here
  static ChatController get instance => Get.put(ChatController());

  /// Clear search
  void clearSearch() {
    searchController.clear();
    filteredChats = chats;
    update();
  }

  void searchChats(v) {
    getChatRepos(showLoading: false);
  }

  /// Chat More data Loading function
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
        );

        singleChats.addAll(list);

        isLoadingMore = false;
        update();
      }
    });
  }

  /// Chat data Loading function
  Future<void> getChatRepos({bool showLoading = true}) async {
    appLog('naimul');
    if (showLoading) {
      isLoading = true;
      update();
    }
    page++;
    if (!showLoading) {
      page = 1;
    }
    final List<ChatModel> list = await chatRepository(
      page,
      searchController.text.trim(),
    );

    if (!showLoading) {
      singleChats.clear();
    }

    singleChats.addAll(list);

    isLoading = false;
    update();
  }

  /// Api status check here
  Status get status {
    if (isLoading && chats.isEmpty) return Status.loading;
    if (filteredChats.isEmpty && hasNoData) return Status.error;
    return Status.completed;
  }

  /// Chat data Update Socket listener
  Future<void> listenChat() async {
    // Listen for chat list updates (using identified event name from images if applicable)
    SocketServices.on("chat:update", (data) {
      getChatRepos(showLoading: false);
    });

    SocketServices.on("update-chatlist::${LocalStorage.userId}", (data) {
      page = 0;
      chats.clear();
      filteredChats.clear();
      hasNoData = false;

      for (var item in data) {
        chats.add(ChatModel.fromJson(item));
      }

      filteredChats = chats;
      update();
    });
  }

  /// Mark chat as read/seen
  void markChatAsSeen(String chatId) {
    final index = singleChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      singleChats[index] = ChatModel(
        id: chats[index].id,
        participant: chats[index].participant,
        latestMessage: chats[index].latestMessage,
        unreadCount: chats[index].unreadCount,
        isDeleted: chats[index].isDeleted,
        createdAt: chats[index].createdAt,
        updatedAt: chats[index].updatedAt,
        isOnline: chats[index].isOnline,
      );

      update();
    }
  }

  /// Chat data Loading function (demo/mock data)
  Future<void> getChatRepo() async {
    if (isLoading || hasNoData) return;
    isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 300));

    filteredChats = chats;
    isLoading = false;
    hasNoData = chats.isEmpty;
    update();
  }

  /// Controller on Init
  @override
  void onInit() {
    super.onInit();

    /// Initial data load using real repository
    getChatRepos();

    /// Start listening for real-time updates
    listenChat();
  }

  @override
  void onClose() {
    // searchController.dispose();
    // scrollController.dispose();
    super.onClose();
  }
}
