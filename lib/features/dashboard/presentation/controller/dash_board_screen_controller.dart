import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:giolee78/features/advertise/presentation/controller/provider_profile_view_controller.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../config/api/api_end_point.dart';
import '../../data/advertiserment_overview_model.dart';
import '../../data/my_active_ads_model.dart';

class DashBoardScreenController extends GetxController {
  var isLoading = false.obs;

  var overviewData = AdvertisementOverviewData(
    totalActiveAds: 0,
    totalReachCount: 0,
    totalClickCount: 0,
    engagementRate: 0,
  ).obs;

  @override
  void onInit() {
    fetchAdvertisementOverview();
    super.onInit();
    fetchMyActiveAds();
  }

  List<MyActiveAdvertisement> activeAds = [];

  Future<void> fetchAdvertisementOverview() async {
    try {
      isLoading(true);

      ApiResponseModel response = await ApiService.get(
        ApiEndPoint.advertisementsOverviewMe,
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = AdvertisementOverviewResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (result.success) {
          overviewData.value = result.data;
          update();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMyActiveAds() async {
    try {
      final activeEndpoint = "${ApiEndPoint.getAdvertisementMe}?status=active";

      ApiResponseModel responseActive = await ApiService.get(activeEndpoint);

      print('Active Ads Response: ${responseActive.data}');

      if (responseActive.statusCode == 200 && responseActive.data != null) {

        debugPrint("${responseActive.data}");

        final List<dynamic> jsonList = responseActive.data['data'];
        activeAds = jsonList
            .map((e) => MyActiveAdvertisement.fromJson(e))
            .toList();
        update();
        print('Active Ads parsed: ${activeAds.length}');
      }
    } catch (e) {
      debugPrint("Exception Error Is :${e}");
    }
  }
}
