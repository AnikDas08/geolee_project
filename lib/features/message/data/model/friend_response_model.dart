// This model file handles the /friendships/my-friends API response

class FriendsResponse {
  final bool success;
  final String message;
  final Pagination pagination;
  final List<FriendData> data;

  FriendsResponse({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory FriendsResponse.fromJson(Map<String, dynamic> json) {
    return FriendsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => FriendData.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'pagination': pagination.toJson(),
      'data': data.map((item) => item.toJson()).toList(),
    };
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
      page: json['page'] ?? 1,
      totalPage: json['totalPage'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'limit': limit,
      'page': page,
      'totalPage': totalPage,
    };
  }
}

class FriendData {
  final String id; // _id of the friendship record
  final Friend friend;
  final String createdAt;
  final String updatedAt;

  FriendData({
    required this.id,
    required this.friend,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendData.fromJson(Map<String, dynamic> json) {
    return FriendData(
      id: json['_id'] ?? '',
      friend: Friend.fromJson(json['friend'] ?? {}),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'friend': friend.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Friend {
  final String id; // _id of the user
  final String name;
  final String email;
  final String image;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
    };
  }
}