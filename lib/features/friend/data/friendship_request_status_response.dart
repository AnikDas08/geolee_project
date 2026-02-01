class FriendshipStatusResponse {
  final bool success;
  final String message;
  final FriendshipData data;

  FriendshipStatusResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FriendshipStatusResponse.fromJson(Map<String, dynamic> json) {
    return FriendshipStatusResponse(
      success: json['success'],
      message: json['message'],
      data: FriendshipData.fromJson(json['data']),
    );
  }
}

class FriendshipData {
  final bool isAlreadyFriend;
  final dynamic pendingFriendRequest;

  FriendshipData({
    required this.isAlreadyFriend,
    required this.pendingFriendRequest,
  });

  factory FriendshipData.fromJson(Map<String, dynamic> json) {
    return FriendshipData(
      isAlreadyFriend: json['isAlreadyFriend'],
      pendingFriendRequest: json['pendingFriendRequest'],
    );
  }
}
