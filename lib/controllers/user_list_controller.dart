import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/models/friend_request_model.dart';
import 'package:messanger/models/friendship_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/routes/app_routes.dart';
import 'package:messanger/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

enum UserRelationshipStatus {
  none,
  friendRequestSent,
  friendRequestReceive,
  friends,
  blocked,
}

class UsersListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();

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
    // TODO: implement onInit
    super.onInit();
    _loadUsers();
    _loadRelationships();

    debounce(
      _sentRequests,
      (_) => filterUsers(),
      time: Duration(milliseconds: 300),
    );
  }

  void _loadUsers() async {
    _users.bindStream(_firestoreService.getAllUsersStream());

    ever(_users, (List<UserModel> userList) {
      final currentUserId = _authController.user?.uid;
      final otherUsers = userList.where((user) => user.id != currentUserId).toList();
      if (_searchQuery.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        filterUsers();
      }
    });

  }

  void _loadRelationships() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _sentRequests.bindStream(
        _firestoreService.getSentFriendRequestsStream(currentUserId),
      );

      _receiveRequests.bindStream(
        _firestoreService.getFriendRequestsStream(currentUserId),
      );

      _friendships.bindStream(
        _firestoreService.getFriendsStream(currentUserId),
      );

      ever(_sentRequests, (_) {
        _updateAllRelationshipsStatus();
      });
      
      ever(_receiveRequests, (_) {
        _updateAllRelationshipsStatus();
      });
      
      ever(_friendships, (_) {
        _updateAllRelationshipsStatus();
      });
      
      ever(_users, (_) {
        _updateAllRelationshipsStatus();
      });
    }
  }

  void _updateAllRelationshipsStatus() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId == null) return;

    print('Updating all relationship statuses for ${_users.length} users');
    
    for (var user in _users) {
      if (user.id != currentUserId) {
        final status = _calculateUserRelationshipStatus(user.id);
        _userRelationships[user.id] = status;
        print('User ${user.displayName} (${user.id}) relationship status: $status');
      }
    }
    _userRelationships.refresh();
    print('Finished updating relationship statuses');
  }

  UserRelationshipStatus _calculateUserRelationshipStatus(String userId) {
    final currentUserId = _authController.user?.uid;

    if (currentUserId == null) return UserRelationshipStatus.none;

    print('Calculating relationship status for user $userId');
    print('Current user: $currentUserId');
    print('Friendships count: ${_friendships.length}');
    print('Sent requests count: ${_sentRequests.length}');
    print('Received requests count: ${_receiveRequests.length}');

    final friendship = _friendships.firstWhereOrNull(
      (friendship) =>
          (friendship.user1Id == currentUserId && friendship.user2Id == userId) ||
          (friendship.user1Id == userId && friendship.user2Id == currentUserId),
    );

    if (friendship != null) {
      print('Found friendship with user $userId');
      if (friendship.isBlocked) {
        print('Friendship is blocked');
        return UserRelationshipStatus.blocked;
      } else {
        print('Friendship is active');
        return UserRelationshipStatus.friends;
      }
    }
    
    final sentRequest = _sentRequests.firstWhereOrNull(
      (request) => request.receiverId == userId && request.status == FriendRequestStatus.pending,
    );

    if (sentRequest != null) {
      print('Found sent request to user $userId');
      return UserRelationshipStatus.friendRequestSent;
    }

    final receiveRequest = _receiveRequests.firstWhereOrNull(
      (request) => request.senderId == userId && request.status == FriendRequestStatus.pending,
    );

    if (receiveRequest != null) {
      print('Found received request from user $userId');
      return UserRelationshipStatus.friendRequestReceive;
    }

    print('No relationship found with user $userId');
    return UserRelationshipStatus.none;

  }

  void filterUsers() {
    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredUsers.value = _users.where((user) => user.id != currentUserId).toList();
    } else {
      _filteredUsers.value = _users
          .where((user) {
            return user.displayName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query);
          }).toList();
    } 

  }


  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> sendFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      print('Sending friend request from $currentUserId to ${user.id} (${user.displayName})');

      if (currentUserId != null) {
        final request = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: user.id,
          status: FriendRequestStatus.pending,
          createdAt: DateTime.now(),
        );
        _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
        _userRelationships.refresh();
        print('Updated local relationship status for ${user.id} to friendRequestSent');

        await _firestoreService.sendFriendRequest(request);
        print('Friend request sent to Firestore');
        
        // Give streams time to update before refreshing relationships
        await Future.delayed(Duration(milliseconds: 100));
        // Refresh relationships to ensure UI is updated
        _updateAllRelationshipsStatus();
        
        Get.snackbar('Success', "Friend request sent to ${user.displayName}");
      }
    } catch (e) {
      print('Error sending friend request: $e');
      _userRelationships[user.id] = UserRelationshipStatus.none;
      _error.value = e.toString();
      Get.snackbar('Error','Failed to send friend request');
    } finally {
      _isLoading.value = false;
    }
  }


  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;

      final currentUserId = _authController.user?.uid;
      if (currentUserId == null) return;

      // Find request safely
      final request = _sentRequests.firstWhereOrNull(
            (r) =>
        r.receiverId == user.id &&
            r.senderId == currentUserId &&
            r.status == FriendRequestStatus.pending,
      );

      if (request == null) {
        print("CancelFriendRequest: No pending request found.");
        Get.snackbar(
          'Info',
          'No pending friend request found.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }

      // Update UI instantly
      _userRelationships[user.id] = UserRelationshipStatus.none;
      _userRelationships.refresh(); // <-- VERY IMPORTANT

      // Cancel in Firestore
      await _firestoreService.cancelFriendRequest(request.id);

      // Remove from list locally
      _sentRequests.remove(request);
      _sentRequests.refresh();  // <-- update list for UI

      // Show success
      Get.snackbar(
        'Success',
        'Friend request cancelled for ${user.displayName}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      print("CancelFriendRequest Error: $e");

      _userRelationships[user.id] = UserRelationshipStatus.none;
      _userRelationships.refresh();

      Get.snackbar(
        'Error',
        'Failed to cancel friend request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }


  Future<void> acceptFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _receiveRequests.firstWhereOrNull(
          (request) => request.senderId == user.id && request.status == FriendRequestStatus.pending,
        );

        if (request != null) {
          _userRelationships[user.id] = UserRelationshipStatus.friends;
          _userRelationships.refresh();

          await _firestoreService.respondToFriendRequest(
            request.id,
            FriendRequestStatus.accepted,
          );
          
          // Remove the request from the list
          _receiveRequests.remove(request);
          _receiveRequests.refresh();
          
          Get.snackbar('Success', "Friend request accepted from ${user.displayName}");
        }
      }
      
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to accept friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        // Find the correct request to decline
        final request = _receiveRequests.firstWhereOrNull(
          (request) => request.senderId == user.id && request.status == FriendRequestStatus.pending,
        );
        if (request != null) {
          _userRelationships[user.id] = UserRelationshipStatus.none;
          _userRelationships.refresh();
          
          await _firestoreService.respondToFriendRequest(
            request.id,
            FriendRequestStatus.declined,
          );
          
          // Remove from local list
          _receiveRequests.remove(request);
          _receiveRequests.refresh();
          
          Get.snackbar('Success', "Friend request declined");
        } else {
          Get.snackbar('Info', "No pending friend request found");
        }
      } 
    
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to decline friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final relationship = _userRelationships[user.id] ?? UserRelationshipStatus.none;
        if (relationship != UserRelationshipStatus.friends) {
          Get.snackbar('Info', "You can only start a chat with friends");
          return;
        }

        final chatId = await _firestoreService.createOrGetChat(currentUserId, user.id);

        if (chatId != null) {
          Get.snackbar('Success', "Chat started");
          Get.toNamed(AppRoutes.chat, arguments: { 'chatId': chatId, 'user': user });
        }
      }
    } catch (e) {
      _error.value = e.toString();
      print(e.toString());
      Get.snackbar('Error','Failed to start chat');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshUsers() async {
    final currentUserId = _authController.user?.uid;
    
    if (currentUserId != null) {
      _loadUsers();
      _loadRelationships();
    }
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
      default:
        return 'Add Friend';
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
      default:
        return Icons.add;
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
      default:
        return Colors.blue;
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