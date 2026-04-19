class CheckoutSessionModel {
  final bool success;
  final String message;
  final CheckoutData data;

  CheckoutSessionModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CheckoutData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CheckoutData {
  final Submission submission;
  final String checkoutUrl;
  final int userBalance;

  CheckoutData({
    required this.submission,
    required this.checkoutUrl,
    required this.userBalance,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      submission: Submission.fromJson(json['submission'] ?? {}),
      checkoutUrl: json['checkoutUrl'] ?? '',
      userBalance: json['userBalance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submission': submission.toJson(),
      'checkoutUrl': checkoutUrl,
      'userBalance': userBalance,
    };
  }
}

class Submission {
  final String service;
  final String user;
  final String paymentIntentId;
  final String paymentStatus;
  final String id;
  final int v;

  Submission({
    required this.service,
    required this.user,
    required this.paymentIntentId,
    required this.paymentStatus,
    required this.id,
    required this.v,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      service: json['service'] ?? '',
      user: json['user'] ?? '',
      paymentIntentId: json['paymentIntentId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      id: json['_id'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service,
      'user': user,
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus,
      '_id': id,
      '__v': v,
    };
  }
}