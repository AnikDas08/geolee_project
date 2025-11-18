import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/app_utils.dart';
import '../../data/model/notification_model.dart';
import '../../repository/notification_repository.dart';

class NotificationsController extends GetxController {
  /// Notification List
  List notifications = [];

  /// Notification Loading Bar
  bool isLoading = false;

  /// Notification more Data Loading Bar
  bool isLoadingMore = false;

  /// No more notification data
  bool hasNoData = false;

  /// page no here
  int page = 0;

  /// Notification Repository Instance
  NotificationRepository notificationRepository = NotificationRepository();

  /// Notification Scroll Controller
  ScrollController scrollController = ScrollController();

  /// Notification More data Loading function

  // Initialize and fetch notifications
  @override
  void onInit() {
    super.onInit();
    getNotificationsRepo();
    moreNotification();
  }

  void moreNotification() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (isLoadingMore || hasNoData) return;
        isLoadingMore = true;
        update();
        page++;
        List<NotificationModel> list = await notificationRepository
            .notificationRepository(page);
        if (list.isEmpty) {
          hasNoData = true;
        } else {
          notifications.addAll(list);
        }
        isLoadingMore = false;
        update();
      }
    });
  }

  /// Notification data Loading function
  getNotificationsRepo() async {
    if (isLoading || hasNoData) return;
    isLoading = true;
    update();

    page++;
    List<NotificationModel> list = await notificationRepository
        .notificationRepository(page);
    if (list.isEmpty) {
      hasNoData = true;
    } else {
      notifications.addAll(list);
    }
    isLoading = false;
    update();
  }

  /// Notification Read function
  readNotification(NotificationModel item) async {
    isLoading = true;
    update();

    var result = await notificationRepository.getCustomOffer(
      item.referenceId ?? "",
    );
    result.fold(
      ifLeft: (error) {
        // Handle error - could show a snackbar or dialog
        debugPrint('Error fetching custom offer: $error');
      },
      ifRight: (customOffer) {
        if (customOffer.data != null) {
        }
      },
    );
    isLoading = false;
    update();
  }

  /// Notification Accept function
  acceptCustomOffer(String id) async {
    isLoading = true;
    update();

    var result = await notificationRepository.acceptCustomOffer(id);
    result.fold(
      ifLeft: (error) {
        Get.back();
        debugPrint('Error fetching custom offer: $error');
        Get.snackbar(
          "Error",
          "Error fetching custom offer $error",
          snackPosition: SnackPosition.TOP,
        );
      },
      ifRight: (offerAccept) {
        Get.back();
        debugPrint('Custom offer accepted: ${offerAccept.data}');
        Get.snackbar(
          "Success",
          "Custom offer accepted successfully",
          snackPosition: SnackPosition.TOP,
        );
      },
    );
    isLoading = false;
    update();
  }

  /// Notification Reject function
  rejectCustomOffer(String id) async {
    isLoading = true;
    update();

    var result = await notificationRepository.rejectCustomOffer(id);
    result.fold(
      ifLeft: (error) {
        Get.back();
        debugPrint('Error fetching custom offer: $error');
        Get.snackbar(
          "Error",
          "Error fetching custom offer $error",
          snackPosition: SnackPosition.TOP,
        );
      },
      ifRight: (offerAccept) {
        Get.back();
        debugPrint('Custom offer rejected: ${offerAccept.data}');
        Get.snackbar(
          "Success",
          "Custom offer rejected successfully",
          snackPosition: SnackPosition.TOP,
        );
      },
    );
    isLoading = false;
    update();
  }

  // payment
  Future<void> getPaymentSession(String serviceId) async {
    try {
      isLoading = true;
      update();

      var result = await notificationRepository.getCheckoutSession(serviceId);

      result.fold(
        ifLeft: (error) {
          Utils.errorSnackBar("Error", error);
        },
        ifRight: (checkoutSession) async {
          final result = await Get.toNamed(
            AppRoutes.stripeWebViewScreen,
            arguments: checkoutSession.data.checkoutUrl,
          );
          if (result == 'success') {
            Get.offAllNamed(AppRoutes.homeNav);
          }
          if (result == 'failed') {
            Utils.errorSnackBar("Error", "Payment failed. Please try again.");
          }
          if (result == 'cancelled') {
            Utils.errorSnackBar(
              "Error",
              "Payment cancelled. Please try again.",
            );
          }
        },
      );
    } catch (e) {
      Utils.errorSnackBar(
        "Error",
        "An error occurred while creating the checkout session. Please try again.",
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Notification Controller Instance create here
  static NotificationsController get instance =>
      Get.put(NotificationsController());
}
