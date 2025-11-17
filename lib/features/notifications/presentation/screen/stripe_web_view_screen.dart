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
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request) {
                  if (request.url.contains("success")) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeNav()),
                    );
                    Get.snackbar(
                      "Success",
                      "Payment successful",
                      backgroundColor: AppColors.success,
                      colorText: AppColors.white,
                    );
                    return NavigationDecision.prevent;
                  } else if (request.url.contains("cancel")) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                    Get.snackbar(
                      "Cancel",
                      "Payment cancelled",
                      backgroundColor: AppColors.cancel,
                      colorText: AppColors.white,
                    );
                    return NavigationDecision.navigate;
                  }
                  return NavigationDecision.navigate;
                },
                onPageStarted: (_) {},
                onPageFinished: (url) {
                  if (url.contains("success")) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeNav()),
                    );
                  } else if (url.contains("cancel")) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  }
                },
                onWebResourceError: (error) {},
              ),
            )
            ..loadRequest(Uri.parse(checkoutUrl)),
        ),
      ),
    );
  }
}
