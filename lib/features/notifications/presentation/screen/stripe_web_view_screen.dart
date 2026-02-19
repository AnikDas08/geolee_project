import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/home/presentation/screen/home_nav_screen.dart';
import 'package:giolee78/features/notifications/presentation/screen/notifications_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewPage extends StatelessWidget {
  final String checkoutUrl;
  const StripeWebViewPage({super.key, required this.checkoutUrl});

  @override
  Widget build(BuildContext context) {
    final webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains("success")) {
              // ✅ Navigate after build completes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAll(() => HomeNav());
                Get.snackbar(
                  "Success",
                  "Payment successful",
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              });
              return NavigationDecision.prevent;
            } else if (request.url.contains("cancel")) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAll(() => const NotificationScreen());
                Get.snackbar(
                  "Cancel",
                  "Payment cancelled",
                  backgroundColor: AppColors.cancel,
                  colorText: AppColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {},
          onPageFinished: (url) {
            if (url.contains("success")) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAll(() => HomeNav());
              });
            } else if (url.contains("cancel")) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAll(() => const NotificationScreen());
              });
            }
          },
          onWebResourceError: (error) {
            // Optional: show error snackbar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar(
                "Error",
                "Failed to load page",
                backgroundColor: AppColors.cancel,
                colorText: AppColors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));

    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: webController),
      ),
    );
  }
}
