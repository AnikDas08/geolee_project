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
  List<ChatModel> chats = []; // all groups (original)
  List<ChatModel> filteredChats = []; // filtered groups
  List<ChatModel> filteredSingleChats = []; // ✅ filtered single chats

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
    filteredChats = List.from(chats);
    filteredSingleChats = List.from(singleChats); // ✅
    update();
  }

  // ✅ Local search — name বা email দিয়ে filter
  void searchChats(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredChats = List.from(chats);
      filteredSingleChats = List.from(singleChats);
    } else {
      // Single chats — participant name বা email দিয়ে filter
      filteredSingleChats = singleChats.where((chat) {
        final name = chat.participant.fullName.toLowerCase();
        final email = chat.participant.email.toLowerCase(); // ✅ email
        return name.contains(q) || email.contains(q);
      }).toList();

      // Group chats — group name দিয়ে filter
      filteredChats = chats.where((chat) {
        final groupName = (chat.chatName ?? '').toLowerCase();
        return groupName.contains(q);
      }).toList();
    }

    update();
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

        final allGroups = list.where((item) => item.isGroup).toList();
        chats.addAll(allGroups);
        filteredChats = List.from(chats);
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
        '', // ✅ API তে search না পাঠিয়ে local filter করব
        isGroup,
      );

      if (isGroup) {
        chats.clear();
        final allGroups = list.where((item) => item.isGroup).toList();
        chats.addAll(allGroups);
        filteredChats = List.from(chats); // ✅
      } else {
        singleChats.clear();
        singleChats.addAll(list.where((item) => !item.isGroup).toList());
        filteredSingleChats = List.from(singleChats); // ✅
        await _markFriendStatus();
      }

      // ✅ Search text থাকলে re-apply filter
      if (searchController.text.trim().isNotEmpty) {
        searchChats(searchController.text.trim());
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

        final index = singleChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          singleChats[index] = singleChats[index].copyWith(isFriend: isFriend);
          // ✅ filteredSingleChats ও update করো
          final fIndex = filteredSingleChats.indexWhere((c) => c.id == chat.id);
          if (fIndex != -1) {
            filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(isFriend: isFriend);
          }
        }
      } catch (_) {
        final index = singleChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          singleChats[index] = singleChats[index].copyWith(isFriend: false);
          final fIndex = filteredSingleChats.indexWhere((c) => c.id == chat.id);
          if (fIndex != -1) {
            filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(isFriend: false);
          }
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
      filteredSingleChats.clear(); // ✅
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

      filteredChats = List.from(chats);
      filteredSingleChats = List.from(singleChats); // ✅
      update();
      _markFriendStatus();
    });
  }

  void markChatAsSeen(String chatId) {
    int index = singleChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      singleChats[index] = singleChats[index].copyWith(unreadCount: 0);
      // ✅ filteredSingleChats ও update
      final fIndex = filteredSingleChats.indexWhere((c) => c.id == chatId);
      if (fIndex != -1) {
        filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(unreadCount: 0);
      }
      update();
      return;
    }

    index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      chats[index] = chats[index].copyWith(unreadCount: 0);
      filteredChats = List.from(chats);
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