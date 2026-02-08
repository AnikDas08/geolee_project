class PostResponseById {
  final bool success;
  final String message;
  final Pagination pagination;
  final List<PostById> data;

  PostResponseById({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory PostResponseById.fromJson(Map<String, dynamic> json) {
    return PostResponseById(
      success: json['success'],
      message: json['message'],
      pagination: Pagination.fromJson(json['pagination']),
      data: List<PostById>.from(
        json['data'].map((x) => PostById.fromJson(x)),
      ),
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
      total: json['total'],
      limit: json['limit'],
      page: json['page'],
      totalPage: json['totalPage'],
    );
  }
}
class PostById {
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

  PostById({
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

  factory PostById.fromJson(Map<String, dynamic> json) {
    return PostById(
      id: json['_id'],
      user: User.fromJson(json['user']),
      photos: List<String>.from(json['photos']),
      description: json['description'],
      address: json['address'],
      location: Location.fromJson(json['location']),
      clickerType: json['clickerType'],
      privacy: json['privacy'],
      status: json['status'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
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
      type: json['type'],
      coordinates: List<double>.from(
        json['coordinates'].map((x) => x.toDouble()),
      ),
    );
  }
}
