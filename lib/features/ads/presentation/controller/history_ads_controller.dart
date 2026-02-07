import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/ads/data/add_history_model.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

class HistoryAdsController extends GetxController {
  final RxInt _selectedTabIndex = 0.obs;
  int get selectedTabIndex => _selectedTabIndex.value;

  void changeTab(int index) {
    if (_selectedTabIndex.value == index) return;
    _selectedTabIndex.value = index;
    update();
    fetchAds(); // Tab change হলে fetch করা
  }

  List<Advertisement> allAds = [];
  List<Advertisement> activeAds = [];

  List<Advertisement> get currentAds =>
      selectedTabIndex == 0 ? allAds : activeAds;

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds() async {
    isLoading = true;
    update();

    try {
      // All Ads
      ApiResponseModel responseAll = await ApiService.get(
        ApiEndPoint.getAdvertisement,
      );

      if (responseAll.statusCode == 200 && responseAll.data != null) {
        final List<dynamic> jsonList = responseAll.data['data'];
        allAds = jsonList.map((e) => Advertisement.fromJson(e)).toList();
      }

      // Active Ads
      ApiResponseModel responseActive = await ApiService.get(
      "${ApiEndPoint.getAdvertisement}${'status'}"

      );


      if (responseActive.statusCode == 200 && responseActive.data != null) {
        final List<dynamic> jsonList = responseActive.data['data'];
        activeAds = jsonList.map((e) => Advertisement.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching ads: $e');
    }

    isLoading = false;
    update();
  }
}
