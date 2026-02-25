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

  /// Chat Loading Bars
  bool isSingleLoading = false;
  bool isGroupLoading = false;
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
          true,
        );

        chats.addAll(list.where((item) => item.isGroup).toList());
        filteredChats = chats;
        isLoadingMore = false;
        update();
      }
    });
  }


  /// Chat data Loading function
  Future<void> getChatRepos({
    bool showLoading = true,
    bool isGroup = false,
  }) async {
    print(">>>>>>>>>>>> 🛰️ getChatRepos START: isGroup=$isGroup <<<<<<<<<<<<");
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
        chats.addAll(list.where((item) => item.isGroup).toList());
        filteredChats = chats;
      } else {
        singleChats.clear();
        singleChats.addAll(list.where((item) => !item.isGroup).toList());
      }

      print(
        ">>>>>>>>>>>> ✅ Chat List Loaded for isGroup=$isGroup: Result Count=${list.length}, Single=${singleChats.length}, Group=${chats.length} <<<<<<<<<<<<",
      );
    } catch (e) {
      print(
        ">>>>>>>>>>>> ❌ getChatRepos Error for isGroup=$isGroup: $e <<<<<<<<<<<<",
      );
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

  /// Api status check here
  Status get status {
    if (isGroupLoading && chats.isEmpty) return Status.loading;
    if (filteredChats.isEmpty && hasNoData) return Status.error;
    return Status.completed;
  }

  /// Chat data Update Socket listener
  Future<void> listenChat() async {
    SocketServices.on("chat:update", (data) {
      print(">>>>>>>>>>>> 🔄 Socket Event: chat:update triggered <<<<<<<<<<<<");
      getChatRepos(showLoading: false, isGroup: false);
      getChatRepos(showLoading: false, isGroup: true);
    }, namespace: "/"); // Using root as fallback

    String eventName = "update-chatlist::${LocalStorage.userId}";
    print(
      ">>>>>>>>>>>> 🎧 Listening for Chat List Updates: $eventName <<<<<<<<<<<<",
    );

    SocketServices.on(eventName, (data) {
      print(
        ">>>>>>>>>>>> 📈 Socket Event: $eventName triggered with ${data.length} items <<<<<<<<<<<<",
      );
      page = 0;
      chats.clear();
      singleChats.clear();
      filteredChats.clear();
      hasNoData = false;

      for (var item in data) {
        try {
          final chat = ChatModel.fromJson(item);
          if (chat.isGroup) {
            chats.add(chat);
          } else {
            singleChats.add(chat);
          }
        } catch (e) {
          print(">>>>>>>>>>>> ❌ Socket Data Parsing Error: $e <<<<<<<<<<<<");
        }
      }

      filteredChats = chats;
      update();
    }, namespace: "/"); // Using root as fallback
  }

  /// Mark chat as read/seen
  void markChatAsSeen(String chatId) {
    int index = singleChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final oldChat = singleChats[index];
      singleChats[index] = ChatModel(
        id: oldChat.id,
        isGroup: oldChat.isGroup,
        chatName: oldChat.chatName,
        chatImage: oldChat.chatImage,
        participant: oldChat.participant,
        latestMessage: oldChat.latestMessage,
        unreadCount: 0,
        isDeleted: oldChat.isDeleted,
        createdAt: oldChat.createdAt,
        updatedAt: oldChat.updatedAt,
        isOnline: oldChat.isOnline,
      );
      update();
      return;
    }

    index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      final oldChat = chats[index];
      chats[index] = ChatModel(
        id: oldChat.id,
        isGroup: oldChat.isGroup,
        chatName: oldChat.chatName,
        chatImage: oldChat.chatImage,
        participant: oldChat.participant,
        latestMessage: oldChat.latestMessage,
        unreadCount: 0,
        isDeleted: oldChat.isDeleted,
        createdAt: oldChat.createdAt,
        updatedAt: oldChat.updatedAt,
        isOnline: oldChat.isOnline,
      );
      filteredChats = chats;
      update();
    }
  }

  @override
  void onInit() {
    print(">>>>>>>>>>>> 🚀 ChatController onInit Called <<<<<<<<<<<<");
    super.onInit();
    fetchInitialData();
    listenChat();
  }

  Future<void> fetchInitialData() async {
    Future.wait([
      getChatRepos(isGroup: false),
      getChatRepos(isGroup: true, showLoading: true),
    ]);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
