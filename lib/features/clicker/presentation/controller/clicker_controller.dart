import 'package:get/get.dart';
import 'package:giolee78/component/image/common_image.dart';
import 'package:giolee78/utils/constants/app_images.dart';

class ClickerController extends GetxController {
  final _currentPosition = 0.obs;
  // State for the currently selected filter
  final _selectedFilter = 'All'.obs;

  int get currentPosition => _currentPosition.value;
  String get selectedFilter => _selectedFilter.value; // Getter for the selected filter

  // Filter options list for the bottom sheet
  final List<String> filterOptions = [
    'All',
    'Great Vibes',
    'Off Vibes',
    'Charming Gentleman',
    'Lovely Lady',
  ];

  final banners = [
    CommonImage(imageSrc: AppImages.banner1),
    CommonImage(imageSrc: AppImages.banner2),
    CommonImage(imageSrc: AppImages.banner3),
  ].obs;





  @override
  void onInit() {
    super.onInit();
    _currentPosition.value = 0;
  }

  void changePosition(int position) {
    _currentPosition.value = position;
  }

  // Method to update the selected filter state
  void changeFilter(String newFilter) {
    _selectedFilter.value = newFilter;
  }
}