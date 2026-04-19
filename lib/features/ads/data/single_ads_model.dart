class SingleAdvertisement {
  final String id;
  final String user;
  final String advertiser;
  final String title;
  final String description;
  final String image;
  final String focusArea;
  final FocusAreaLocation focusAreaLocation;
  final String websiteUrl;
  final DateTime startAt;
  final DateTime endAt;
  final String plan;
  final double price;
  final String paymentStatus;
  final DateTime? paidAt;
  final int reachCount;
  final int clickCount;
  final String status;
  final String approvalStatus;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SingleAdvertisement({
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

  factory SingleAdvertisement.fromJson(Map<String, dynamic> json) {
    return SingleAdvertisement(
      id: json['_id'],
      user: json['user'],
      advertiser: json['advertiser'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      focusArea: json['focusArea'],
      focusAreaLocation: FocusAreaLocation.fromJson(json['focusAreaLocation']),
      websiteUrl: json['websiteUrl'],
      startAt: DateTime.parse(json['startAt']),
      endAt: DateTime.parse(json['endAt']),
      plan: json['plan'],
      price: (json['price'] as num).toDouble(),
      paymentStatus: json['paymentStatus'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      reachCount: json['reachCount'],
      clickCount: json['clickCount'],
      status: json['status'],
      approvalStatus: json['approvalStatus'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'advertiser': advertiser,
      'title': title,
      'description': description,
      'image': image,
      'focusArea': focusArea,
      'focusAreaLocation': focusAreaLocation.toJson(),
      'websiteUrl': websiteUrl,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'plan': plan,
      'price': price,
      'paymentStatus': paymentStatus,
      'paidAt': paidAt?.toIso8601String(),
      'reachCount': reachCount,
      'clickCount': clickCount,
      'status': status,
      'approvalStatus': approvalStatus,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FocusAreaLocation {
  final String type;
  final List<double> coordinates;

  FocusAreaLocation({required this.type, required this.coordinates});

  factory FocusAreaLocation.fromJson(Map<String, dynamic> json) {
    return FocusAreaLocation(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
