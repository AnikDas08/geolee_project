class PlanModel {
  final String id;
  final String name;
  final double price;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
