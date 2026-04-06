class AdvertisementResponse {
  final bool success;
  final String message;
  final Pagination pagination;
  final List<Advertisement> data;

  AdvertisementResponse({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory AdvertisementResponse.fromJson(Map<String, dynamic> json) {
    return AdvertisementResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      data: List<Advertisement>.from(
        (json['data'] ?? []).map((x) => Advertisement.fromJson(x)),
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
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 0,
      totalPage: json['totalPage'] ?? 0,
    );
  }
}

class Advertisement {
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
  final dynamic paidAt;
  final int reachCount;
  final int clickCount;
  final String status;
  final String approvalStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Advertisement({
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

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    try {
      return Advertisement(
        id: json['_id'] ?? '',
        user: json['user'] ?? '',
        advertiser: json['advertiser'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image: json['image'] ?? '',
        focusArea: json['focusArea'] ?? '',
        focusAreaLocation: Location.fromJson(json['focusAreaLocation'] ?? {}),
        websiteUrl: json['websiteUrl'] ?? '',
        startAt: DateTime.tryParse(json['startAt']?.toString() ?? '') ?? DateTime.now(),
        endAt: DateTime.tryParse(json['endAt']?.toString() ?? '') ?? DateTime.now(),
        plan: json['plan'] ?? '',
        price: json['price'] ?? 0,
        paymentStatus: json['paymentStatus'] ?? '',
        paidAt: json['paidAt'],
        reachCount: json['reachCount'] ?? 0,
        clickCount: json['clickCount'] ?? 0,
        status: json['status'] ?? '',
        approvalStatus: json['approvalStatus'] ?? '',
        isDeleted: json['isDeleted'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print("❌ Advertisement parsing error: $e");
      // Return a minimal model to avoid crashing the list
      return Advertisement(
        id: json['_id'] ?? '',
        user: '', advertiser: '', title: 'Error loading ad', description: '',
        image: '', focusArea: '', 
        focusAreaLocation: Location(type: '', coordinates: []),
        websiteUrl: '', startAt: DateTime.now(), endAt: DateTime.now(),
        plan: '', price: 0, paymentStatus: '', reachCount: 0, clickCount: 0,
        status: '', approvalStatus: '', isDeleted: false,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
    }
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
      type: json['type'] ?? '',
      coordinates: List<double>.from(
        (json['coordinates'] ?? []).map((x) => x.toDouble()),
      ),
    );
  }
}
