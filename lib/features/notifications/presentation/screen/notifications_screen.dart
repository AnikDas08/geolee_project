import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/notifications/presentation/widgets/notification_item.dart';
import '../controller/notifications_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
      ),

      /// Body Section starts here
      body: GetBuilder<NotificationsController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                return NotificationItem(
                  item: controller.notifications[index],
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
