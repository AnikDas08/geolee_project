class ServiceHistoryResponse {
  final bool success;
  final String message;
  final PaginationModel pagination;
  final ServiceHistoryData data;

  ServiceHistoryResponse({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory ServiceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
      data: ServiceHistoryData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'pagination': pagination.toJson(),
      'data': data.toJson(),
    };
  }
}

class PaginationModel {
  final int total;
  final int limit;
  final int page;
  final int totalPage;

  PaginationModel({
    required this.total,
    required this.limit,
    required this.page,
    required this.totalPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 10,
      page: json['page'] ?? 1,
      totalPage: json['totalPage'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'limit': limit,
      'page': page,
      'totalPage': totalPage,
    };
  }
}

class ServiceHistoryData {
  final List<BookingModel> bookings;
  final double averageRating;
  final int totalReview;

  ServiceHistoryData({
    required this.bookings,
    required this.averageRating,
    required this.totalReview,
  });

  factory ServiceHistoryData.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryData(
      bookings:
          (json['bookings'] as List<dynamic>?)
              ?.map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReview: json['totalReview'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookings': bookings.map((e) => e.toJson()).toList(),
      'averageRating': averageRating,
      'totalReview': totalReview,
    };
  }
}

class BookingModel {
  final String id;
  final ServiceModel service;
  final UserModel user;
  final String paymentIntentId;
  final String paymentStatus;

  BookingModel({
    required this.id,
    required this.service,
    required this.user,
    required this.paymentIntentId,
    required this.paymentStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      service: ServiceModel.fromJson(json['service'] ?? {}),
      user: UserModel.fromJson(json['user'] ?? {}),
      paymentIntentId: json['paymentIntentId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'service': service.toJson(),
      'user': user.toJson(),
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus,
    };
  }
}

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final String category;
  final double lat;
  final double long;
  final String serviceDate;
  final String serviceTime;
  final double price;
  final String priority;
  final String bookingStatus;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.category,
    required this.lat,
    required this.long,
    required this.serviceDate,
    required this.serviceTime,
    required this.price,
    required this.priority,
    required this.bookingStatus,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
      serviceDate: json['serviceDate'] ?? '',
      serviceTime: json['serviceTime'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      priority: json['priority'] ?? '',
      bookingStatus: json['bookingStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
      'lat': lat,
      'long': long,
      'serviceDate': serviceDate,
      'serviceTime': serviceTime,
      'price': price,
      'priority': priority,
      'bookingStatus': bookingStatus,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String image;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email, 'image': image};
  }
}
