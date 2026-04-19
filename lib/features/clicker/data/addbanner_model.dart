class AdBannerModel {
  final String id;
  final String title;
  final String image;
  final String? websiteUrl;
  final String? description;
  final String? businessName;
  final String? businessType;
  final String? phone;
  final String?focusArea;

  AdBannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.websiteUrl,
    this.description,
    this.businessName,
    this.businessType,
    this.phone, this.focusArea,
  });

  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    // The advertiser sub-object may hold businessName / businessType / phone
    final advertiser = json['advertiser'] as Map<String, dynamic>?;

    return AdBannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      websiteUrl: json['websiteUrl'],
      description: json['description'],
      businessName: advertiser?['businessName'] ?? json['businessName'],
      businessType: advertiser?['businessType'] ?? json['businessType'],
      phone: advertiser?['phone'] ?? json['phone'],
      focusArea: advertiser?['focusArea']?? json['focusArea']
    );
  }
}
