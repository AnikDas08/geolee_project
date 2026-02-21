class GroupMember {
  final String id;
  final String name;
  final String? image;

  GroupMember({
    required this.id,
    required this.name,
    this.image,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['_id'] ?? '',
      name: json['chatName'] ?? json['name'] ?? 'Unknown',
      image: json['avatarUrl'],
    );
  }
}