import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:giolee78/config/api/api_end_point.dart';
import 'package:giolee78/config/route/app_routes.dart';
import 'package:giolee78/utils/constants/app_images.dart';
import 'package:giolee78/utils/enum/enum.dart';
import '../../data/service_history_model.dart';
import '../../repository/history_repository.dart';

class HistoryController extends GetxController {
  // Tab management
  RxInt selectedTabIndex = 0.obs;

  // History filter management
  RxInt selectedHistoryFilter = 0.obs; // 0 = Completed, 1 = Rejected

  // Real-time data from API
  RxList<RequestModel> pendingRequests = <RequestModel>[].obs;
  RxList<RequestModel> completedRequests = <RequestModel>[].obs;

  // API response data
  Rx<ServiceHistoryResponse?> serviceHistoryResponse =
      Rx<ServiceHistoryResponse?>(null);

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isAcceptLoading = false.obs;
  RxBool isRejectLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServiceHistory();
  }

  // Switch between tabs
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Switch between history filters
  void changeHistoryFilter(int index) {
    selectedHistoryFilter.value = index;
  }

  // Navigate to details screen
  void navigateHistoryDetails(RequestModel request) {
    Get.toNamed(AppRoutes.historyDetailsScreen, arguments: request);
  }

  void navigateToDetails(RequestModel request) {
    Get.toNamed(AppRoutes.completeHistoryScreen, arguments: request);
  }

  // Get current tab data
  List<RequestModel> get currentTabData {
    switch (selectedTabIndex.value) {
      case 0:
        return pendingRequests;
      case 1:
        return completedRequests;
      default:
        return pendingRequests;
    }
  }

  // Fetch service history from API
  Future<void> fetchServiceHistory() async {
    try {
      isLoading.value = true;

      debugPrint('Fetching service history...');

      final response = await HistoryRepository.getServiceHistory(
        page: currentPage.value,
        limit: 10,
      );

      debugPrint('Response received: ${response != null}');

      if (response != null && response.success) {
        debugPrint('Response success: ${response.success}');
        debugPrint('Bookings count: ${response.data.bookings.length}');

        serviceHistoryResponse.value = response;
        totalPages.value = response.pagination.totalPage;

        // Convert API data to RequestModel
        _convertApiDataToRequestModel(
          response.data.bookings,
          response.data.averageRating,
          response.data.totalReview,
        );
      } else {
        debugPrint('Response is null or not successful');
        Get.snackbar(
          'Error',
          'Failed to fetch service history',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching service history: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'An error occurred while fetching data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Convert API booking data to RequestModel
  void _convertApiDataToRequestModel(
    List<BookingModel> bookings,
    double averageRating,
    int totalReview,
  ) {
    pendingRequests.clear();
    completedRequests.clear();

    debugPrint('Converting ${bookings.length} bookings to RequestModel');

    for (var booking in bookings) {
      debugPrint('Booking status: ${booking.service.bookingStatus}');

      final requestModel = RequestModel(
        id: booking.id,
        title: booking.service.title,
        subtitle: booking.service.description,
        date: _formatDate(booking.service.serviceDate),
        price: '\$${booking.service.price.toStringAsFixed(0)}',
        customerName: booking.user.name,
        customerLocation: '${booking.service.lat}, ${booking.service.long}',
        customerImage: booking.user.image.isNotEmpty
            ? (booking.user.image.startsWith('http')
                  ? booking.user.image
                  : '${ApiEndPoint.imageUrl}${booking.user.image}')
            : AppImages.noImage,
        status: _mapBookingStatusToStatusType(booking.service.bookingStatus),
        totalReview: totalReview,
        averageRating: averageRating,
        time: booking.service.serviceTime,
        priorityLevel: booking.service.priority,
      );

      // Separate based on booking status
      final status = booking.service.bookingStatus.toUpperCase();
      if (status == 'PENDING' || status == 'ACCEPTED' || status == 'RUNNING') {
        pendingRequests.add(requestModel);
        debugPrint('Added to pendingRequests: ${requestModel.title}');
      } else if (status == 'COMPLETED') {
        completedRequests.add(requestModel);
        debugPrint('Added to completedRequests: ${requestModel.title}');
      } else {
        debugPrint('Status not matched: $status');
      }
      // REJECTED and CANCELLED statuses are not displayed in current tabs
    }

    debugPrint(
      'Total pending: ${pendingRequests.length}, completed: ${completedRequests.length}',
    );
  }

  // Format date from API
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d\'th\' MMMM yy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Map booking status to StatusType enum
  StatusType _mapBookingStatusToStatusType(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'ACCEPTED':
      case 'RUNNING':
        return StatusType.running;
      case 'COMPLETED':
        return StatusType.completed;
      case 'REJECTED':
      case 'CANCELLED':
        return StatusType.rejected;
      default:
        return StatusType.running;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    currentPage.value = 1;
    await fetchServiceHistory();
  }

  // Accept request
  Future<void> acceptRequest(String requestId) async {
    try {
      isAcceptLoading.value = true;

      // For now, just remove from pending list
      final requestIndex = pendingRequests.indexWhere(
        (req) => req.id == requestId,
      );
      if (requestIndex != -1) {
        pendingRequests.removeAt(requestIndex);

        // Show success message
        Get.snackbar(
          'Success',
          'Request accepted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Refresh data from API
        await fetchServiceHistory();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept request',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAcceptLoading.value = false;
    }
  }

  // Reject request
  Future<void> rejectRequest(String requestId) async {
    try {
      isRejectLoading.value = true;

      // For now, just remove from pending list
      final requestIndex = pendingRequests.indexWhere(
        (req) => req.id == requestId,
      );
      if (requestIndex != -1) {
        pendingRequests.removeAt(requestIndex);

        // Show success message
        Get.snackbar(
          'Success',
          'Request rejected successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Refresh data from API
        await fetchServiceHistory();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject request',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRejectLoading.value = false;
    }
  }
}

// Request model
class RequestModel {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final String price;
  final String customerName;
  final String customerLocation;
  final String customerImage;
  final StatusType status;
  final int totalReview;
  final double averageRating;
  final String time;
  final String priorityLevel;

  RequestModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.price,
    required this.customerName,
    required this.customerLocation,
    required this.customerImage,
    required this.status,
    required this.totalReview,
    required this.averageRating,
    required this.time,
    required this.priorityLevel,
  });

  RequestModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? date,
    String? price,
    String? customerName,
    String? customerLocation,
    String? customerImage,
    StatusType? status,
    int? totalReview,
    double? averageRating,
    String? time,
    String? priorityLevel,
  }) {
    return RequestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      price: price ?? this.price,
      customerName: customerName ?? this.customerName,
      customerLocation: customerLocation ?? this.customerLocation,
      customerImage: customerImage ?? this.customerImage,
      status: status ?? this.status,
      totalReview: totalReview ?? this.totalReview,
      averageRating: averageRating ?? this.averageRating,
      time: time ?? this.time,
      priorityLevel: priorityLevel ?? this.priorityLevel,
    );
  }
}
