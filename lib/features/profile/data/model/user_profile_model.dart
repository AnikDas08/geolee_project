class UserProfileModel{
  bool? success;
  String? message;
  UserProfileDataModel? data;

  UserProfileModel({this.success, this.message, this.data});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new UserProfileDataModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserProfileDataModel {
  Location? location;
  String? sId;
  String? name;
  String? role;
  String? email;
  String? image;
  Null? gender;
  Null? dob;
  String? bio;
  String? privacy;
  String? address;
  String? status;
  bool? isOnline;
  bool? isVerified;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? iV;

  UserProfileDataModel(
      {this.location,
        this.sId,
        this.name,
        this.role,
        this.email,
        this.image,
        this.gender,
        this.dob,
        this.bio,
        this.privacy,
        this.address,
        this.status,
        this.isOnline,
        this.isVerified,
        this.isDeleted,
        this.createdAt,
        this.updatedAt,
        this.iV});

  UserProfileDataModel.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    name = json['name'];
    role = json['role'];
    email = json['email'];
    image = json['image'];
    gender = json['gender'];
    dob = json['dob'];
    bio = json['bio'];
    privacy = json['privacy'];
    address = json['address'];
    status = json['status'];
    isOnline = json['isOnline'];
    isVerified = json['isVerified'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['role'] = this.role;
    data['email'] = this.email;
    data['image'] = this.image;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    data['bio'] = this.bio;
    data['privacy'] = this.privacy;
    data['address'] = this.address;
    data['status'] = this.status;
    data['isOnline'] = this.isOnline;
    data['isVerified'] = this.isVerified;
    data['isDeleted'] = this.isDeleted;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Location {
  String? type;
  List<int>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
