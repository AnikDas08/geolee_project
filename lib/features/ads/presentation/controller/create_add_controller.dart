import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../config/route/app_routes.dart';
import '../../data/plan_model.dart';

class CreateAdsController extends GetxController {
  /// ---------------- GOOGLE API KEY ----------------
  static const String _googleApiKey = 'AIzaSyAp3rwzXU0fAqaPCTRfx81ixNMu5flXnPo';

  /// ---------------- OBSERVABLES ----------------
  var coverImagePath = ''.obs;
  var selectedPricingPlan = ''.obs;
  var isLoading = false.obs;

  var plans = <PlanModel>[].obs;
  var isPlansLoading = false.obs;

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  var isStoreAvailable = false.obs;
  var storeProducts = <ProductDetails>[].obs;

  @override
  void onInit() {
    super.onInit();
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchases(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Purchase stream error: $error");
    });
  }


  // --- Places Autocomplete ---
  var placeSuggestions = <Map<String, dynamic>>[].obs;
  var isLoadingSuggestions = false.obs;

  // --- Selected Location Coordinates ---
  var selectedLatitude = ''.obs;
  var selectedLongitude = ''.obs;
  var selectedLocationName = ''.obs;

  /// ---------------- TEXT CONTROLLERS ----------------
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final focusAreaController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final adStartDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  
  // Cache for Ad ID during two-step creation process
  String _cachedAdId = "";

  // Debounce timer
  DateTime? _lastSearchTime;

  /// ---------------- PLAN HELPERS ----------------
  String get planId {
    if (selectedPricingPlan.value.isEmpty || plans.isEmpty) return '';
    final plan = plans.firstWhere(
          (p) => p.name.toLowerCase() == selectedPricingPlan.value.toLowerCase(),
      orElse: () => plans.first,
    );
    return plan.id;
  }

  double get selectedPrice {
    if (plans.isEmpty) return 0;
    final plan = plans.firstWhere(
          (p) => p.name.toLowerCase() == selectedPricingPlan.value.toLowerCase(),
      orElse: () => plans.first,
    );
    return plan.price;
  }

  void selectPricingPlan(String plan) {
    selectedPricingPlan.value = plan;
  }

  /// ---------------- IMAGE PICK ----------------
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverImagePath.value = image.path;
    }
  }



  // PLACES AUTOCOMPLETE ================================

  Future<void> searchPlaces(String query) async {
    if (query.trim().length < 2) {
      placeSuggestions.clear();
      return;
    }

    final now = DateTime.now();
    _lastSearchTime = now;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_lastSearchTime != now) return;

    try {
      isLoadingSuggestions.value = true;

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeComponent(query)}'
            '&key=$_googleApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          placeSuggestions.value = predictions
              .map((p) => {
              'place_id': p['place_id'],
              'description': p['description'],
              'main_text': p['structured_formatting']?['main_text'] ??
                  p['description'],
            },).toList();
        } else {
          placeSuggestions.clear();
          debugPrint("Places API status: ${data['status']}");
        }
      }
    } catch (e) {
      debugPrint("Places search error: $e");
      placeSuggestions.clear();
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> selectPlace(Map<String, dynamic> place) async {
    try {
      final placeId = place['place_id'];
      final description = place['description'];

      focusAreaController.text = description;
      selectedLocationName.value = description;

      placeSuggestions.clear();

      await _fetchPlaceCoordinates(placeId);
    } catch (e) {
      debugPrint("Select place error: $e");
    }
  }

  Future<void> _fetchPlaceCoordinates(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId'
            '&fields=geometry,name'
            '&key=$_googleApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          selectedLatitude.value = location['lat'].toString();
          selectedLongitude.value = location['lng'].toString();

          debugPrint(
            "Coordinates: ${selectedLatitude.value}, ${selectedLongitude.value}",
          );
        } else {
          debugPrint("Place Details API status: ${data['status']}");
          selectedLatitude.value = '0.0';
          selectedLongitude.value = '0.0';
        }
      }
    } catch (e) {
      debugPrint("Fetch coordinates error: $e");
      selectedLatitude.value = '0.0';
      selectedLongitude.value = '0.0';
    }
  }

  void clearSuggestions() {
    placeSuggestions.clear();
  }

  // VALIDATION ================================
  bool _validate() {
    if (coverImagePath.value.isEmpty) {
      Get.snackbar("Error", "Please select a cover image");
      return false;
    }
    if (titleController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter title");
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter description");
      return false;
    }
    if (focusAreaController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter focus area");
      return false;
    }
    if (selectedLatitude.value.isEmpty || selectedLatitude.value == '0.0') {
      Get.snackbar("Error", "Please select a valid location from suggestions");
      return false;
    }
    if (adStartDateController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please select ad start date");
      return false;
    }
    if (planId.isEmpty) {
      Get.snackbar("Error", "Please select pricing plan");
      return false;
    }
    return true;
  }

  //DATE HELPERS ================================

  DateTime _parseUiDate() {
    final parts = adStartDateController.text.split(' ');
    return DateTime(
      int.parse(parts[2]),
      _monthToNumber(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _formatIso(DateTime date) => date.toUtc().toIso8601String();

  String getIsoStartDate() {
    final d = _parseUiDate();
    final now = DateTime.now();
    return _formatIso(
      DateTime(d.year, d.month, d.day, now.hour, now.minute, now.second),
    );
  }

  int _monthToNumber(String month) {
    const map = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    return map[month]!;
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }

  //FETCH PLANS ================================
  Future<void> fetchPlans() async {
    try {
      isPlansLoading.value = true;
      debugPrint("🔍 Fetching plans from: ${ApiEndPoint.getPlans}");

      final ApiResponseModel response = await ApiService.get(ApiEndPoint.getPlans);

      if (response.statusCode == 200) {
        final res = response.data as Map<String, dynamic>;
        plans.value = (res['data'] as List)
            .map((e) => PlanModel.fromJson(e))
            .toList();

        debugPrint(" Plans loaded: ${plans.length} items");

        if (plans.isNotEmpty) {
          selectedPricingPlan.value = plans.first.name;
        }

        // Fetch products from store
        final available = await _iap.isAvailable();
        isStoreAvailable.value = available;
        if (available) {
          final Set<String> apiProductIds = plans.map((plan) {
            return Platform.isAndroid ? plan.googleProductId : plan.appleProductId;
          }).where((id) => id.isNotEmpty).toSet();
          
          if (apiProductIds.isNotEmpty) {
            debugPrint("🛒 Querying store for IDs: $apiProductIds");
            final productResponse = await _iap.queryProductDetails(apiProductIds);
            
            if (productResponse.error != null) {
              debugPrint("❌ Store Query Error: ${productResponse.error!.message}");
            }
            if (productResponse.notFoundIDs.isNotEmpty) {
              debugPrint("⚠️ Store Not Found IDs: ${productResponse.notFoundIDs}");
            }
            
            debugPrint("✅ Store Found Products: ${productResponse.productDetails.map((p) => p.id).toList()}");
            storeProducts.assignAll(productResponse.productDetails);
          }
        }
      } else {
        Get.snackbar("Error", response.message ?? "Failed to load plans");
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      Get.snackbar("Error", "Failed to load plans: $e");
    } finally {
      isPlansLoading.value = false;
    }
  }

  // CREATE ADS + PAYMENT ================================

  Future<void> createAds() async {
    if (!_validate()) return;
    
    // Find matching PlanModel
    final plan = plans.firstWhere(
      (p) => p.name.toLowerCase() == selectedPricingPlan.value.toLowerCase(),
      orElse: () => plans.first,
    );

    final String storeProductId = Platform.isAndroid ? plan.googleProductId : plan.appleProductId;

    isLoading.value = true;
    final available = await _iap.isAvailable();
    if (!available) {
      Get.snackbar('Store Error', 'In-app purchases not available');
      isLoading.value = false;
      return;
    }

    if (storeProducts.isEmpty) {
      Get.snackbar('Error', 'No products found in store matching API IDs. Please check Play Console setup.');
      debugPrint("❌ No products found in store matching API IDs");
      isLoading.value = false;
      return;
    }
    
    // Find the specific product the user selected to buy
    final selectedProduct = storeProducts.firstWhere(
      (prod) => prod.id == storeProductId, 
      orElse: () => storeProducts.first,
    );

    // STEP 1: CREATE AD (Pending)
    isLoading.value = true;
    final bool success = await _createPendingAd();
    if (!success) {
      isLoading.value = false;
      return;
    }

    isLoading.value = false;
    _buyProduct(selectedProduct);
  }

  Future<bool> _createPendingAd() async {
    try {
      final Map<String, String> body = {
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "focusArea": focusAreaController.text.trim(),
        "latitude": selectedLatitude.value,
        "longitude": selectedLongitude.value,
        "startAt": getIsoStartDate(),
        "plan": planId,
      };

      if (websiteLinkController.text.trim().isNotEmpty) {
        body["websiteUrl"] = websiteLinkController.text.trim();
      }

      final ApiResponseModel response = await ApiService.multipartUpdate(
        ApiEndPoint.createAds,
        method: "POST",
        body: body,
        imagePath: coverImagePath.value,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data as Map<String, dynamic>;
        final adData = resData['data'] ?? {};
        _cachedAdId = adData['_id'] ?? adData['id'] ?? "";
        
        if (_cachedAdId.isEmpty) {
          Get.snackbar('Error', 'Failed to get Ad ID from server');
          return false;
        }
        return true;
      } else {
        Get.snackbar('Error', 'Failed to create pending Ad: ${response.message}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
      return false;
    }
  }

  void _buyProduct(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> _listenToPurchases(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          Get.snackbar('Error', 'Purchase failed: ${purchaseDetails.error?.message}');
          isLoading.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
                   
          // 3. Complete the purchase in store
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }

          // 4. Verify purchase with backend and activate ad
          await _verifyPurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final Map<String, dynamic> body = {
        "advertisement": _cachedAdId,
        "platform": Platform.isAndroid ? "google" : "apple",
      };
      
      if (Platform.isAndroid) {
        body["purchaseToken"] = purchaseDetails.verificationData.serverVerificationData;
      } else if (Platform.isIOS) {
        body["transactionReceipt"] = purchaseDetails.verificationData.serverVerificationData;
      }

      final ApiResponseModel response = await ApiService.post(
        ApiEndPoint.verifyPurchase,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessPopup();
      } else {
        Get.snackbar('Error', 'Payment verification failed: ${response.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Verification error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //DATE PICKER ============================
  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text =
      "${picked.day.toString().padLeft(2, '0')} ${_month(picked.month)} ${picked.year}";
    }
  }

  //SUCCESS================================
  void _showSuccessPopup() {
    successPopUps(
      message:
      'Your Ad submitted successfully. Please wait for admin approval.',
      buttonTitle: 'Done',
      onTap: () => Get.offAllNamed(AppRoutes.homeNav),
    );
  }

  //DISPOSE ================================
  @override
  void onClose() {
    _subscription.cancel();
    titleController.dispose();
    descriptionController.dispose();
    focusAreaController.dispose();
    websiteLinkController.dispose();
    adStartDateController.dispose();
    super.onClose();
  }
}