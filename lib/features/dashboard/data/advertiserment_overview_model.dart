class AdvertisementOverviewResponse {
  final bool success;
  final String message;
  final AdvertisementOverviewData data;

  AdvertisementOverviewResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdvertisementOverviewResponse.fromJson(Map<String, dynamic> json) {
    return AdvertisementOverviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AdvertisementOverviewData.fromJson(json['data'] ?? {}),
    );
  }
}


class AdvertisementOverviewData {
  final int totalActiveAds;
  final int totalReachCount;
  final int totalClickCount;
  final int engagementRate;

  AdvertisementOverviewData({
    required this.totalActiveAds,
    required this.totalReachCount,
    required this.totalClickCount,
    required this.engagementRate,
  });

  factory AdvertisementOverviewData.fromJson(Map<String, dynamic> json) {
    return AdvertisementOverviewData(
      totalActiveAds: json['totalActiveAds'] ?? 0,
      totalReachCount: json['totalReachCount'] ?? 0,
      totalClickCount: json['totalClickCount'] ?? 0,
      engagementRate: json['engagementRate'] ?? 0,
    );
  }
}
