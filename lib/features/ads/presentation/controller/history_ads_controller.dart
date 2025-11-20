import 'package:get/get.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class HistoryAdsController extends GetxController {
  final RxInt _selectedTabIndex = 0.obs;

  int get selectedTabIndex => _selectedTabIndex.value;

  void changeTab(int index) {
    if (_selectedTabIndex.value == index) return;
    _selectedTabIndex.value = index;
    update();
  }

  List<_HistoryAdData> get allAds => const [
    _HistoryAdData(
      imageSrc: AppImages.banner1,
      title: 'Delicious Fast Food',
      description:
          'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavor From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps',
    ),
    _HistoryAdData(
      imageSrc: AppImages.banner2,
      title: 'Delicious Fast Food',
      description:
          'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavor From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps',
    ),
    _HistoryAdData(
      imageSrc: AppImages.banner3,
      title: 'Delicious Fast Food',
      description:
          'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavor From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps',
    ),
  ];

  List<_HistoryAdData> get activeAds => const [
    _HistoryAdData(
      imageSrc: AppImages.banner2,
      title: 'Delicious Fast Food',
      description:
          'Satisfy Your Cravings With Delicious Fast Food, Where Every Bite Is Packed With Flavor From Juicy Burgers And Crispy Fries To Cheesy Pizzas And Spicy Wraps',
    ),
  ];

  List<_HistoryAdData> get currentAds =>
      selectedTabIndex == 0 ? allAds : activeAds;
}

class _HistoryAdData {
  final String imageSrc;
  final String title;
  final String description;

  const _HistoryAdData({
    required this.imageSrc,
    required this.title,
    required this.description,
  });
}
