import 'package:flutter/material.dart';

import '../../../config/api/api_end_point.dart';
import '../../../services/api/api_response_model.dart';
import '../../../services/api/api_service.dart';
import '../data/service_history_model.dart';

class HistoryRepository {
  /// Fetch service history from API
  /// Returns ServiceHistoryResponse on success
  static Future<ServiceHistoryResponse?> getServiceHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Build query parameters
      final queryParams = '?page=$page&limit=$limit';
      final endpoint = '${ApiEndPoint.myServiceHistory}$queryParams';

      // Make API call
      final ApiResponseModel response = await ApiService.get(endpoint);

      // Check if response is successful
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        // Parse and return the response
        return ServiceHistoryResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        // Handle error response
        debugPrint('Error fetching service history: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('Exception in getServiceHistory: $e');
      return null;
    }
  }

  /// Fetch service history with custom filters
  static Future<ServiceHistoryResponse?> getFilteredServiceHistory({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
  }) async {
    try {
      // Build query parameters
      String queryParams = '?page=$page&limit=$limit';

      if (status != null && status.isNotEmpty) {
        queryParams += '&status=$status';
      }

      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams += '&paymentStatus=$paymentStatus';
      }

      final endpoint = '${ApiEndPoint.myServiceHistory}$queryParams';

      // Make API call
      final ApiResponseModel response = await ApiService.get(endpoint);

      // Check if response is successful
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        // Parse and return the response
        return ServiceHistoryResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        // Handle error response
        debugPrint(
          'Error fetching filtered service history: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('Exception in getFilteredServiceHistory: $e');
      return null;
    }
  }
}
