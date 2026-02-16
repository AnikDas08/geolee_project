class NearbyChatResponseModel {
  final bool success;
  final String message;
  final PaginationModel pagination;
  final List<NearbyChatUserModel> data;

  NearbyChatResponseModel({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory NearbyChatResponseModel.fromJson(Map<String, dynamic> json) {
    return NearbyChatResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => NearbyChatUserModel.fromJson(e))
          .toList(),
    );
  }

  operator [](int other) {}
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
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 0,
      totalPage: json['totalPage'] ?? 0,
    );
  }
}


class NearbyChatUserModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? image;
  final String? gender;
  final DateTime? dob;
  final String? bio;
  final String privacy;
  final String? address;
  final LocationModel location;
  final String status;
  final bool isLocationVisible;
  final bool isOnline;
  final bool isVerified;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AdvertiserModel? advertiser;

  NearbyChatUserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.image,
    this.gender,
    this.dob,
    this.bio,
    required this.privacy,
    this.address,
    required this.location,
    required this.status,
    required this.isLocationVisible,
    required this.isOnline,
    required this.isVerified,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.advertiser,
  });

  factory NearbyChatUserModel.fromJson(Map<String, dynamic> json) {
    return NearbyChatUserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      bio: json['bio'],
      privacy: json['privacy'] ?? '',
      address: json['address'],
      location: LocationModel.fromJson(json['location'] ?? {}),
      status: json['status'] ?? '',
      isLocationVisible: json['isLocationVisible'] ?? false,
      isOnline: json['isOnline'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      advertiser: json['advertiser'] != null
          ? AdvertiserModel.fromJson(json['advertiser'])
          : null,
    );
  }
}


class AdvertiserModel {
  final String id;
  final String user;
  final String businessName;
  final String businessType;
  final String? logo;
  final String licenseNumber;
  final String phone;
  final String bio;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdvertiserModel({
    required this.id,
    required this.user,
    required this.businessName,
    required this.businessType,
    this.logo,
    required this.licenseNumber,
    required this.phone,
    required this.bio,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdvertiserModel.fromJson(Map<String, dynamic> json) {
    return AdvertiserModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      businessName: json['businessName'] ?? '',
      businessType: json['businessType'] ?? '',
      logo: json['logo'],
      licenseNumber: json['licenseNumber'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}


class LocationModel {
  final String type;
  final List<double> coordinates;

  LocationModel({
    required this.type,
    required this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
