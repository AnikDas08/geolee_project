class UserModel {
  final Location location;
  final String id;
  final String name;
  final String role;
  final String email;
  final String image;
  final String gender;
  final DateTime dob;
  final String bio;
  final String privacy;
  final String address;
  final String status;
  final bool isOnline;
  final bool isVerified;
  final bool isDeleted;
  final bool isLocationVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final Advertiser advertiser;

  const UserModel({
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
    required this.isLocationVisible,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.advertiser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    location: Location.fromJson(json["location"] ?? {}),
    id: json["_id"] ?? "",
    name: json["name"] ?? "",
    role: json["role"] ?? "",
    email: json["email"] ?? "",
    image: json["image"] ?? "",
    gender: json["gender"] ?? "",
    dob: DateTime.tryParse(json["dob"] ?? '') ?? DateTime.now(),
    bio: json["bio"] ?? "",
    privacy: json["privacy"] ?? "public",
    address: json["address"] ?? "",
    status: json["status"] ?? "inactive",
    isOnline: json["isOnline"] ?? false,
    isVerified: json["isVerified"] ?? false,
    isDeleted: json["isDeleted"] ?? false,
    isLocationVisible: json["isLocationVisible"] ?? false,
    createdAt: DateTime.tryParse(json["createdAt"] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json["updatedAt"] ?? '') ?? DateTime.now(),
    v: json["__v"] ?? 0,
    advertiser: Advertiser.fromJson(json["advertiser"] ?? {}),
  );
}

class Location {
  final String type;
  final double lat;
  final double long;

  const Location({required this.type, required this.lat, required this.long});

  factory Location.fromJson(Map<String, dynamic> json) {
    double latitude = 0.0;
    double longitude = 0.0;

    final coordinates = json["coordinates"];

    if (coordinates is List && coordinates.length >= 2) {
      longitude = coordinates[0].toDouble();
      latitude = coordinates[1].toDouble();
    }

    return Location(
      type: json["type"] ?? "Point",
      lat: latitude,
      long: longitude,
    );
  }

  factory Location.empty() =>
      const Location(type: "Point", lat: 0.0, long: 0.0);
}

class Advertiser {
  final String id;
  final String user;
  final String businessName;
  final String businessType;
  final String logo;
  final String licenseNumber;
  final String phone;
  final String bio;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  const Advertiser({
    required this.id,
    required this.user,
    required this.businessName,
    required this.businessType,
    required this.logo,
    required this.licenseNumber,
    required this.phone,
    required this.bio,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Advertiser.fromJson(Map<String, dynamic> json) => Advertiser(
    id: json["_id"] ?? "",
    user: json["user"] ?? "",
    businessName: json["businessName"] ?? "",
    businessType: json["businessType"] ?? "",
    logo: json["logo"] ?? "",
    licenseNumber: json["licenseNumber"] ?? "",
    phone: json["phone"] ?? "",
    bio: json["bio"] ?? "",
    isDeleted: json["isDeleted"] ?? false,
    createdAt: DateTime.tryParse(json["createdAt"] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    v: json["__v"] ?? 0,
  );
}
