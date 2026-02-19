import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFriendController extends GetxController {
  /// User lists
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];

  /// Loading states
  bool isLoading = false;

  /// Search controller
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  /// Search users
  void searchUsers(String query) {
    searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      filteredUsers = users;
    } else {
      filteredUsers = users.where((user) {
        final nameLower = user.name.toLowerCase();
        return nameLower.contains(searchQuery);
      }).toList();
    }

    update();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    filteredUsers = users;
    update();
  }

  /// Send friend request
  void sendFriendRequest(String userId) {
    final index = users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      users[index] = UserModel(
        id: users[index].id,
        name: users[index].name,
        image: users[index].image,
        isFriend: true,
      );

      // Update filtered list
      final filteredIndex = filteredUsers.indexWhere((user) => user.id == userId);
      if (filteredIndex != -1) {
        filteredUsers[filteredIndex] = UserModel(
          id: filteredUsers[filteredIndex].id,
          name: filteredUsers[filteredIndex].name,
          image: filteredUsers[filteredIndex].image,
          isFriend: true,
        );
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Friend request sent to ${users[index].name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      update();
    }
  }

  /// Load users (demo data)
  Future<void> loadUsers() async {
    isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 500));

    users = [
      UserModel(
        id: '1',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '2',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '3',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '4',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '5',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '6',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '7',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '8',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '9',
        name: 'Arlene McCoy',
        image: 'https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '10',
        name: 'John Smith',
        image: 'https://images.pexels.com/photos/1552108/pexels-photo-1552108.jpeg',
        isFriend: true,
      ),
      UserModel(
        id: '11',
        name: 'Jane Doe',
        image: 'https://images.pexels.com/photos/1542085/pexels-photo-1542085.jpeg',
        isFriend: false,
      ),
      UserModel(
        id: '12',
        name: 'Mike Johnson',
        image: 'https://images.pexels.com/photos/1516680/pexels-photo-1516680.jpeg',
        isFriend: true,
      ),
    ];

    filteredUsers = users;
    isLoading = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

/// User Model
class UserModel {
  final String id;
  final String name;
  final String image;
  final bool isFriend;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFriend,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isFriend: json['isFriend'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'isFriend': isFriend,
    };
  }
}