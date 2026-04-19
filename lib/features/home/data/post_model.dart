// post_model.dart
import '../../clicker/data/all_post_model.dart';

class PostModel {
  bool success;
  String message;
  Pagination pagination;
  List<PostData> data;

  PostModel({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
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