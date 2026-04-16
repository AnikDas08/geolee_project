import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/home/presentation/screen/home_nav_screen.dart';
import 'package:giolee78/utils/constants/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewPage extends StatefulWidget {
  final String checkoutUrl;
  const StripeWebViewPage({super.key, required this.checkoutUrl});

  @override
  State<StripeWebViewPage> createState() => _StripeWebViewPageState();
}

class _StripeWebViewPageState extends State<StripeWebViewPage> {
  late final WebViewController _webController;
  bool _isLoading = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            debugPrint("NAV REQUEST: ${request.url}");
            _handleUrl(request.url);

            if (request.url.contains("success") ||
                request.url.contains("succeeded") ||
                request.url.contains("cancel") ||
                request.url.contains("cancelled")) {

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            debugPrint("PAGE STARTED: $url");
            _handleUrl(url);
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint("PAGE FINISHED: $url");
            _handleUrl(url);
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint("WEB ERROR: ${error.description}");
            if (mounted) setState(() => _isLoading = false);
            //====================================================
            if (error.isForMainFrame ?? false) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar(
                  "Error",
                  "Failed to load page",
                  backgroundColor: AppColors.cancel,
                  colorText: AppColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleUrl(String url) {
    if (_hasNavigated) return;

    debugPrint("🔍 Checking URL: $url");

    final isSuccess = url.contains("success") ||           // localhost:3000/payment/success
        url.contains("succeeded") ||                        // payment_attempt_state=succeeded
        url.contains("checkout-success") ||                 // common stripe pattern
        url.contains("payment-complete") ||
        url.contains("payment_attempt_state=succeeded");   // explicit check

    final isCancel = url.contains("cancel") ||
        url.contains("cancelled") ||
        url.contains("failure") ||
        url.contains("failed") ||
        url.contains("canceled");

    if (isSuccess) {
      _hasNavigated = true;
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
    } else if (isCancel) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back(); // Go back to the existing CreateAdsScreen instead of creating a new one and clearing stack
        Get.snackbar(
          "Cancel",
          "Payment cancelled",
          backgroundColor: AppColors.cancel,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _webController),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            // Fallback Done/Close Button
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Get.back(),
                child: const Text("Done / Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}