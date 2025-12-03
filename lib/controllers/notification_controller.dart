import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/models/notification_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/routes/app_routes.dart';
import 'package:messanger/services/firestore_service.dart';
import 'package:messanger/theme/app_theme.dart';

class NotificationController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<NotificationModel> get notifications => _notifications;

  Map<String, UserModel> get users => _users;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _loadUsers();
  }

  void _loadNotifications() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _notifications.bindStream(
        _firestoreService.getNotificationsStream(currentUserId),
      );
    }
  }

  void _loadUsers() {
    _users.bindStream(
      _firestoreService.getAllUsersStream().map((userList) {
        Map<String, UserModel> userMap = {};
        for (var user in userList) {
          userMap[user.id] = user;
        }
        return userMap;
      }),
    );
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> markAsRead(NotificationModel notification) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _firestoreService.markNotificationAsRead(notification.id);

      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _notifications.refresh();
      }

      Get.snackbar(
        'Success',
        'Notification marked as read',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to mark notification as read: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        await _firestoreService.markAllNotificationsAsRead(currentUserId);

        // Update all local notifications
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = _notifications[i].copyWith(isRead: true);
          }
        }
        _notifications.refresh();
      }

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to mark all notifications as read: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _firestoreService.deleteNotification(notification.id);

      // Remove from local list
      _notifications.removeWhere((n) => n.id == notification.id);

      Get.snackbar(
        'Success',
        'Notification deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    markAsRead(notification);
    switch (notification.type) {
      case NotificationType.friendRequest:
        Get.toNamed(AppRoutes.friendRequests);
        break;

      case NotificationType.friendRequestAccept:
      case NotificationType.friendRequestDecline:
        Get.toNamed(AppRoutes.friends);

      case NotificationType.newMessage:
        final userId = notification.data['userId'];
        if (userId != null) {
          final user = getUser(userId);
          if (user != null) {
            Get.toNamed(AppRoutes.chat, arguments: {'otherUser': user});
          }
        }
        break;

      case NotificationType.friendRemove:
        break;
    }
  }

  String getNotificationTitle(NotificationModel notification) {
    return notification.title;
  }

  String getNotificationBody(NotificationModel notification) {
    return notification.body;
  }

  int getUnreadCount() {
    return _notifications.where((notifications) => !notifications.isRead).length;
  }

  String getNotificationTimeText(DateTime createdAt) {
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

  IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendRequestAccept:
        return Icons.check_circle_outline;
      case NotificationType.friendRequestDecline:
        return Icons.cancel;
      case NotificationType.friendRemove:
        return Icons.person_remove;

      case NotificationType.newMessage:
        return Icons.message;
    }
  }

  Color getNotificationIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
        return AppTheme.primaryColor;
      case NotificationType.friendRequestAccept:
        return AppTheme.successColor;
      case NotificationType.friendRequestDecline:
        return AppTheme.errorColor;
      case NotificationType.friendRemove:
        return AppTheme.errorColor;

      case NotificationType.newMessage:
        return AppTheme.secondaryColor;
    }
  }

  void clearError() {
    _error.value = '';
  }

}
