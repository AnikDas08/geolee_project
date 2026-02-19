import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/ads/presentation/screen/create_ads_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';

class StripePaymentWebViewScreen extends StatelessWidget {
  final String checkoutUrl;
  const StripePaymentWebViewScreen({super.key, required this.checkoutUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller:
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request) {
                  if (request.url.contains("success")) {
                    Get.offAllNamed(AppRoutes.homeNav);
                    Get.snackbar(
                      AppString.successful,
                      AppString.payment_successful,
                      backgroundColor: AppColors.success,
                      colorText: AppColors.white,
                    );
                    return NavigationDecision.prevent;
                  } else if (request.url.contains("cancel")) {

                    // Get.toNamed(AppRoutes.homeNav);

                    Get.to(() => const CreateAdsScreen());
                    Get.snackbar(
                      AppString.cancel,
                      AppString.payment_cancel,
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
                    Get.offAllNamed(AppRoutes.homeNav);
                  } else if (url.contains("cancel")) {
                    Get.to(() => const CreateAdsScreen());
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
