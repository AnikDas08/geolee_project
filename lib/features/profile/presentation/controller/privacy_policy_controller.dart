import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/profile/data/model/html_model.dart';

import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';

class PrivacyPolicyController extends GetxController {

  Status status = Status.completed;


  HtmlModel data = HtmlModel.fromJson({});

  static PrivacyPolicyController get instance =>
      Get.put(PrivacyPolicyController());

  getPrivacyPolicyRepo() async {
    status = Status.loading;
    update();

    var response = await ApiService.get(ApiEndPoint.privacyPolicies);

    if (response.statusCode == 200) {
      data = HtmlModel.fromJson(response.data['data']);
      debugPrint(data.toString());

      status = Status.completed;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode, response.message);
      status = Status.error;
      update();
    }
  }

  @override
  void onInit() {
    getPrivacyPolicyRepo();
    super.onInit();
  }
}
