class MyActiveAdsModel {
  final bool success;
  final String message;
  final Pagination pagination;
  final List<MyActiveAdvertisement> data;

  MyActiveAdsModel({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory MyActiveAdsModel.fromJson(Map<String, dynamic> json) {
    return MyActiveAdsModel(
      success: json['success'],
      message: json['message'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<MyActiveAdvertisement>.from(
        json['data'].map((x) => MyActiveAdvertisement.fromJson(x)),
      ),
    );
  }
}

class Pagination {
  final int total;
  final int limit;
  final int page;
  final int totalPage;

  Pagination({
    required this.total,
    required this.limit,
    required this.page,
    required this.totalPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      limit: json['limit'],
      page: json['page'],
      totalPage: json['totalPage'],
    );
  }
}

class MyActiveAdvertisement {
  final String id;
  final String user;
  final String advertiser;
  final String title;
  final String description;
  final String image;
  final String focusArea;
  final Location focusAreaLocation;
  final String websiteUrl;
  final DateTime startAt;
  final DateTime endAt;
  final String plan;
  final int price;
  final String paymentStatus;
  final String? paidAt;
  final int reachCount;
  final int clickCount;
  final String status;
  final String approvalStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  MyActiveAdvertisement({
    required this.id,
    required this.user,
    required this.advertiser,
    required this.title,
    required this.description,
    required this.image,
    required this.focusArea,
    required this.focusAreaLocation,
    required this.websiteUrl,
    required this.startAt,
    required this.endAt,
    required this.plan,
    required this.price,
    required this.paymentStatus,
    this.paidAt,
    required this.reachCount,
    required this.clickCount,
    required this.status,
    required this.approvalStatus,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyActiveAdvertisement.fromJson(Map<String, dynamic> json) {
    return MyActiveAdvertisement(
      id: json['_id'],
      user: json['user'],
      advertiser: json['advertiser'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      focusArea: json['focusArea'],
      focusAreaLocation: Location.fromJson(json['focusAreaLocation']),
      websiteUrl: json['websiteUrl'],
      startAt: DateTime.parse(json['startAt']),
      endAt: DateTime.parse(json['endAt']),
      plan: json['plan'],
      price: json['price'],
      paymentStatus: json['paymentStatus'],
      paidAt: json['paidAt'],
      reachCount: json['reachCount'],
      clickCount: json['clickCount'],
      status: json['status'],
      approvalStatus: json['approvalStatus'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(
        json['coordinates'].map((x) => x.toDouble()),
      ),
    );
  }
}
