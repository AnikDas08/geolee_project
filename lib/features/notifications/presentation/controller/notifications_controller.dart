import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';

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
    if (LocalStorage.token.isNotEmpty) {
      getNotifications();
    }
    moreNotification();
  }

  /// First Load
  Future<void> getNotifications() async {
    if (isLoading || hasNoData) return;

    isLoading = true;
    update();

    page++;
    try {
      final response = await repository.getNotifications(page);

      if (response.notifications.isEmpty) {
        hasNoData = true;
      } else {
        notifications.addAll(response.notifications);
        unreadCount = response.unreadCount;
      }
    } catch (e) {
      debugPrint('Failed to get notifications: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Pagination
  void moreNotification() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (isLoadingMore || hasNoData) return;

        isLoadingMore = true;
        update();

        page++;
        try {
          final response = await repository.getNotifications(page);

          if (response.notifications.isEmpty) {
            hasNoData = true;
          } else {
            notifications.addAll(response.notifications);
            unreadCount = response.unreadCount;
          }
        } catch (e) {
          debugPrint('Failed to load more notifications: $e');
        } finally {
          isLoadingMore = false;
          update();
        }
      }
    });
  }

  /// Mark single notification as read
  Future<void> markAsRead(int index) async {
    final notification = notifications[index];

    if (notification.read) return;

    notifications[index] = notification.copyWith(read: true);
    if (unreadCount > 0) unreadCount--;
    update();

    // ✅ Pass the notification id
    final success = await repository.markNotificationAsRead(notification.id);

    if (!success) {
      notifications[index] = notification.copyWith(read: false);
      if (unreadCount < notifications.length) unreadCount++;
      update();
    }
  }

  /// Mark ALL notifications as read
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    final previous = List<NotificationModel>.from(notifications);
    final previousUnread = unreadCount;

    notifications = notifications.map((n) => n.copyWith(read: true)).toList();
    unreadCount = 0;
    update();

    // ✅ No argument needed
    final success = await repository.markAllNotificationsAsRead();

    if (!success) {
      notifications = previous;
      unreadCount = previousUnread;
      update();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
