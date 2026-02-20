import 'package:get/get.dart';
import 'controller/notifications_controller.dart';

/// ✅ Use this binding when navigating to NotificationScreen
/// so the controller is properly registered and disposed.
///
/// Usage:
///   Get.to(() => NotificationScreen(), binding: NotificationBinding());
///
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}