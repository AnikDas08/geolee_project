import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  void searchChats(v) {}

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
        if (list.isEmpty) {
          hasNoData = true;
        } else {
          singleChats.addAll(list);
        }
        isLoadingMore = false;
        update();
      }
    });
  }

  /// Chat data Loading function
  Future<void> getChatRepos() async {
    if (isLoading || hasNoData) return;
    isLoading = true;
    update();

    page++;
    final List<ChatModel> list = await chatRepository(
      page,
      searchController.text.trim(),
    );
    if (list.isEmpty) {
      hasNoData = true;
    } else {
      singleChats.addAll(list);
      filteredChats = chats;
    }
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
      chats[index] = ChatModel(
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

    /// Load demo chat list data
    getChatRepo();
  }

  @override
  void onClose() {
    // searchController.dispose();
    // scrollController.dispose();
    super.onClose();
  }
}
