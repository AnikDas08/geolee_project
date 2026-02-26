import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/features/home/presentation/controller/home_nav_controller.dart';
import 'package:giolee78/features/profile/presentation/controller/my_profile_controller.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_keys.dart';
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

  // ─── Heatmap ───
  RxSet<Heatmap> heatmaps = <Heatmap>{}.obs;

  // ─── Map refresh — single trigger with debounce ───
  RxInt mapRefreshTrigger = 0.obs;
  Timer? _refreshDebounce;

  // ─── Google Map Controller ───
  Completer<GoogleMapController> mapController = Completer();

  // ─── Markers ───
  RxList<Marker> markerList = <Marker>[].obs;

  // ─── Marker icon cache — OOM fix ───
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  // ─── Current Location ───
  RxDouble currentLatitude = 0.0.obs;
  RxDouble currentLongitude = 0.0.obs;
  RxBool isLocationUpdating = false.obs;

  List<String> clickerOptions = [
    "All",
    "Great Vibes",
    "Off Vibes",
    "Charming Gentleman",
    "Lovely Lady",
  ];

  final MyProfileController myProfileController =
  Get.put(MyProfileController());

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      argument = Get.arguments;
      Get.find<HomeNavController>().refresh();
      Get.find<MyProfileController>().refresh();
      await myProfileController.getUserData();
      await getUserData();

      // ✅ default All
      clickerCount.value = "All";

      if (LocalStorage.token.isNotEmpty) {
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

  // ─── Debounced map refresh ───
  void _scheduleMapRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 300), () {
      mapRefreshTrigger.value++;
    });
  }

  // ─────────────────────────────────────────
  //  Heatmap Gradient & Marker Color
  // ─────────────────────────────────────────

  HeatmapGradient _getHeatmapGradient() {
    final clicker = clickerCount.value;
    if (clicker == "Great Vibes") {
      return HeatmapGradient([
        const HeatmapGradientColor(Colors.lightGreen, 0.1),
        const HeatmapGradientColor(Colors.green, 0.4),
        HeatmapGradientColor(Colors.green.shade700, 0.7),
        HeatmapGradientColor(Colors.green.shade900, 1.0),
      ]);
    } else if (clicker == "Off Vibes") {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.orange.shade200, 0.1),
        const HeatmapGradientColor(Colors.orange, 0.4),
        const HeatmapGradientColor(Colors.deepOrange, 0.7),
        HeatmapGradientColor(Colors.red.shade900, 1.0),
      ]);
    } else if (clicker == "Charming Gentleman") {
      return HeatmapGradient([
        const HeatmapGradientColor(Colors.lightBlue, 0.1),
        const HeatmapGradientColor(Colors.blue, 0.4),
        const HeatmapGradientColor(Colors.indigo, 0.7),
        HeatmapGradientColor(Colors.purple.shade900, 1.0),
      ]);
    } else if (clicker == "Lovely Lady") {
      return HeatmapGradient([
        HeatmapGradientColor(Colors.pink.shade100, 0.1),
        const HeatmapGradientColor(Colors.pinkAccent, 0.4),
        const HeatmapGradientColor(Colors.pink, 0.7),
        HeatmapGradientColor(Colors.pink.shade900, 1.0),
      ]);
    } else {
      return const HeatmapGradient([
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

  // ─────────────────────────────────────────
  //  Marker Icon — cached + disposed
  // ─────────────────────────────────────────

  void clearMarkerCache() => _markerIconCache.clear();

  Future<BitmapDescriptor> _createCountMarkerIcon(
      int count, Color bgColor) async {
    final String cacheKey = '${count}_${bgColor.value}';
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }
    try {
      const double size = 60;
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        size / 2,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        (size / 2) - 4,
        Paint()..color = bgColor,
      );

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22, // ✅ static — no .sp OOM
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(size / 2 - tp.width / 2, size / 2 - tp.height / 2),
      );

      final ui.Image img =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose(); // ✅ memory free

      final icon = BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
      _markerIconCache[cacheKey] = icon;
      return icon;
    } catch (e) {
      debugPrint('Error creating marker icon: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  // ─────────────────────────────────────────
  //  Heatmap Generator
  // ─────────────────────────────────────────

  void _generateHeatmapFromPosts(List<Post> posts) {
    try {
      if (posts.isEmpty) {
        heatmaps.clear();
        markerList.clear();
        _scheduleMapRefresh();
        update();
        return;
      }

      final List<WeightedLatLng> heatmapPoints = [];
      for (var post in posts) {
        try {
          if (post.lat != 0 &&
              post.long != 0 &&
              post.lat >= -90 &&
              post.lat <= 90 &&
              post.long >= -180 &&
              post.long <= 180) {
            double weight = 1.0;
            if (post.clickerType == "Great Vibes") {
              weight = 2.0;
            } else if (post.clickerType == "Off Vibes") weight = 1.5;
            else if (post.clickerType == "Charming Gentleman" ||
                post.clickerType == "Lovely Lady") weight = 2.5;
            heatmapPoints.add(
                WeightedLatLng(LatLng(post.lat, post.long), weight: weight));
          }
        } catch (e) {
          debugPrint('Error processing post ${post.id}: $e');
        }
      }

      if (heatmapPoints.isNotEmpty) {
        heatmaps.assignAll({
          Heatmap(
            heatmapId: const HeatmapId("posts_activity"),
            data: heatmapPoints,
            radius: const HeatmapRadius.fromPixels(50),
            opacity: 0.8,
            gradient: _getHeatmapGradient(),
          ),
        });
      } else {
        heatmaps.clear();
      }

      update();
      // ✅ async markers — শেষে debounce trigger দেবে
      _generateMarkersFromPosts(posts);
    } catch (e) {
      debugPrint('Error in _generateHeatmapFromPosts: $e');
    }
  }

  // ─────────────────────────────────────────
  //  Marker Generator
  // ─────────────────────────────────────────

  Future<void> _generateMarkersFromPosts(List<Post> posts) async {
    try {
      markerList.clear();
      final Map<String, List<Post>> grouped = {};

      for (var post in posts) {
        if (post.lat == 0 && post.long == 0) continue;
        if (post.lat < -90 ||
            post.lat > 90 ||
            post.long < -180 ||
            post.long > 180) {
          continue;
        }
        final double roundedLat = (post.lat * 1000).roundToDouble() / 1000;
        final double roundedLng = (post.long * 1000).roundToDouble() / 1000;
        final String key = '${roundedLat}_$roundedLng';
        grouped.putIfAbsent(key, () => []).add(post);
      }

      final Color markerColor = _getMarkerColor();
      final List<Marker> newMarkers = [];

      for (var entry in grouped.entries) {
        final parts = entry.key.split('_');
        final double lat = double.parse(parts[0]);
        final double lng = double.parse(parts[1]);
        final int count = entry.value.length;
        final BitmapDescriptor icon =
        await _createCountMarkerIcon(count, markerColor);

        newMarkers.add(Marker(
          markerId: MarkerId(entry.key),
          position: LatLng(lat, lng),
          icon: icon,
          infoWindow: InfoWindow(
            title: '$count ${count == 1 ? 'Post' : 'Posts'}',
            snippet: entry.value.first.clickerType ?? '',
          ),
        ));
      }

      markerList.assignAll(newMarkers);
      _scheduleMapRefresh(); // ✅ debounced — একবারই rebuild
      debugPrint('Markers: ${markerList.length}');
    } catch (e) {
      debugPrint('Error generating markers: $e');
    }
  }

  // ─────────────────────────────────────────
  //  Map Camera
  // ─────────────────────────────────────────

  Future<void> moveMapToCurrentLocation() async {
    try {
      if (!mapController.isCompleted) return;
      final ctrl = await mapController.future;
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(currentLatitude.value, currentLongitude.value),
        12,
      ));
    } catch (e) {
      debugPrint('Error moving map: $e');
    }
  }

  // ─────────────────────────────────────────
  //  Filters
  // ─────────────────────────────────────────

  void applyPeriodFilter(String period) {
    try {
      final DateTime now = DateTime.now();
      DateTime calculatedStart;

      if (period.endsWith('h')) {
        final int hours = int.parse(period.replaceAll('h', ''));
        calculatedStart = now.subtract(Duration(hours: hours));
      } else if (period == '1 Month') {
        calculatedStart = DateTime(
            now.year, now.month - 1, now.day, now.hour, now.minute, now.second);
      } else if (period.endsWith('d')) {
        final int days = int.parse(period.replaceAll('d', ''));
        calculatedStart = now.subtract(Duration(days: days));
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
      debugPrint('Error clearing filter: $e');
    }
  }

  Future<void> applyClickerFilter(String? clickerType) async {
    try {
      clearMarkerCache(); // ✅ cache clear on filter change
      clickerCount.value = clickerType;
      await fetchPostsWithFilter();
    } catch (e) {
      debugPrint('Error in applyClickerFilter: $e');
    }
  }

  // ─────────────────────────────────────────
  //  API
  // ─────────────────────────────────────────

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
        url +=
        "&startDate=${Uri.encodeComponent(start)}&endDate=${Uri.encodeComponent(end)}";
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
          debugPrint('Parse error: $e');
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
          debugPrint('Parse error: $e');
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

  Future<void> getUserData() async {
    isLoading = true;
    update();
    try {
      final response = await ApiService.get(ApiEndPoint.profile)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = response.data;
        LocalStorage.userId = data['data']?["_id"];
        LocalStorage.myImage = data['data']?["image"];
        LocalStorage.myName = data['data']?["name"];
        LocalStorage.myEmail = data['data']?["email"];
        LocalStorage.bio = data['data']?['bio'];
        LocalStorage.dateOfBirth = data['data']?['dob'];
        LocalStorage.gender = data['data']?['gender'];

        LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
        LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
        LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
        LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName);
        LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail);
      } else {
        Get.snackbar(response.statusCode.toString(), response.message);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  // ─────────────────────────────────────────
  //  Location
  // ─────────────────────────────────────────

  Future<Position?> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // ✅ medium saves memory
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinate(double lat, double lng) async {
    try {
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final Placemark p = placemarks.first;
        return "${p.street}, ${p.subLocality}, ${p.locality}, "
            "${p.administrativeArea}, ${p.country}";
      }
      return null;
    } catch (e) {
      debugPrint("getAddress error: $e");
      return null;
    }
  }

  Future<void> updateProfile(double longitude, double latitude) async {
    try {
      final String? address = await getAddressFromCoordinate(latitude, longitude);
      final response = await ApiService.patch("users/profile", body: {
        "location": [longitude, latitude],
        "address": address ?? "Location Unavailable",
      });
      if (response.statusCode == 200) {
        debugPrint('Profile location updated');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> getCurrentLocationAndUpdateProfile() async {
    try {
      isLocationUpdating.value = true;
      final Position? position = await getCurrentLocation();
      if (position != null) {
        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;

        LocalStorage.lat = position.latitude;
        LocalStorage.long = position.longitude;

        await updateProfile(position.longitude, position.latitude);
        moveMapToCurrentLocation();
      }
    } catch (e) {
      debugPrint('Location update error: $e');
    } finally {
      isLocationUpdating.value = false;
    }
  }

  // ─────────────────────────────────────────
  //  Search
  // ─────────────────────────────────────────

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
        } catch (_) {
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
      final response =
      await ApiService.get("${ApiEndPoint.getMyFriendRequest}");
      if (response.statusCode == 200) {
        try {
          final dataList = response.data['data'] as List<dynamic>;
          friendRequestsList.value = dataList
              .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint("Parse friend requests error: $e");
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
      debugPrint('Error refreshing: $e');
    }
  }

  void clearHeatmap() {
    heatmaps.clear();
    markerList.clear();
    _scheduleMapRefresh();
    update();
  }

  @override
  void onClose() {
    _refreshDebounce?.cancel(); // ✅ timer cancel
    clearMarkerCache();
    super.onClose();
  }
}