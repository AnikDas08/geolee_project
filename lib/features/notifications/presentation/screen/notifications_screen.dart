import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/app_images.dart';
import '../controller/notifications_controller.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: GetBuilder<NotificationsController>(
        init: NotificationsController(), // controller init
        builder: (controller) {

          /// First loading
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// No notifications
          if (controller.notifications.isEmpty) {
            return Center(
              child: Image.asset(AppImages.emptyNotification),
            );
          }

          return ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: controller.notifications.length +
                (controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {

              /// Bottom loader
              if (index == controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final item = controller.notifications[index];

              return NotificationItem(

                item: item,
                onTap: () {
                  controller.markAsRead(index);

                  /// Navigation example
                  // Get.toNamed(AppRoutes.notificationDetails, arguments: item);
                },
              );
            },
          );
        },
      ),
    );
  }
}
