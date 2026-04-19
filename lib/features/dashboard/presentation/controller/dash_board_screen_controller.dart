import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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
    engagementRate: 0.0,
  ).obs;

  List<MyActiveAdvertisement> activeAds = [];

  @override
  void onInit() {
    super.onInit();
    fetchAdvertisementOverview();
    fetchMyActiveAds();
  }

  Future<void> fetchAdvertisementOverview() async {
    try {
      isLoading(true);

      debugPrint("📊 Fetching advertisement overview...");

      final ApiResponseModel response = await ApiService.get(
        ApiEndPoint.advertisementsOverviewMe,
      );

      debugPrint("📊 Response status: ${response.statusCode}");
      debugPrint("📊 Response data: ${response.data}");

      if (response.statusCode == 200) {
        final result = AdvertisementOverviewResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (result.success) {
          overviewData.value = result.data;

          debugPrint("✅ Overview updated:");
          debugPrint("   Active Ads: ${overviewData.value.totalActiveAds}");
          debugPrint("   Reach Count: ${overviewData.value.totalReachCount}");
          debugPrint("   Click Count: ${overviewData.value.totalClickCount}");
          debugPrint("   Engagement: ${overviewData.value.engagementRate}");

          update(); // ✅ Trigger UI update
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching overview: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMyActiveAds() async {
    try {
      final activeEndpoint = "${ApiEndPoint.getAdvertisementMe}?status=active";

      final ApiResponseModel responseActive = await ApiService.get(activeEndpoint);

      debugPrint('📢 Active Ads Response: ${responseActive.data}');

      if (responseActive.statusCode == 200) {
        debugPrint("${responseActive.data}");

        final List<dynamic> jsonList = responseActive.data['data'];
        activeAds = jsonList
            .map((e) => MyActiveAdvertisement.fromJson(e))
            .toList();

        debugPrint('✅ Active Ads parsed: ${activeAds.length}');
        update(); // ✅ Trigger UI update
      }
    } catch (e) {
      debugPrint("❌ Exception Error: $e");
    }
  }
}