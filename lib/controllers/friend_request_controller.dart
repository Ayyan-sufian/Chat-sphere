import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/models/friend_request_model.dart';
import 'package:messanger/models/friendship_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/services/firestore_service.dart';

class FriendRequestController extends GetxController{
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<FriendRequestModel> _receivedRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, bool> _requestLoadingStates = <String, bool>{}.obs;

  final RxInt _selectedTabIndex = 0.obs;

  // Getters
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
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      // Load received friend requests
      _receivedRequests.bindStream(
        _firestoreService.getFriendRequestsStream(currentUserId),
      );

      // Load sent friend requests
      _sentRequests.bindStream(
        _firestoreService.getSentFriendRequestsStream(currentUserId),
      );
    }
  }

  void _loadUser(){
    _users.bindStream(
      _firestoreService.getAllUsersStream().map((usersList) {
        Map<String, UserModel> userMap = {};
        for (var user in usersList){
          userMap[user.id] = user;
        }
        return userMap;
      })
    );
  }

  void changeTab(int index){
    _selectedTabIndex.value = index;
  }

  UserModel? getUser(String userId){
    return _users[userId];
  }

  Future<void> acceptFriendRequest(FriendRequestModel request) async {
    try {
      _requestLoadingStates[request.id] = true;
      _requestLoadingStates.refresh();
      _error.value = '';

      // Update UI immediately
      final index = _receivedRequests.indexWhere((req) => req.id == request.id);
      if (index != -1) {
        _receivedRequests[index] = FriendRequestModel(
          id: request.id,
          senderId: request.senderId,
          receiverId: request.receiverId,
          status: FriendRequestStatus.accepted,
          createdAt: request.createdAt,
          respondedAt: DateTime.now(),
          message: request.message,
        );
        _receivedRequests.refresh();
      }

      await _firestoreService.respondToFriendRequest(
        request.id,
        FriendRequestStatus.accepted,
      );

      // Remove from received requests list after successful update
      _receivedRequests.removeWhere((req) => req.id == request.id);
      
      Get.snackbar(
        'Success',
        'Friend request accepted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to accept friend request: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _requestLoadingStates.remove(request.id);
      _requestLoadingStates.refresh();
    }
  }

  Future<void> declineFriendRequest(FriendRequestModel request) async {
    try {
      _requestLoadingStates[request.id] = true;
      _requestLoadingStates.refresh();
      _error.value = '';

      // Update UI immediately
      final index = _receivedRequests.indexWhere((req) => req.id == request.id);
      if (index != -1) {
        _receivedRequests[index] = FriendRequestModel(
          id: request.id,
          senderId: request.senderId,
          receiverId: request.receiverId,
          status: FriendRequestStatus.declined,
          createdAt: request.createdAt,
          respondedAt: DateTime.now(),
          message: request.message,
        );
        _receivedRequests.refresh();
      }

      await _firestoreService.respondToFriendRequest(
        request.id,
        FriendRequestStatus.declined,
      );

      // Remove from received requests list after successful update
      _receivedRequests.removeWhere((req) => req.id == request.id);
      
      Get.snackbar(
        'Success',
        'Friend request declined',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to decline friend request: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _requestLoadingStates.remove(request.id);
      _requestLoadingStates.refresh();
    }
  }

  Future<void> unblockUser(String userId) async{
    try{
      _isLoading.value = true;
      await _firestoreService.unBlockUser(_authController.user!.uid, userId);
      Get.snackbar('Success', 'User unblocked successfully');
    }
    catch (e){
      print(e.toString());
      _error.value = 'Failed to unblocked user';
    }finally{
      _isLoading.value = false;
    }
  }

  Future<void> cancelSentRequest(String requestId) async {
    try {
      _requestLoadingStates[requestId] = true;
      _requestLoadingStates.refresh();
      _error.value = '';

      // Update UI immediately
      _sentRequests.removeWhere((req) => req.id == requestId);
      _sentRequests.refresh();

      await _firestoreService.cancelFriendRequest(requestId);

      Get.snackbar(
        'Success',
        'Friend request cancelled',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to cancel friend request: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _requestLoadingStates.remove(requestId);
      _requestLoadingStates.refresh();
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      if (_users.containsKey(userId)) {
        return _users[userId];
      }

      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        _users[userId] = user;
      }
      return user;
    } catch (e) {
      _error.value = e.toString();
      return null;
    }
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

  @override
  void onClose() {
    _receivedRequests.close();
    _sentRequests.close();
    _users.close();
    _isLoading.close();
    _error.close();
    _requestLoadingStates.close();
    super.onClose();
  }
}