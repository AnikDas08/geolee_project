class AdBannerModel {
  final String id;
  final String title;
  final String image;
  final String? websiteUrl; // Ensure this is here

  AdBannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.websiteUrl,
  });

  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    return AdBannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      websiteUrl: json['websiteUrl'], // Map from JSON
    );
  }
}