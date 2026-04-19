import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/profile/data/declaimer_response.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../utils/app_utils.dart';

class TermsOfServicesController extends GetxController {
  RxBool isLoading = true.obs;
  RxString termsAndConditionHtmlContent = ''.obs;
  RxString privacyPolicyHtmlContent = ''.obs;

  static TermsOfServicesController get instance =>
      Get.put(TermsOfServicesController());

  @override
  void onInit() {
    super.onInit();
    loadTerms();
    loadPrivacy();
  }

  Future<void> loadTerms() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiEndPoint.termsOfServices);

      if (response.statusCode == 200 && response.data['data'] != null) {
        final model = DisclaimerResponse.fromJson(response.data['data']);
        termsAndConditionHtmlContent.value = model.content;
      }
    } catch (e) {
      Utils.errorSnackBar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPrivacy() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get(ApiEndPoint.privacyPolicies);

      if (response.statusCode == 200 && response.data['data'] != null) {
        final model = DisclaimerResponse.fromJson(response.data['data']);
        privacyPolicyHtmlContent.value = model.content;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
