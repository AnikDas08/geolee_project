// post_model.dart
class AllPostModel {
  bool success;
  String message;
  Pagination pagination;
  List<PostData> data;

  AllPostModel({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory AllPostModel.fromJson(Map<dynamic, dynamic> json) => AllPostModel(
    success: json["success"],
    message: json["message"],
    pagination: Pagination.fromJson(json["pagination"]),
    data: List<PostData>.from(
        json["data"].map((x) => PostData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "pagination": pagination.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Pagination {
  int total;
  int limit;
  int page;
  int totalPage;

  Pagination({
    required this.total,
    required this.limit,
    required this.page,
    required this.totalPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    limit: json["limit"],
    page: json["page"],
    totalPage: json["totalPage"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "limit": limit,
    "page": page,
    "totalPage": totalPage,
  };
}

class PostData {
  String id;
  User user;
  List<String> photos;
  String description;
  String address;
  Location location;
  String clickerType;
  String privacy;
  String status;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;

  PostData({
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
  });

  factory PostData.fromJson(Map<String, dynamic> json) => PostData(
    id: json["_id"],
    user: User.fromJson(json["user"]),
    photos: List<String>.from(json["photos"].map((x) => x)),
    description: json["description"],
    address: json["address"],
    location: Location.fromJson(json["location"]),
    clickerType: json["clickerType"],
    privacy: json["privacy"],
    status: json["status"],
    isDeleted: json["isDeleted"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user.toJson(),
    "photos": List<dynamic>.from(photos.map((x) => x)),
    "description": description,
    "address": address,
    "location": location.toJson(),
    "clickerType": clickerType,
    "privacy": privacy,
    "status": status,
    "isDeleted": isDeleted,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class User {
  String id;
  String name;
  String email;
  String image;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "image": image,
  };
}

class Location {
  String type;
  List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: List<double>.from(
        json["coordinates"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}
