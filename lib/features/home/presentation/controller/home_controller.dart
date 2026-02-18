import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/my_profile_controller.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../friend/data/friend_request_model.dart';
import '../../data/data_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];
  String searchQuery = '';
  RxString name = "".obs;
  RxString image = "".obs;
  String subCategory = "";
  int notificationCount = 0;
  RxList<FriendModel> friendRequestsList = <FriendModel>[].obs;

  RxBool IsLoading = false.obs;

  var clickerCount = RxnString();
  var filterOption = RxnString();

  // ─── Filter parameters ───
  var selectedPeriod = ''.obs;
  Rxn<DateTime> startDate = Rxn<DateTime>();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  RxBool isDateFilterActive = false.obs;
  String? argument;

  // --- Heatmap Variables ---
  Set<Heatmap> heatmaps = {};


  //this on for map  marker and post count
  RxList<Marker> markerList = <Marker>[].obs;

  // --- Current Location Variables ---
  RxDouble currentLatitude = 0.0.obs;
  RxDouble currentLongitude = 0.0.obs;
  RxBool isLocationUpdating = false.obs;

  List<String> clickerOptions = ["All", "Great Vibes", "Off Vibes", "Charming Gentleman", "Lovely Lady"];
  List<String> filterOptions = ["Option 1", "Option 2", "Option 3"];
  final MyProfileController myProfileController = Get.put(MyProfileController());

  @override
  void onInit() {
    super.onInit();
    try {
      argument = Get.arguments;
      Get.find<HomeNavController>().refresh();
      Get.find<MyProfileController>().refresh();
      myProfileController.getUserData();

      if (LocalStorage.token != null && LocalStorage.token!.isNotEmpty) {
        getCurrentLocationAndUpdateProfile();
        fetchPosts();
        myProfileController.getUserData();
      } else {
        allPosts = [];
        filteredPosts = [];
        isLoading = false;
        update();
      }
    } catch (e) {
      debugPrint('Error in onInit: $e');
      update();
    }
  }

  HeatmapGradient _getHeatmapGradient() {
    final clicker = clickerCount.value;
    if (clicker == "Great Vibes") {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.lightGreen, 0.1),
        HeatmapGradientColor(Colors.green, 0.4),
        HeatmapGradientColor(Colors.green.shade700, 0.7),
        HeatmapGradientColor(Colors.green.shade900, 1.0),
      ]);
    } else if (clicker == "Off Vibes") {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.orange.shade200, 0.1),
        HeatmapGradientColor(Colors.orange, 0.4),
        HeatmapGradientColor(Colors.deepOrange, 0.7),
        HeatmapGradientColor(Colors.red.shade900, 1.0),
      ]);
    } else if (clicker == "Charming Gentleman") {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.lightBlue, 0.1),
        HeatmapGradientColor(Colors.blue, 0.4),
        HeatmapGradientColor(Colors.indigo, 0.7),
        HeatmapGradientColor(Colors.purple.shade900, 1.0),
      ]);
    } else if (clicker == "Lovely Lady") {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.pink.shade100, 0.1),
        HeatmapGradientColor(Colors.pinkAccent, 0.4),
        HeatmapGradientColor(Colors.pink, 0.7),
        HeatmapGradientColor(Colors.pink.shade900, 1.0),
      ]);
    } else {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.cyan, 0.1),
        HeatmapGradientColor(Colors.yellow, 0.4),
        HeatmapGradientColor(Colors.orange, 0.7),
        HeatmapGradientColor(Colors.red, 1.0),
      ]);
    }
  }

  Color _getMarkerColor() {
    final clicker = clickerCount.value;
    if (clicker == "Great Vibes") return Colors.green;
    if (clicker == "Off Vibes") return Colors.deepOrange;
    if (clicker == "Charming Gentleman") return Colors.indigo;
    if (clicker == "Lovely Lady") return Colors.pink;
    return Colors.red;
  }

  Future<BitmapDescriptor> _createCountMarkerIcon(int count, Color bgColor) async {
    try {
      const double size = 60;
      double fontSize = 22.sp;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final Paint borderPaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, borderPaint);

      final Paint bgPaint = Paint()..color = bgColor;
      canvas.drawCircle(const Offset(size / 2, size / 2), (size / 2) - 4, bgPaint);

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
      );

      final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error creating count marker icon: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  // ✅ async শেষে markerList.assignAll() → Obx তে সাথে সাথে update হবে
  Future<void> _generateMarkersFromPosts(List<Post> posts) async {
    try {
      markerList.clear();

      Map<String, List<Post>> grouped = {};

      for (var post in posts) {
        if (post.lat == 0 && post.long == 0) continue;
        if (post.lat < -90 || post.lat > 90 || post.long < -180 || post.long > 180) continue;

        double roundedLat = (post.lat * 1000).roundToDouble() / 1000;
        double roundedLng = (post.long * 1000).roundToDouble() / 1000;
        String key = '${roundedLat}_$roundedLng';
        grouped.putIfAbsent(key, () => []).add(post);
      }

      final Color markerColor = _getMarkerColor();
      List<Marker> newMarkers = [];

      for (var entry in grouped.entries) {
        final parts = entry.key.split('_');
        final double lat = double.parse(parts[0]);
        final double lng = double.parse(parts[1]);
        final int count = entry.value.length;
        final BitmapDescriptor icon = await _createCountMarkerIcon(count, markerColor);

        newMarkers.add(
          Marker(
            markerId: MarkerId(entry.key),
            position: LatLng(lat, lng),
            icon: icon,
            infoWindow: InfoWindow(
              title: '$count ${count == 1 ? 'Post' : 'Posts'}',
              snippet: entry.value.first.clickerType ?? '',
            ),
          ),
        );
      }

      // ✅ assignAll → RxList notify করে, Obx সাথে সাথে rebuild করে
      markerList.assignAll(newMarkers);
      debugPrint('Markers updated: ${markerList.length} markers');
    } catch (e) {
      debugPrint('Error generating markers: $e');
    }
  }

  void _generateHeatmapFromPosts(List<Post> posts) {
    try {
      if (posts.isEmpty) {
        heatmaps = {};
        markerList.clear();
        update();
        return;
      }

      List<WeightedLatLng> heatmapPoints = [];

      for (var post in posts) {
        try {
          if (post.lat != 0 && post.long != 0) {
            if (post.lat >= -90 && post.lat <= 90 && post.long >= -180 && post.long <= 180) {
              double weight = 1.0;
              if (post.clickerType == "Great Vibes") weight = 2.0;
              else if (post.clickerType == "Off Vibes") weight = 1.5;
              else if (post.clickerType == "Charming Gentleman" || post.clickerType == "Lovely Leady") weight = 2.5;

              heatmapPoints.add(WeightedLatLng(LatLng(post.lat, post.long), weight: weight));
            }
          }
        } catch (e) {
          debugPrint('Error processing post ${post.id}: $e');
        }
      }

      if (heatmapPoints.isNotEmpty) {
        heatmaps = {
          Heatmap(
            heatmapId: const HeatmapId("posts_activity"),
            data: heatmapPoints,
            radius: HeatmapRadius.fromPixels(50),
            opacity: 0.8,
            gradient: _getHeatmapGradient(),
          )
        };
      } else {
        heatmaps = {};
      }

      update();

      // ✅ async marker generation — শেষ হলে Obx তে auto-update
      _generateMarkersFromPosts(posts);
    } catch (e) {
      debugPrint('Error in _generateHeatmapFromPosts: $e');
    }
  }

  void applyPeriodFilter(String period) {
    try {
      final DateTime now = DateTime.now();
      DateTime calculatedStart;

      if (period == 'Last 24 Hours') {
        calculatedStart = now.subtract(const Duration(hours: 24));
      } else if (period == 'Last 7 Days') {
        calculatedStart = now.subtract(const Duration(days: 7));
      } else if (period == 'Last 15 Days') {
        calculatedStart = now.subtract(const Duration(days: 15));
      } else if (period == 'Last 30 Days') {
        calculatedStart = now.subtract(const Duration(days: 30));
      } else {
        calculatedStart = now.subtract(const Duration(hours: 24));
      }

      selectedPeriod.value = period;
      startDate.value = calculatedStart;
      endDate.value = now;
      isDateFilterActive.value = true;

      fetchPostsWithFilter();
      update();
    } catch (e) {
      debugPrint('Error in applyPeriodFilter: $e');
      Get.snackbar('Filter Error', 'Failed to apply period filter.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white);
    }
  }

  void applyFilter(String period, DateTime start, DateTime end) {
    try {
      selectedPeriod.value = 'Custom Range';
      startDate.value = start;
      endDate.value = end;
      isDateFilterActive.value = true;

      fetchPostsWithFilter();
      update();
    } catch (e) {
      debugPrint('Error in applyFilter: $e');
      Get.snackbar('Filter Error', 'Failed to apply date filter.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white);
    }
  }

  void clearDateFilter() {
    try {
      selectedPeriod.value = '';
      startDate.value = null;
      endDate.value = null;
      isDateFilterActive.value = false;
      fetchPostsWithFilter();
      update();
    } catch (e) {
      debugPrint('Error clearing date filter: $e');
    }
  }

  void applyClickerFilter(String? clickerType) async {
    try {
      clickerCount.value = clickerType;
      await fetchPostsWithFilter();
    } catch (e) {
      debugPrint('Error in applyClickerFilter: $e');
      Get.snackbar('Filter Error', 'Failed to apply clicker filter.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white);
    }
  }

  Future<void> fetchPostsWithFilter() async {
    try {
      isLoading = true;
      update();

      String url = "${ApiEndPoint.post}?limit=100";

      if (clickerCount.value != null && clickerCount.value != "All") {
        url += "&clickerType=${Uri.encodeComponent(clickerCount.value!)}";
      }

      if (startDate.value != null && endDate.value != null) {
        final String start = startDate.value!.toUtc().toIso8601String();
        final String end = endDate.value!.toUtc().toIso8601String();
        url += "&startDate=${Uri.encodeComponent(start)}&endDate=${Uri.encodeComponent(end)}";
      }

      debugPrint('Fetch URL: $url');

      final response = await ApiService.get(url);

      if (response.statusCode == 200) {
        try {
          final postResponse = PostResponseModel.fromJson(response.data);
          allPosts = postResponse.data;
          filteredPosts = allPosts;
          _generateHeatmapFromPosts(allPosts);
        } catch (e) {
          debugPrint('Error parsing post response: $e');
          allPosts = [];
          filteredPosts = [];
        }
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      allPosts = [];
      filteredPosts = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchPosts() async {
    try {
      isLoading = true;
      update();

      final response = await ApiService.get("${ApiEndPoint.post}?limit=100");

      if (response.statusCode == 200) {
        try {
          final postResponse = PostResponseModel.fromJson(response.data);
          allPosts = postResponse.data;
          filteredPosts = allPosts;
          _generateHeatmapFromPosts(allPosts);
        } catch (e) {
          debugPrint('Error parsing post response: $e');
          allPosts = [];
          filteredPosts = [];
        }
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      allPosts = [];
      filteredPosts = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinate(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
      return null;
    } catch (e) {
      debugPrint("Error in getAddressFromCoordinate: $e");
      return null;
    }
  }

  Future<void> updateProfile(double longitude, double latitude) async {
    try {
      String? address = await getAddressFromCoordinate(latitude, longitude);
      Map<String, dynamic> body = {
        "location": [longitude, latitude],
        "address": address ?? "Location Unavailable"
      };
      final response = await ApiService.patch("users/profile", body: body);
      if (response.statusCode == 200) {
        debugPrint('Profile location updated: $longitude, $latitude');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> getCurrentLocationAndUpdateProfile() async {
    try {
      isLocationUpdating.value = true;
      Position? position = await getCurrentLocation();
      if (position != null) {
        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;
        await updateProfile(position.longitude, position.latitude);
      }
    } catch (e) {
      debugPrint('Error in getCurrentLocationAndUpdateProfile: $e');
    } finally {
      isLocationUpdating.value = false;
    }
  }

  void searchPosts(String query) {
    try {
      searchQuery = query.toLowerCase();
      filteredPosts = searchQuery.isEmpty
          ? allPosts
          : allPosts.where((post) {
        try {
          return post.title.toLowerCase().contains(searchQuery) ||
              post.description.toLowerCase().contains(searchQuery) ||
              post.user.name.toLowerCase().contains(searchQuery);
        } catch (e) {
          return false;
        }
      }).toList();

      _generateHeatmapFromPosts(filteredPosts);
      update();
    } catch (e) {
      debugPrint('Error in searchPosts: $e');
    }
  }

  Future<void> fetchFriendRequests() async {
    try {
      IsLoading.value = true;
      final response = await ApiService.get("${ApiEndPoint.getMyFriendRequest}");
      if (response.statusCode == 200) {
        try {
          final dataList = response.data['data'] as List<dynamic>;
          friendRequestsList.value =
              dataList.map((e) => FriendModel.fromJson(e as Map<String, dynamic>)).toList();
        } catch (e) {
          debugPrint("Error parsing friend requests: $e");
          friendRequestsList.value = [];
        }
      }
    } catch (e) {
      debugPrint('Error fetching friend requests: $e');
    } finally {
      IsLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    try {
      await fetchPosts();
      await fetchFriendRequests();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }

  void clearHeatmap() {
    heatmaps = {};
    markerList.clear();
    update();
  }
}