import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import '../../data/model/notification_model.dart';
import '../../repository/notification_repository.dart';

class NotificationsController extends GetxController {
  List<NotificationModel> notifications = [];
  RxInt unreadCount = 0.obs; // ✅ Rx — AppBar badge realtime update হবে

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNoData = false;

  int page = 0;

  final ScrollController scrollController = ScrollController();
  final NotificationRepository repository = NotificationRepository();

  // ✅ Polling timer — 30 সেকেন্ড পর পর নতুন notification check
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    if (LocalStorage.token != "") {
      _initialLoad();
      _startPolling(); // ✅ realtime polling শুরু
    }
    _setupScrollListener();
  }

  // ✅ প্রথমবার load — page reset করে
  Future<void> _initialLoad() async {
    page = 0;
    hasNoData = false;
    notifications.clear();
    await _fetchNotifications(isFirst: true);
  }

  // ✅ Polling — 30s পর পর unread count ও নতুন notification check
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkNewNotifications();
    });
  }

  Future<void> _checkNewNotifications() async {
    try {
      final response = await repository.getNotifications(1);

      if (response.notifications.isEmpty) return;

      // নতুন notification আছে কিনা check
      final existingIds = notifications.map((n) => n.id).toSet();
      final newItems = response.notifications
          .where((n) => !existingIds.contains(n.id))
          .toList();

      if (newItems.isNotEmpty) {
        notifications.insertAll(0, newItems); // ✅ সামনে যোগ করো
        unreadCount.value = response.unreadCount;
        update();
        debugPrint("🔔 ${newItems.length} new notification(s) found");
      } else {
        // নতুন item না থাকলেও unread count update করো
        unreadCount.value = response.unreadCount;
      }
    } catch (e) {
      debugPrint("Polling error: $e");
    }
  }

  // ✅ Core fetch method
  Future<void> _fetchNotifications({bool isFirst = false}) async {
    if (isFirst) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }
    update();

    page++;

    try {
      final response = await repository.getNotifications(page);

      if (response.notifications.isEmpty) {
        hasNoData = true;
      } else {
        notifications.addAll(response.notifications);
      }

      unreadCount.value = response.unreadCount; // ✅ Rx update
    } catch (e) {
      debugPrint("Fetch notification error: $e");
    } finally {
      isLoading = false;
      isLoadingMore = false;
      update();
    }
  }

  // ✅ Pull to refresh
  Future<void> refresh() async {
    await _initialLoad();
  }

  // ✅ Scroll listener — pagination
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        if (!isLoadingMore && !hasNoData && !isLoading) {
          _fetchNotifications();
        }
      }
    });
  }

  // ✅ Mark as Read — API call + local update
  Future<void> markAsRead(int index) async {
    final notification = notifications[index];

    // আগেই read থাকলে skip
    if (notification.read) return;

    // ✅ Optimistic UI — আগে local update করো
    notifications[index] = notification.copyWith(read: true);
    if (unreadCount.value > 0) unreadCount.value--;
    update();

    // ✅ API call — server এ mark as read
    try {
      await repository.markAsRead(notification.id);
      debugPrint("✅ Marked as read: ${notification.id}");
    } catch (e) {
      // ❌ API fail হলে revert করো
      debugPrint("❌ markAsRead API error: $e");
      notifications[index] = notification.copyWith(read: false);
      unreadCount.value++;
      update();
    }
  }

  // ✅ Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      notifications = notifications.map((n) => n.copyWith(read: true)).toList();
      unreadCount.value = 0;
      update();
    } catch (e) {
      debugPrint("markAllAsRead error: $e");
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel(); // ✅ memory leak বন্ধ
    scrollController.dispose();
    super.onClose();
  }
}