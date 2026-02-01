class DisclaimerResponse {
  final String content;

  DisclaimerResponse({required this.content});

  factory DisclaimerResponse.fromJson(Map<String, dynamic> json) {
    return DisclaimerResponse(content: json['data']['content']);
  }
}
