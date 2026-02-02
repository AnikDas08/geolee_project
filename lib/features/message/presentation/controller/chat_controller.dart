import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/chat_list_model.dart';
import '../../repository/chat_repository.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/enum/enum.dart';

class ChatController extends GetxController {
  /// Chat List here
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
  String searchQuery = '';

  /// Chat Controller Instance create here
  static ChatController get instance => Get.put(ChatController());

  /// Search function
  void searchChats(String query) {
    searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      filteredChats = chats;
    } else {
      filteredChats = chats.where((chat) {
        final nameLower = chat.participant.fullName.toLowerCase();
        final messageLower = chat.latestMessage.text.toLowerCase();
        return nameLower.contains(searchQuery) ||
            messageLower.contains(searchQuery);
      }).toList();
    }

    update();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    filteredChats = chats;
    update();
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
        List<ChatModel> list = await chatRepository(page);
        if (list.isEmpty) {
          hasNoData = true;
        } else {
          chats.addAll(list);
          if (searchQuery.isEmpty) {
            filteredChats = chats;
          } else {
            searchChats(searchQuery);
          }
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
    List<ChatModel> list = await chatRepository(page);
    if (list.isEmpty) {
      hasNoData = true;
    } else {
      chats.addAll(list);
      filteredChats = chats;
    }
    isLoading = false;
    update();
  }

  /// Api status check here
  Status get status {
    if (isLoading && chats.isEmpty) return Status.loading;
    if (filteredChats.isEmpty && hasNoData && searchQuery.isEmpty) return Status.error;
    return Status.completed;
  }

  /// Chat data Update Socket listener
  listenChat() async {
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
    final index = chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      chats[index] = ChatModel(
        id: chats[index].id,
        participant: chats[index].participant,
        status: chats[index].status,
        latestMessage: chats[index].latestMessage,
        unreadCount: 0,
        isSeen: true,
      );

      // Update filtered list as well
      if (searchQuery.isEmpty) {
        filteredChats = chats;
      } else {
        searchChats(searchQuery);
      }

      update();
    }
  }

  /// Chat data Loading function (demo/mock data)
  Future<void> getChatRepo() async {
    if (isLoading || hasNoData) return;
    isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 300));

    chats = [
      // Unseen message with unread count
      ChatModel(
        id: '1',
        participant: Participant(
          id: 'u1',
          fullName: 'Alex Linderson',
          image:
          'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
          skill: const ['Cleaning', 'Moving'],
        ),
        status: true,
        latestMessage: LatestMessage(
          id: 'm1',
          sender: 'u1',
          text: 'How Are You Today?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        unreadCount: 3,
        isSeen: false,
      ),

      // Seen message (white background)
      ChatModel(
        id: '2',
        participant: Participant(
          id: 'u2',
          fullName: 'Jenny Wilson',
          image:
          'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
          skill: const ['Plumbing'],
        ),
        status: false,
        latestMessage: LatestMessage(
          id: 'm2',
          sender: 'u2',
          text: 'Hey! Can You Join The Meeting?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        unreadCount: 0,
        isSeen: true,
      ),

      // Unseen message with unread count
      ChatModel(
        id: '3',
        participant: Participant(
          id: 'u3',
          fullName: 'Darrell Steward',
          image:
          'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
          skill: const ['Electrician'],
        ),
        status: false,
        latestMessage: LatestMessage(
          id: 'm3',
          sender: 'u3',
          text: 'Hey! Can You Join The Meeting?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        unreadCount: 2,
        isSeen: false,
      ),

      // Unseen message without unread count
      ChatModel(
        id: '4',
        participant: Participant(
          id: 'u4',
          fullName: 'Ralph Edwards',
          image:
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
          skill: const ['Painting'],
        ),
        status: true,
        latestMessage: LatestMessage(
          id: 'm4',
          sender: 'u4',
          text: 'Hey! Can You Join The Meeting?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        unreadCount: 1,
        isSeen: false,
      ),

      // Seen message (white background)
      ChatModel(
        id: '5',
        participant: Participant(
          id: 'u5',
          fullName: 'Courtney Henry',
          image:
          'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg',
          skill: const ['Gardening'],
        ),
        status: false,
        latestMessage: LatestMessage(
          id: 'm5',
          sender: 'u5',
          text: 'Hey! Can You Join The Meeting?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        unreadCount: 0,
        isSeen: true,
      ),
    ];

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