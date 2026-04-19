class FriendModel {
  final String id;
  final String userName;
  final String avatar;
  bool isFriendRequestSent;

  FriendModel({
    required this.id,
    required this.userName,
    required this.avatar,
    this.isFriendRequestSent = false,
  });
}