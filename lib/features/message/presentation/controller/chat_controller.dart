import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/log/app_log.dart';
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
  bool isLoadingMoreSingle = false;
  bool hasNoData = false;
  bool hasNoSingleData = false;
  int page = 0;
  int singlePage = 0;

  int _groupTotalPages = 1;
  int _singleTotalPages = 1;
  bool get hasMoreGroups => page < _groupTotalPages;
  bool get hasMoreSingles => singlePage < _singleTotalPages;

  ScrollController scrollController = ScrollController();
  ScrollController singleScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  Timer? _searchDebounce; // Added for server-side search timing

  static ChatController get instance => Get.put(ChatController());

  void clearSearch() {
    searchController.clear();
    // Refresh data from server without search term
    getChatRepos(isGroup: false);
    getChatRepos(isGroup: true);
    update();
  }

  void _sortChats() {
    singleChats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // UPDATED: Now calls the server instead of filtering locally
  void searchChats(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    // Small delay to wait for user to stop typing
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      // Re-fetch data from server using the search query
      getChatRepos(isGroup: false, showLoading: true);
      getChatRepos(isGroup: true, showLoading: true);
    });

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
    if (isLoadingMore || !hasMoreGroups) return;
    isLoadingMore = true;
    update();

    try {
      page++;
      final response = await chatRepository(
        page,
        searchController.text.trim(),
        true,
      );

      _groupTotalPages = response.totalPage;
      final allGroups = response.data.where((item) => item.isGroup).toList();
      chats.addAll(allGroups);
      _sortChats();
      filteredChats = List.from(chats);
    } catch (e) {
      page--;
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  Future<void> _loadMoreSingles() async {
    if (isLoadingMoreSingle || !hasMoreSingles) return;
    isLoadingMoreSingle = true;
    update();

    try {
      singlePage++;
      final response = await chatRepository(
        singlePage,
        searchController.text.trim(),
        false,
      );

      _singleTotalPages = response.totalPage;
      final singles = response.data.where((item) => !item.isGroup).toList();
      singleChats.addAll(singles);
      _sortChats();
      filteredSingleChats = List.from(singleChats);
      await _markFriendStatusForList(singles);
    } catch (e) {
      singlePage--;
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
        searchController.text.trim(), // Use actual search controller text
        isGroup,
      );

      if (isGroup) {
        chats.clear();
        _groupTotalPages = response.totalPage;
        final allGroups = response.data.where((item) => item.isGroup).toList();
        chats.addAll(allGroups);
        _sortChats();
        filteredChats = List.from(chats);
      } else {
        singleChats.clear();
        _singleTotalPages = response.totalPage;
        singleChats.addAll(response.data.where((item) => !item.isGroup).toList());
        _sortChats();
        filteredSingleChats = List.from(singleChats);
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

  Future<void> _markFriendStatus() async {
    await _markFriendStatusForList(singleChats);
  }

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
            filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(isFriend: isFriend);
          }
        }
      } catch (_) {}
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
      page = 1;
      singlePage = 1;
      chats.clear();
      singleChats.clear();
      for (var item in data) {
        try {
          final chat = ChatModel.fromJson(item);
          if (chat.isGroup) chats.add(chat); else singleChats.add(chat);
        } catch (e) {}
      }
      _sortChats();
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
      if (fIndex != -1) filteredSingleChats[fIndex] = filteredSingleChats[fIndex].copyWith(unreadCount: 0);
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
    setupSinglePagination();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel(); // Cancel timer on close
    singleScrollController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      getChatRepos(),
      getChatRepos(isGroup: true),
    ]);
  }
}