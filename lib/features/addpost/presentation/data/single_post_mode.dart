class SinglePostModel {
  final bool success;
  final String message;
  final SinglePostData data;

  SinglePostModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SinglePostModel.fromJson(Map<String, dynamic> json) {
    return SinglePostModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SinglePostData.fromJson(json['data']),
    );
  }
}

class SinglePostData {
  final String id;
  final User user;
  final List<String> photos;
  final String description;
  final String address;
  final Location location;
  final String clickerType;
  final String privacy;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  SinglePostData({
    required this.id,
    required this.user,
    required this.photos,
    required this.description,
    required this.address,
    required this.location,
    required this.clickerType,
    required this.privacy,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory SinglePostData.fromJson(Map<String, dynamic> json) {
    return SinglePostData(
      id: json['_id'] ?? '',
      user: User.fromJson(json['user']),
      photos: List<String>.from(json['photos'] ?? []),
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      location: Location.fromJson(json['location']),
      clickerType: json['clickerType'] ?? '',
      privacy: json['privacy'] ?? '',
      status: json['status'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String image;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
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
      type: json['type'] ?? '',
      coordinates: List<double>.from(
          (json['coordinates'] ?? []).map((x) => x.toDouble())),
    );
  }
}
