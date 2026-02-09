class AdBannerModel {
  final String id;
  final String image;

  AdBannerModel({required this.id, required this.image});

  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    return AdBannerModel(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
    );
  }
}