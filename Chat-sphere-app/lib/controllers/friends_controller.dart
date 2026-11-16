import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import 'auth_controller.dart';

class FriendsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;

  List<UserModel> get friends => _friends;

  List<UserModel> get filteredFriends => _filteredFriends;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _loadFriends();

    debounce(
      _searchQuery,
      (_) => _filterFriends(),
      time: const Duration(milliseconds: 300),
    );
  }

  void _loadFriends() {
    final currentUserId = _authController.currentUserId;
    final friendIds = <String>{};
    for (final friendship in MockDatabase.instance.friendships) {
      friendIds.add(friendship.getOtherUserId(currentUserId));
    }

    _friends.value = MockDatabase.instance.users
        .where((user) => friendIds.contains(user.id))
        .toList();
    _filterFriends();
  }

  void _filterFriends() {
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredFriends.value = _friends;
    } else {
      _filteredFriends.value = _friends.where((friend) {
        return friend.displayName.toLowerCase().contains(query) ||
            friend.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearchQuery() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async {
    _loadFriends();
  }

  Future<void> removeFriend(UserModel friend) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Friends'),
        content: Text(
          'Are you sure you want to remove ${friend.displayName} form your friends list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (result == true) {
      MockDatabase.instance.removeFriendship(friend.id);
      _loadFriends();
      Get.snackbar(
        'Success',
        'Friend removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> blockFriend(UserModel friend) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Block Friend'),
        content: Text('Are you sure you want to block ${friend.displayName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (result == true) {
      MockDatabase.instance.blockFriend(friend.id);
      Get.snackbar('Success', 'Friend blocked');
    }
  }

  Future<void> startChat(UserModel friend) async {
    final chat = MockDatabase.instance.openChatWith(friend);
    Get.toNamed(
      AppRoutes.chat,
      arguments: {'chatId': chat.id, 'otherUser': friend, 'isNewChat': true},
    );
  }

  void openFriendRequest() {
    Get.toNamed(AppRoutes.friendRequests);
  }

  String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return 'Last seen ${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inDays} days ago';
      } else {
        return 'Last seen on ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }

  void clearError() {
    _error.value = '';
  }
}
