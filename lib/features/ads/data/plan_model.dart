class PlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String appleProductId;
  final String googleProductId;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.appleProductId,
    required this.googleProductId,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      appleProductId: json['appleProductId'] ?? '',
      googleProductId: json['googleProductId'] ?? '',
    );
  }
}
