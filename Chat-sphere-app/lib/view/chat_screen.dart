import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../theme/app_theme.dart';
import 'widget/message_bubble.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              if (messages.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final showDate = index == 0 ||
                      !controller.isSameDay(
                        messages[index - 1].timestamp,
                        message.timestamp,
                      );
                  final isMine = controller.isMessageMine(message);
                  final isLastOfGroup = index == messages.length - 1 ||
                      messages[index + 1].senderId != message.senderId ||
                      !controller.isSameDay(
                        messages[index + 1].timestamp,
                        message.timestamp,
                      );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDate)
                        _buildDateHeader(
                          controller.dateLabel(message.timestamp),
                        ),
                      MessageBubble(
                        message: message,
                        isMine: isMine,
                        showAvatar: !isMine && isLastOfGroup,
                        timeText: controller.messageTime(message.timestamp),
                        avatarLabel: controller.person.displayName.isNotEmpty
                            ? controller.person.displayName[0].toUpperCase()
                            : '?',
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimaryTheme,
      elevation: 0,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  controller.person.displayName.isNotEmpty
                      ? controller.person.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (controller.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.person.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryTheme,
                  ),
                ),
                Text(
                  controller.lastSeenText,
                  style: TextStyle(
                    fontSize: 12,
                    color: controller.isOnline
                        ? AppTheme.successColor
                        : AppTheme.textSceTheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.snackbar('Info', 'Voice calls are coming soon!');
          },
          icon: const Icon(Icons.call_outlined),
        ),
        IconButton(
          onPressed: () {
            Get.snackbar('Info', 'Video calls are coming soon!');
          },
          icon: const Icon(Icons.videocam_outlined),
        ),
        IconButton(
          onPressed: () => _showChatOptions(context),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSceTheme,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No messages yet",
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textSceTheme,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Say hello to ${controller.person.displayName} 👋",
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSceTheme,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                Get.snackbar('Info', 'Attachments are coming soon!');
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.sendMessage(),
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        Get.snackbar('Info', 'Emojis are coming soon!');
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppTheme.primaryColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: controller.sendMessage,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
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
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: AppTheme.primaryColor,
              ),
              title: const Text("View profile"),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'Profile details coming soon!');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text("Block user"),
              subtitle: const Text("You will no longer receive messages"),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Info', 'User blocked');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
