class MyFriendsModel {
  final bool success;
  final String message;
  final Pagination? pagination;
  final List<MyFriendsData> data;

  MyFriendsModel({
    required this.success,
    required this.message,
    this.pagination,
    required this.data,
  });

  factory MyFriendsModel.fromJson(Map<String, dynamic> json) {
    return MyFriendsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? List<MyFriendsData>.from(
          json['data'].map((x) => MyFriendsData.fromJson(x)))
          : [],
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

class MyFriendsData {
  final String id;
  final FriendDataModel? friend;
  final String createdAt;
  final String updatedAt;

  MyFriendsData({
    required this.id,
    this.friend,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyFriendsData.fromJson(Map<String, dynamic> json) {
    return MyFriendsData(
      id: json['_id'] ?? '',
      friend: json['friend'] != null
          ? FriendDataModel.fromJson(json['friend'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class FriendDataModel {
  final String id;
  final String name;
  final String email;
  final String image;

  FriendDataModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory FriendDataModel.fromJson(Map<String, dynamic> json) {
    return FriendDataModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
