import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import '../controller/notifications_controller.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Notifications"),
        actions: [
          // ✅ Mark All Read button
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text(
              "Mark all read",
              style: TextStyle(color: Colors.blue),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: GetBuilder<NotificationsController>(
        builder: (controller) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Image.asset(AppImages.emptyNotification),
            );
          }

          // ✅ Pull to refresh
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: controller.notifications.length +
                  (controller.isLoadingMore ? 1 : 0),
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