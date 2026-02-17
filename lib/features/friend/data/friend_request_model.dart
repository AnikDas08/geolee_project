class FriendModel {
  bool success;
  String message;
  Pagination pagination;
  List<FriendData> data;

  FriendModel({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    success: json["success"],
    message: json["message"],
    pagination: Pagination.fromJson(json["pagination"]),
    data: List<FriendData>.from(
      json["data"].map((x) => FriendData.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "pagination": pagination.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FriendData {
  String id;
  Sender sender; // sender info
  String receiver;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  FriendData({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendData.fromJson(Map<String, dynamic> json) => FriendData(
    id: json["_id"],
    sender: Sender.fromJson(json["sender"]),
    receiver: json["receiver"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sender": sender.toJson(),
    "receiver": receiver,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class Sender {
  String id;
  String name;
  String image;
  String bio;
  String address;

  Sender({
    required this.id,
    required this.name,
    required this.image,
    required this.bio,
    required this.address,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json["_id"],
    name: json["name"],
    image: json["image"],
    bio: json["bio"] ?? "",
    address: json["address"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
    "bio": bio,
    "address": address,
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
