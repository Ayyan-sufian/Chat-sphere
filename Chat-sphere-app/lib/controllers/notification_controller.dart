import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class NotificationController extends GetxController {
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
    _notifications.value =
        List<NotificationModel>.from(MockDatabase.instance.notifications);
  }

  void _loadUsers() {
    _users.value = {
      for (final user in MockDatabase.instance.users) user.id: user,
    };
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> markAsRead(NotificationModel notification) async {
    MockDatabase.instance.markNotificationRead(notification.id);
    _loadNotifications();
    Get.snackbar(
      'Success',
      'Notification marked as read',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> markAllAsRead() async {
    MockDatabase.instance.markAllNotificationsRead();
    _loadNotifications();
    Get.snackbar(
      'Success',
      'All notifications marked as read',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    MockDatabase.instance.deleteNotification(notification.id);
    _loadNotifications();
    Get.snackbar(
      'Success',
      'Notification deleted',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
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
        break;

      case NotificationType.newMessage:
        final userId = notification.data['userId'];
        if (userId != null) {
          final user = getUser(userId.toString());
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
    return _notifications.where((notification) => !notification.isRead).length;
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
