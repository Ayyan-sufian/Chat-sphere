import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/controllers/home_controller.dart';
import 'package:messanger/models/chat_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/theme/app_theme.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final UserModel otherUser;
  final String lastMessageTime;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.otherUser,
    required this.lastMessageTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.find<HomeController>();
    final currentUserId = authController.user?.uid ?? '';
    final unreadCount = chat.getUnreadCount(currentUserId);
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showChatOption(context, homeController),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: otherUser.photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              otherUser.photoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  otherUser.displayName.isNotEmpty
                                      ? otherUser.displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            otherUser.displayName.isNotEmpty
                                ? otherUser.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                  ),
                  if (otherUser.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 2, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherUser.displayName,
                            style: Theme.of(Get.context!).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessageTime.isNotEmpty)
                          Text(
                            lastMessageTime,
                            style: Theme.of(Get.context!).textTheme.bodySmall
                                ?.copyWith(
                                  color: unreadCount > 0
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSceTheme,

                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (chat.lastMessageSenderId == currentUserId) ...[
                          Icon(
                            _getSeenStatusIcon(),
                            size: 24,
                            color: _getSeenStatusColor(),
                          ),
                          SizedBox(width: 4),
                        ],

                        Expanded(
                          child: Text(
                            chat.lastMessage ?? 'No message yet',
                            style: Theme.of(Get.context!).textTheme.bodyMedium
                                ?.copyWith(
                                  color: unreadCount > 0
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSceTheme,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          SizedBox(height: 8),
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (chat.lastMessageSenderId == currentUserId) ...[
                      SizedBox(height: 2),
                      Text(
                        _getSeenStatusText(),
                        style: Theme.of(Get.context!).textTheme.bodySmall
                            ?.copyWith(
                              color: _getSeenStatusColor(),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSeenStatusIcon() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return Icons.done_all;
    } else {
      return Icons.done;
    }
  }

  Color _getSeenStatusColor() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return AppTheme.primaryColor;
    } else {
      return AppTheme.textSceTheme;
    }
  }

  String _getSeenStatusText() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return 'Seen';
    } else {
      return 'Delivered';
    }
  }

  void _showChatOption(BuildContext context, HomeController homeController) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSceTheme.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 20,),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red,),
              title: Text("Delete Chat"),
              subtitle: Text("This chat is only delete for you"),
              onTap: () {
                Navigator.pop(context);
                homeController.deleteChat(chat);
                }
            ),
            SizedBox(height: 10,),
            ListTile(
                leading: Icon(Icons.person, color: AppTheme.primaryColor,),
                title: Text("View profile"),
                onTap: () {
                  Navigator.pop(context);
                }
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),

    );
  }
}
