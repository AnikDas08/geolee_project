class CreateGroupRequest {
  final List<String> participants;
  final String chatName;
  final String description;
  final String privacy;

  CreateGroupRequest({
    required this.participants,
    required this.chatName,
    required this.description,
    required this.privacy,
  });

  Map<String, dynamic> toJson() {
    return {
      "participants": participants,
      "chatName": chatName,
      "description": description,
      "privacy": privacy,
    };
  }
}