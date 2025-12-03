import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/models/friendship_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/routes/app_routes.dart';
import 'package:messanger/services/firestore_service.dart';

class FriendsController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;

  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;

  StreamSubscription? _friendshipSubscription;

  List<FriendshipModel> get friendships => _friendships.toList();

  List<UserModel> get friends => _friends;

  List<UserModel> get filteredFriends => _filteredFriends;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadFriends();

    debounce(
      _searchQuery,
      (_) => _filteredFriends(),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    // TODO: implement onClose
    _friendshipSubscription?.cancel();
    super.onClose();
  }

  void _loadFriends() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _friendshipSubscription?.cancel();

      _friendshipSubscription = _firestoreService
          .getFriendsStream(currentUserId)
          .listen((friendshipList) {
            _friendships.value = friendshipList;
            _loadFriendDetails(currentUserId, friendshipList);
          });
    }
  }

  Future<void> _loadFriendDetails(
    String currentUserId,
    List<FriendshipModel> friendshipsList,
  ) async {
    try {
      _isLoading.value = true;

      List<UserModel> friendUser = [];

      final futures = friendshipsList.map((friendships) async {
        String friendId = friendships.getOtherUserId(currentUserId);
        return await _firestoreService.getUser(friendId);
      }).toList();

      final results = await Future.wait(futures);

      for (var friend in results) {
        if (friend != null) {
          friendUser.add(friend);
        }
      }

      _friends.value = friendUser;
      _filterFriends();
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterFriends() {
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredFriends.value = _friends;
    } else {
      _filteredFriends.value = _friends.where((friends) {
        return friends.displayName.toLowerCase().contains(query) ||
            friends.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query){
    _searchQuery.value = query;
  }

  void clearSearchQuery() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async{
    final currentUserId = _authController.user?.uid;
    
    if (currentUserId != null) {
      _loadFriends();
    }  
  }

  Future<void> removeFriend(UserModel friend) async{
    try{
      final result = await Get.dialog<bool>(AlertDialog(
        title: Text("Remove Friends"),
        content: Text("Are you sure you want to remove ${friend.displayName} form your friends list?"),
        actions: [
          TextButton(onPressed: () =>
        Navigator.pop(Get.context!, false), child: Text("Cancel")),
          TextButton(onPressed: () {
            Navigator.pop(Get.context!, true);
          },style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent
          ),
              child: Text("Remove"))
        ],
      ));
    if (result == true) {
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        await _firestoreService.removeFriendship(currentUserId, friend.id);
        // Simple
        Get.snackbar(
          'Success',
          'Friend removed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

      }
    }

    }catch(e){
      Get.snackbar(
        'Error',
        'Error removing friend: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }finally{
      refreshFriends();
      _isLoading.value = false;
    }
  }

  Future<void> blockFriend(UserModel friend) async{
    try{
      final result = await Get.dialog<bool>(AlertDialog(
        title: Text("Block Friend"),
        content: Text("Are you sure you want to block ${friend.displayName} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(Get.context!, true), child: Text("Block"))
        ],
      ));

      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _firestoreService.blockUser(currentUserId, friend.id);
        }
      }
    }catch(e){
      Get.snackbar('Error', 'Error blocking friend: ${e.toString()}');
    }
  }

  Future<void> startChat(UserModel friend) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        Get.toNamed(AppRoutes.chat, arguments: {'chatId': null, 'otherUser': friend, 'isNewChat': true});
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Error starting chat: ${e.toString()}');

    } finally {
      _isLoading.value = false;
    }
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
