import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:giolee78/features/ads/data/add_history_model.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/services/api/api_response_model.dart';
import 'package:giolee78/services/api/api_service.dart';

import '../../data/single_ads_model.dart';

class ViewAdsScreenController extends GetxController {

  late String adsId;
  SingleAdvertisement? ad;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    adsId = Get.arguments;
    fetchAdById();
  }

  Future<void> fetchAdById() async {
    isLoading = true;
    update();

    try {
      final endpoint = "${ApiEndPoint.getAdvertisementById}$adsId";
      ApiResponseModel response = await ApiService.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        ad = SingleAdvertisement.fromJson(response.data['data']);
      }
    } catch (e) {
      print("Error fetching single ad: $e");
    }

    isLoading = false;
    update();
  }


  Future<void>deleteAdsById()async{
    try{


      ApiResponseModel response=await ApiService.delete(ApiEndPoint.deleteAdvertisementById+adsId);
      if(response.statusCode==200){
        Get.snackbar("Success", "Ads Deleted Successfully");
      }else{
        Get.snackbar("Error", response.message??"Something went wrong");
      }

    }catch(e){
      debugPrint("Delete Ads Error: $e");
    }

  }


}
