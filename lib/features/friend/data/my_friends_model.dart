class MyFriendsModel {
 final bool? success;
 final String? message;
 final Pagination? pagination;
 final List<MyFriendsData>? data;

const  MyFriendsModel({this.success, this.message, this.pagination, this.data});

 factory MyFriendsModel.fromJson(dynamic json) {

   if(json == null){
     return const MyFriendsModel();
   }
   if(json is Map){
     return MyFriendsModel(message: json['message'], success:  json['success'], pagination: json['pagination'] is Map ? Pagination.fromJson(json['pagination']) : null ,

         data: json['data'] is List ? (json['data'] as List).map((e) =>MyFriendsData.fromJson(e)).toList() : []
     );
   }
   return const MyFriendsModel();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? total;
  int? limit;
  int? page;
  int? totalPage;

  Pagination({this.total, this.limit, this.page, this.totalPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    limit = json['limit'];
    page = json['page'];
    totalPage = json['totalPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['limit'] = this.limit;
    data['page'] = this.page;
    data['totalPage'] = this.totalPage;
    return data;
  }
}

class MyFriendsData {
  String? sId;
  FriendDataModel? friend;
  String? createdAt;
  String? updatedAt;

  MyFriendsData({this.sId, this.friend, this.createdAt, this.updatedAt});

  MyFriendsData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    friend =
    json['friend'] != null ? new FriendDataModel.fromJson(json['friend']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.friend != null) {
      data['friend'] = this.friend!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class FriendDataModel {
  String? sId;
  String? name;
  String? email;
  String? image;

  FriendDataModel({this.sId, this.name, this.email, this.image});

  FriendDataModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['image'] = this.image;
    return data;
  }
}
