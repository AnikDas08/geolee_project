// To parse this JSON data, do
//
//     final userProfileModel = userProfileModelFromJson(jsonString);

import 'dart:convert';

UserProfileModel userProfileModelFromJson(String str) => UserProfileModel.fromJson(json.decode(str));

String userProfileModelToJson(UserProfileModel data) => json.encode(data.toJson());

class UserProfileModel {
  bool success;
  String message;
  Data data;

  UserProfileModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
    success: json["success"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Location location;
  String id;
  String name;
  String role;
  String email;
  String image;
  String gender;
  DateTime dob;
  String bio;
  String privacy;
  String address;
  String status;
  bool isOnline;
  bool isVerified;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Data({
    required this.location,
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.image,
    required this.gender,
    required this.dob,
    required this.bio,
    required this.privacy,
    required this.address,
    required this.status,
    required this.isOnline,
    required this.isVerified,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    location: Location.fromJson(json["location"]),
    id: json["_id"],
    name: json["name"]??"User",
    role: json["role"],
    email: json["email"],
    image: json["image"],
    gender: json["gender"],
    dob: DateTime.parse(json["dob"]),
    bio: json["bio"],
    privacy: json["privacy"],
    address: json["address"],
    status: json["status"],
    isOnline: json["isOnline"],
    isVerified: json["isVerified"],
    isDeleted: json["isDeleted"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "location": location.toJson(),
    "_id": id,
    "name": name,
    "role": role,
    "email": email,
    "image": image,
    "gender": gender,
    "dob": dob.toIso8601String(),
    "bio": bio,
    "privacy": privacy,
    "address": address,
    "status": status,
    "isOnline": isOnline,
    "isVerified": isVerified,
    "isDeleted": isDeleted,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class Location {
  String type;
  List<int> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: List<int>.from(json["coordinates"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}
