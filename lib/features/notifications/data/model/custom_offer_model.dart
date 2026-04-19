class CustomOfferModel {
  final bool? success;
  final String? message;
  final CustomOfferData? data;

  CustomOfferModel({this.success, this.message, this.data});

  factory CustomOfferModel.fromJson(Map<String, dynamic> json) {
    return CustomOfferModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? CustomOfferData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class CustomOfferData {
  final String? id;
  final String? chatId;
  final ServiceModel? service;
  final double? customPrice;
  final String? serviceDate;
  final String? serviceTime;
  final UserModel? user;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  CustomOfferData({
    this.id,
    this.chatId,
    this.service,
    this.customPrice,
    this.serviceDate,
    this.serviceTime,
    this.user,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomOfferData.fromJson(Map<String, dynamic> json) {
    return CustomOfferData(
      id: json['_id'],
      chatId: json['chatId'],
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      customPrice: json['customPrice']?.toDouble(),
      serviceDate: json['serviceDate'],
      serviceTime: json['serviceTime'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'service': service?.toJson(),
      'customPrice': customPrice,
      'serviceDate': serviceDate,
      'serviceTime': serviceTime,
      'user': user?.toJson(),
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class ServiceModel {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final String? category;
  final double? lat;
  final double? long;
  final String? serviceDate;
  final String? serviceTime;
  final double? price;
  final String? priority;
  final String? bookingStatus;
  final String? user;
  final String? createdAt;
  final String? updatedAt;

  ServiceModel({
    this.id,
    this.title,
    this.description,
    this.image,
    this.category,
    this.lat,
    this.long,
    this.serviceDate,
    this.serviceTime,
    this.price,
    this.priority,
    this.bookingStatus,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      category: json['category'],
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      serviceDate: json['serviceDate'],
      serviceTime: json['serviceTime'],
      price: json['price']?.toDouble(),
      priority: json['priority'],
      bookingStatus: json['bookingStatus'],
      user: json['user'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
      'lat': lat,
      'long': long,
      'serviceDate': serviceDate,
      'serviceTime': serviceTime,
      'price': price,
      'priority': priority,
      'bookingStatus': bookingStatus,
      'user': user,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? image;
  final List<String>? skill;

  UserModel({this.id, this.name, this.image, this.skill});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      skill:
          (json['skill'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'image': image, 'skill': skill};
  }
}
