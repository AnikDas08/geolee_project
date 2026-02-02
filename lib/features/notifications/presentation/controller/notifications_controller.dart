import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/notification_model.dart';
import '../../repository/notification_repository.dart';
class NotificationsController extends GetxController {
  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNoData = false;

  int page = 0;

  final ScrollController scrollController = ScrollController();
  final NotificationRepository repository = NotificationRepository();

  @override
  void onInit() {
    super.onInit();
    getNotifications();
    moreNotification();
  }

  /// First Load
  Future<void> getNotifications() async {
    if (isLoading || hasNoData) return;

    isLoading = true;
    update();

    page++;

    final response = await repository.getNotifications(page);

    if (response.notifications.isEmpty) {
      hasNoData = false;
      update();
    } else {
      notifications.addAll(response.notifications);
      update();
    }

    unreadCount = response.unreadCount;

    isLoading = false;
    update();
  }

  /// Pagination
  void moreNotification() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (isLoadingMore || hasNoData) return;

        isLoadingMore = true;
        update();

        page++;

        final response = await repository.getNotifications(page);

        if (response.notifications.isEmpty) {
          hasNoData = true;
        } else {
          notifications.addAll(response.notifications);
        }

        unreadCount = response.unreadCount;

        isLoadingMore = false;
        update();
      }
    });
  }

  /// Mark as Read (local)
  void markAsRead(int index) {
    notifications[index] =
        NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          read: true,
          createdAt: notifications[index].createdAt,
        );

    if (unreadCount > 0) unreadCount--;
    update();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
