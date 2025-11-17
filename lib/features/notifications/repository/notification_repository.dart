import 'package:flutter/material.dart';
import 'package:dart_either/dart_either.dart';
import 'package:giolee78/features/notifications/data/model/checkout_session_model.dart';
import 'package:giolee78/features/notifications/data/model/custom_offer_model.dart';
import 'package:giolee78/features/notifications/data/model/offer_accept_model.dart';
import 'package:giolee78/services/storage/storage_services.dart';

import '../../../services/api/api_service.dart';
import '../../../config/api/api_end_point.dart';
import '../data/model/notification_model.dart';

class NotificationRepository {
  Future<List<NotificationModel>> notificationRepository(int page) async {
    var response = await ApiService.get(
      "${ApiEndPoint.baseUrl}${ApiEndPoint.notifications}?page=$page",
      header: {"Authorization": "Bearer ${LocalStorage.token}"},
    );

    if (response.statusCode == 200) {
      var notificationList = response.data['data'] ?? [];

      List<NotificationModel> list = [];

      for (var notification in notificationList) {
        list.add(NotificationModel.fromJson(notification));
      }

      return list;
    } else {
      return [];
    }
  }

  Future<Either<String, CustomOfferModel>> getCustomOffer(String id) async {
    try {
      var response = await ApiService.get(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.customOffer}/$id",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200) {
        return Right(
          CustomOfferModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(response.data['message']);
      }
    } catch (e) {
      debugPrint('Error fetching custom offer: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, OfferAcceptModel>> acceptCustomOffer(String id) async {
    try {
      var response = await ApiService.patch(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.customOffer}/$id",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
        body: {"status": "ACCEPTED"},
      );

      if (response.statusCode == 200) {
        return Right(
          OfferAcceptModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(response.data['message']);
      }
    } catch (e) {
      debugPrint('Error fetching custom offer: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, OfferAcceptModel>> rejectCustomOffer(String id) async {
    try {
      var response = await ApiService.patch(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.customOffer}/$id",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
        body: {"status": "REJECTED"},
      );

      if (response.statusCode == 200) {
        return Right(
          OfferAcceptModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(response.data['message']);
      }
    } catch (e) {
      debugPrint('Error fetching custom offer: $e');
      return Left(e.toString());
    }
  }

  Future<Either<String, CheckoutSessionModel>> getCheckoutSession(
    String serviceId,
  ) async {
    try {
      var response = await ApiService.post(
        "${ApiEndPoint.baseUrl}${ApiEndPoint.servicePay}",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
        body: {"service": serviceId},
      );

      if (response.statusCode == 200) {
        return Right(
          CheckoutSessionModel.fromJson(response.data as Map<String, dynamic>),
        );
      } else {
        return Left(response.data['message']);
      }
    } catch (e) {
      debugPrint('Error fetching checkout session: $e');
      return Left(e.toString());
    }
  }
}
