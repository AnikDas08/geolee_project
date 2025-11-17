class OfferAcceptModel {
  final bool? success;
  final String? message;
  final OfferAcceptData? data;

  OfferAcceptModel({this.success, this.message, this.data});

  factory OfferAcceptModel.fromJson(Map<String, dynamic> json) {
    return OfferAcceptModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? OfferAcceptData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class OfferAcceptData {
  final String id;
  final String chatId;
  final String service;
  final int customPrice;
  final String serviceDate;
  final String serviceTime;
  final String user;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int v;

  OfferAcceptData({
    required this.id,
    required this.chatId,
    required this.service,
    required this.customPrice,
    required this.serviceDate,
    required this.serviceTime,
    required this.user,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory OfferAcceptData.fromJson(Map<String, dynamic> json) {
    return OfferAcceptData(
      id: json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      service: json['service'] ?? '',
      customPrice: json['customPrice'] ?? 0,
      serviceDate: json['serviceDate'] ?? '',
      serviceTime: json['serviceTime'] ?? '',
      user: json['user'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'service': service,
      'customPrice': customPrice,
      'serviceDate': serviceDate,
      'serviceTime': serviceTime,
      'user': user,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
