import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_images.dart';
import '../controller/notifications_controller.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          GetBuilder<NotificationsController>(
            builder: (controller) {
              if (controller.unreadCount > 0) {
                return TextButton(
                  onPressed: () => controller.markAllAsRead(),
                  child: const Text("Mark all as read", style: TextStyle(color: AppColors.primaryColor)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: GetBuilder<NotificationsController>(
        // ✅ Ensure controller is available and data is loaded when screen opens
        init: Get.isRegistered<NotificationsController>() ? null : NotificationsController(),
        builder: (controller) {
          
          // Show loader if it's the very first load
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show empty state if no notifications
          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.emptyNotification, width: 200),
                  const SizedBox(height: 20),
                  const Text("No notifications yet", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.page = 0;
              controller.hasNoData = false;
              controller.notifications.clear();
              await controller.getNotifications();
            },
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: controller.notifications.length + (controller.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = controller.notifications[index];

                return NotificationItem(
                  item: item,
                  onTap: () => controller.markAsRead(index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
