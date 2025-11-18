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

  /// Chat Controller Instance create here
  static ChatController get instance => Get.put(ChatController());

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
    }
    isLoading = false;
    update();
  }

  /// Api status check here
  Status get status {
    if (isLoading && chats.isEmpty) return Status.loading;
    if (chats.isEmpty && hasNoData) return Status.error;
    return Status.completed;
  }

  /// Chat data Update  Socket listener
  listenChat() async {
    SocketServices.on("update-chatlist::${LocalStorage.userId}", (data) {
      page = 0;
      chats.clear();
      hasNoData = false;

      for (var item in data) {
        chats.add(ChatModel.fromJson(item));
      }

      update();
    });
  }

  /// Chat data Loading function (demo/mock data)
  Future<void> getChatRepo() async {
    if (isLoading || hasNoData) return;
    isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 300));

    chats = [
      ChatModel(
        id: '1',
        participant: Participant(
          id: 'u1',
          fullName: 'Demo User One',
          image:
              'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
          skill: const ['Cleaning', 'Moving'],
        ),
        status: true,
        latestMessage: LatestMessage(
          id: 'm1',
          sender: 'u1',
          text: 'Hi, I am interested in your service.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ),
      ChatModel(
        id: '2',
        participant: Participant(
          id: 'u2',
          fullName: 'Demo User Two',
          image:
              'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
          skill: const ['Plumbing'],
        ),
        status: false,
        latestMessage: LatestMessage(
          id: 'm2',
          sender: 'u2',
          text: 'When are you available?',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ),
      ChatModel(
        id: '3',
        participant: Participant(
          id: 'u3',
          fullName: 'Demo User Three',
          image:
              'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
          skill: const ['Electrician'],
        ),
        status: true,
        latestMessage: LatestMessage(
          id: 'm3',
          sender: 'u3',
          text: 'Thanks for the quick response!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
    ];

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
}
