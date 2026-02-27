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
  List<ChatModel> filteredSingleChats = [];

  bool isSingleLoading = false;
  bool isGroupLoading = false;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoadingMoreSingle = false; // ✅
  bool hasNoData = false;
  bool hasNoSingleData = false; // ✅
  int page = 0;
  int singlePage = 0; // ✅

  // ✅ Pagination tracking
  int _groupTotalPages = 1;
  int _singleTotalPages = 1;
  bool get hasMoreGroups => page < _groupTotalPages;
  bool get hasMoreSingles => singlePage < _singleTotalPages;

  ScrollController scrollController = ScrollController();
  ScrollController singleScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  static ChatController get instance => Get.put(ChatController());

  void clearSearch() {
    searchController.clear();
    filteredChats = List.from(chats);
    filteredSingleChats = List.from(singleChats);
    update();
  }

  void searchChats(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredChats = List.from(chats);
      filteredSingleChats = List.from(singleChats);
    } else {
      filteredSingleChats = singleChats.where((chat) {
        final name = chat.participant.fullName.toLowerCase();
        final email = chat.participant.email.toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();

      filteredChats = chats.where((chat) {
        final groupName = (chat.chatName ?? '').toLowerCase();
        return groupName.contains(q);
      }).toList();
    }

    update();
  }

  void setupGroupPagination() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (isLoadingMore || !hasMoreGroups) return;
        await _loadMoreGroups();
      }
    });
  }

  // ✅ Single chat pagination
  void setupSinglePagination() {
    singleScrollController.addListener(() async {
      if (singleScrollController.position.pixels >=
          singleScrollController.position.maxScrollExtent - 200) {
        if (isLoadingMoreSingle || !hasMoreSingles) return;
        await _loadMoreSingles();
      }
    });
  }

  Future<void> _loadMoreGroups() async {
    if (isLoadingMore || !hasMoreGroups) {
      debugPrint("⏸️ _loadMoreGroups skipped: isLoading=$isLoadingMore, hasMore=$hasMoreGroups");
      return;
    }
    isLoadingMore = true;
    update();

    try {
      page++;
      debugPrint("📄 Loading groups page: $page (total pages available: $_groupTotalPages)");

      final response = await chatRepository(
        page,
        searchController.text.trim(),
        true,
      );

      _groupTotalPages = response.totalPage;
      debugPrint("📊 Updated _groupTotalPages to: $_groupTotalPages");

      final allGroups = response.data.where((item) => item.isGroup).toList();
      debugPrint("➕ Adding ${allGroups.length} groups to existing ${chats.length}");
      chats.addAll(allGroups);

      if (searchController.text.trim().isEmpty) {
        filteredChats = List.from(chats);
      } else {
        searchChats(searchController.text.trim());
      }
      debugPrint("✅ _loadMoreGroups completed. Total chats: ${chats.length}");
    } catch (e) {
      print("❌ loadMoreGroups Error: $e");
      page--; // Revert page on error
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  Future<void> _loadMoreSingles() async {
    if (isLoadingMoreSingle || !hasMoreSingles) {
      debugPrint("⏸️ _loadMoreSingles skipped: isLoading=$isLoadingMoreSingle, hasMore=$hasMoreSingles");
      return;
    }
    isLoadingMoreSingle = true;
    update();

    try {
      singlePage++;
      debugPrint("📄 Loading singles page: $singlePage (total pages available: $_singleTotalPages)");

      final response = await chatRepository(
        singlePage,
        searchController.text.trim(),
        false,
      );

      _singleTotalPages = response.totalPage;
      debugPrint("📊 Updated _singleTotalPages to: $_singleTotalPages");

      final singles = response.data.where((item) => !item.isGroup).toList();
      debugPrint("➕ Adding ${singles.length} singles to existing ${singleChats.length}");
      singleChats.addAll(singles);

      if (searchController.text.trim().isEmpty) {
        filteredSingleChats = List.from(singleChats);
      } else {
        searchChats(searchController.text.trim());
      }

      await _markFriendStatusForList(singles);
      debugPrint("✅ _loadMoreSingles completed. Total singles: ${singleChats.length}");
    } catch (e) {
      print("❌ loadMoreSingles Error: $e");
      singlePage--; // Revert page on error
    } finally {
      isLoadingMoreSingle = false;
      update();
    }
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

      if (isGroup) {
        page = 1;
      } else {
        singlePage = 1;
      }

      final response = await chatRepository(
        isGroup ? page : singlePage,
        '',
        isGroup,
      );

      if (isGroup) {
        chats.clear();
        _groupTotalPages = response.totalPage;
        debugPrint("📊 Groups: totalPage=$_groupTotalPages, received=${response.data.length}");

        final allGroups = response.data.where((item) => item.isGroup).toList();
        chats.addAll(allGroups);
        filteredChats = List.from(chats);
      } else {
        singleChats.clear();
        _singleTotalPages = response.totalPage;
        debugPrint("📊 Singles: totalPage=$_singleTotalPages, received=${response.data.length}");

        singleChats.addAll(response.data.where((item) => !item.isGroup).toList());
        filteredSingleChats = List.from(singleChats);
        await _markFriendStatus();
      }

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
    await _markFriendStatusForList(singleChats);
  }

  // ✅ Reusable — specific list এর জন্য
  Future<void> _markFriendStatusForList(List<ChatModel> targetList) async {
    if (targetList.isEmpty) return;

    final List<Future> checks = targetList.map((chat) async {
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
          final fIndex = filteredSingleChats.indexWhere((c) => c.id == chat.id);
          if (fIndex != -1) {
            filteredSingleChats[fIndex] =
                filteredSingleChats[fIndex].copyWith(isFriend: isFriend);
          }
        }
      } catch (_) {
        final index = singleChats.indexWhere((c) => c.id == chat.id);
        if (index != -1) {
          singleChats[index] = singleChats[index].copyWith(isFriend: false);
          final fIndex = filteredSingleChats.indexWhere((c) => c.id == chat.id);
          if (fIndex != -1) {
            filteredSingleChats[fIndex] =
                filteredSingleChats[fIndex].copyWith(isFriend: false);
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
      singlePage = 0;
      chats.clear();
      singleChats.clear();
      filteredChats.clear();
      filteredSingleChats.clear();
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
      filteredSingleChats = List.from(singleChats);
      update();
      _markFriendStatus();
    });
  }

  void markChatAsSeen(String chatId) {
    int index = singleChats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      singleChats[index] = singleChats[index].copyWith(unreadCount: 0);
      final fIndex = filteredSingleChats.indexWhere((c) => c.id == chatId);
      if (fIndex != -1) {
        filteredSingleChats[fIndex] =
            filteredSingleChats[fIndex].copyWith(unreadCount: 0);
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
    setupGroupPagination();
    setupSinglePagination(); // ✅
  }

  @override
  void onClose() {
    singleScrollController.dispose(); // ✅
    super.onClose();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      getChatRepos(),
      getChatRepos(isGroup: true),
    ]);
  }
}