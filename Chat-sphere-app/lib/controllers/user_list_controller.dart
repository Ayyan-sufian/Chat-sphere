import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/friend_request_model.dart';
import '../models/friendship_model.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import 'auth_controller.dart';

enum UserRelationshipStatus {
  none,
  friendRequestSent,
  friendRequestReceive,
  friends,
  blocked,
}

class UsersListController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _error = ''.obs;
  final RxMap<String, UserRelationshipStatus> _userRelationships =
      <String, UserRelationshipStatus>{}.obs;

  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receiveRequests =
      <FriendRequestModel>[].obs;

  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;

  List<UserModel> get users => _users;

  List<UserModel> get filteredUsers => _filteredUsers;

  bool get isLoading => _isLoading.value;

  String get searchQuery => _searchQuery.value;

  String get error => _error.value;

  Map<String, UserRelationshipStatus> get userRelationships =>
      _userRelationships;

  @override
  void onInit() {
    super.onInit();
    _refreshData();
  }

  void _refreshData() {
    final db = MockDatabase.instance;
    final currentUserId = _authController.currentUserId;

    _users.value = List<UserModel>.from(db.users);
    _sentRequests.value =
        db.friendRequests.where((r) => r.senderId == currentUserId).toList();
    _receiveRequests.value =
        db.friendRequests.where((r) => r.receiverId == currentUserId).toList();
    _friendships.value = List<FriendshipModel>.from(db.friendships);

    _updateAllRelationshipsStatus();
    filterUsers();
  }

  void _updateAllRelationshipsStatus() {
    final currentUserId = _authController.currentUserId;

    for (final user in _users) {
      if (user.id != currentUserId) {
        _userRelationships[user.id] = _calculateUserRelationshipStatus(user.id);
      }
    }
    _userRelationships.refresh();
  }

  UserRelationshipStatus _calculateUserRelationshipStatus(String userId) {
    final currentUserId = _authController.currentUserId;

    FriendshipModel? friendship;
    for (final item in _friendships) {
      if ((item.user1Id == currentUserId && item.user2Id == userId) ||
          (item.user1Id == userId && item.user2Id == currentUserId)) {
        friendship = item;
        break;
      }
    }

    if (friendship != null) {
      return friendship.isBlocked
          ? UserRelationshipStatus.blocked
          : UserRelationshipStatus.friends;
    }

    final hasSentRequest = _sentRequests.any(
      (request) =>
          request.receiverId == userId &&
          request.status == FriendRequestStatus.pending,
    );
    if (hasSentRequest) {
      return UserRelationshipStatus.friendRequestSent;
    }

    final hasReceivedRequest = _receiveRequests.any(
      (request) =>
          request.senderId == userId &&
          request.status == FriendRequestStatus.pending,
    );
    if (hasReceivedRequest) {
      return UserRelationshipStatus.friendRequestReceive;
    }

    return UserRelationshipStatus.none;
  }

  void filterUsers() {
    final currentUserId = _authController.currentUserId;
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredUsers.value =
          _users.where((user) => user.id != currentUserId).toList();
    } else {
      _filteredUsers.value = _users.where((user) {
        if (user.id == currentUserId) return false;
        return user.displayName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    filterUsers();
  }

  void clearSearch() {
    _searchQuery.value = '';
    filterUsers();
  }

  Future<void> sendFriendRequest(UserModel user) async {
    MockDatabase.instance.sendFriendRequest(user.id);
    _refreshData();
    Get.snackbar('Success', 'Friend request sent to ${user.displayName}');
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    final currentUserId = _authController.currentUserId;
    FriendRequestModel? request;
    for (final item in _sentRequests) {
      if (item.receiverId == user.id &&
          item.senderId == currentUserId &&
          item.status == FriendRequestStatus.pending) {
        request = item;
        break;
      }
    }

    if (request == null) {
      Get.snackbar(
        'Info',
        'No pending friend request found.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    MockDatabase.instance.cancelFriendRequest(request.id);
    _refreshData();
    Get.snackbar(
      'Success',
      'Friend request cancelled for ${user.displayName}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> acceptFriendRequest(UserModel user) async {
    FriendRequestModel? request;
    for (final item in _receiveRequests) {
      if (item.senderId == user.id &&
          item.status == FriendRequestStatus.pending) {
        request = item;
        break;
      }
    }

    if (request != null) {
      MockDatabase.instance
          .respondToFriendRequest(request.id, FriendRequestStatus.accepted);
      _refreshData();
      Get.snackbar(
        'Success',
        'Friend request accepted from ${user.displayName}',
      );
    }
  }

  Future<void> deleteFriendRequest(UserModel user) async {
    FriendRequestModel? request;
    for (final item in _receiveRequests) {
      if (item.senderId == user.id &&
          item.status == FriendRequestStatus.pending) {
        request = item;
        break;
      }
    }

    if (request != null) {
      MockDatabase.instance
          .respondToFriendRequest(request.id, FriendRequestStatus.declined);
      _refreshData();
      Get.snackbar('Success', 'Friend request declined');
    } else {
      Get.snackbar('Info', 'No pending friend request found');
    }
  }

  Future<void> startChat(UserModel user) async {
    final relationship =
        _userRelationships[user.id] ?? UserRelationshipStatus.none;
    if (relationship != UserRelationshipStatus.friends) {
      Get.snackbar('Info', 'You can only start a chat with friends');
      return;
    }

    final chat = MockDatabase.instance.openChatWith(user);
    Get.toNamed(
      AppRoutes.chat,
      arguments: {'chatId': chat.id, 'otherUser': user},
    );
  }

  Future<void> refreshUsers() async {
    _refreshData();
  }

  UserRelationshipStatus getUserRelationshipStatus(String userId) {
    return _userRelationships[userId] ?? UserRelationshipStatus.none;
  }

  String getRelationshipButtonText(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return 'Add';
      case UserRelationshipStatus.friendRequestSent:
        return 'Request sent';
      case UserRelationshipStatus.friendRequestReceive:
        return 'Accept';
      case UserRelationshipStatus.friends:
        return 'Message';
      case UserRelationshipStatus.blocked:
        return 'Blocked';
    }
  }

  IconData getRelationshipButtonIcon(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Icons.person_add;
      case UserRelationshipStatus.friendRequestSent:
        return Icons.access_time;
      case UserRelationshipStatus.friendRequestReceive:
        return Icons.check;
      case UserRelationshipStatus.friends:
        return Icons.chat_bubble_outline;
      case UserRelationshipStatus.blocked:
        return Icons.block;
    }
  }

  Color getRelationshipButtonColor(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Colors.blue;
      case UserRelationshipStatus.friendRequestSent:
        return Colors.orange;
      case UserRelationshipStatus.friendRequestReceive:
        return Colors.green;
      case UserRelationshipStatus.friends:
        return Colors.blue;
      case UserRelationshipStatus.blocked:
        return Colors.redAccent;
    }
  }

  void handleRelationshipAction(UserModel user) {
    final status = getUserRelationshipStatus(user.id);

    switch (status) {
      case UserRelationshipStatus.none:
        sendFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestSent:
        cancelFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestReceive:
        acceptFriendRequest(user);
        break;
      case UserRelationshipStatus.friends:
        startChat(user);
        break;
      case UserRelationshipStatus.blocked:
        Get.snackbar('Error', "You can't message a blocked user");
        break;
    }
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
