import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/friend_request_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class FriendRequestController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<FriendRequestModel> _receivedRequests =
      <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, bool> _requestLoadingStates = <String, bool>{}.obs;

  final RxInt _selectedTabIndex = 0.obs;

  List<FriendRequestModel> get receivedRequests => _receivedRequests;
  List<FriendRequestModel> get sentRequests => _sentRequests;
  Map<String, UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  int get selectedTabIndex => _selectedTabIndex.value;
  Map<String, bool> get requestLoadingStates => _requestLoadingStates;

  @override
  void onInit() {
    super.onInit();
    _loadFriendRequests();
    _loadUser();
  }

  void _loadFriendRequests() {
    final currentUserId = _authController.currentUserId;
    final db = MockDatabase.instance;
    _receivedRequests.value =
        db.friendRequests.where((r) => r.receiverId == currentUserId).toList();
    _sentRequests.value =
        db.friendRequests.where((r) => r.senderId == currentUserId).toList();
  }

  void _loadUser() {
    _users.value = {
      for (final user in MockDatabase.instance.users) user.id: user,
    };
  }

  void changeTab(int index) {
    _selectedTabIndex.value = index;
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> acceptFriendRequest(FriendRequestModel request) async {
    _requestLoadingStates[request.id] = true;
    _requestLoadingStates.refresh();

    MockDatabase.instance
        .respondToFriendRequest(request.id, FriendRequestStatus.accepted);
    _loadFriendRequests();
    _requestLoadingStates.remove(request.id);
    _requestLoadingStates.refresh();

    Get.snackbar(
      'Success',
      'Friend request accepted',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> declineFriendRequest(FriendRequestModel request) async {
    _requestLoadingStates[request.id] = true;
    _requestLoadingStates.refresh();

    MockDatabase.instance
        .respondToFriendRequest(request.id, FriendRequestStatus.declined);
    _loadFriendRequests();
    _requestLoadingStates.remove(request.id);
    _requestLoadingStates.refresh();

    Get.snackbar(
      'Success',
      'Friend request declined',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> unblockUser(String userId) async {
    MockDatabase.instance.unblockUser(userId);
    Get.snackbar('Success', 'User unblocked successfully');
  }

  Future<void> cancelSentRequest(String requestId) async {
    _requestLoadingStates[requestId] = true;
    _requestLoadingStates.refresh();

    MockDatabase.instance.cancelFriendRequest(requestId);
    _loadFriendRequests();
    _requestLoadingStates.remove(requestId);
    _requestLoadingStates.refresh();

    Get.snackbar(
      'Success',
      'Friend request cancelled',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<UserModel?> getUserById(String userId) async {
    return _users[userId] ?? MockDatabase.instance.userById(userId);
  }

  String getRequestTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String getRequestStatus(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return 'Pending';
      case FriendRequestStatus.accepted:
        return 'Accepted';
      case FriendRequestStatus.declined:
        return 'Declined';
    }
  }

  Color getStatusColor(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return Colors.grey;
      case FriendRequestStatus.accepted:
        return Colors.green;
      case FriendRequestStatus.declined:
        return Colors.red;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
