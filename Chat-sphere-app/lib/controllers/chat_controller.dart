import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';
import 'home_controller.dart';

class ChatController extends GetxController {
  ChatController({this.chatId, this.otherUser});

  final String? chatId;
  final UserModel? otherUser;

  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxString _resolvedChatId = ''.obs;

  late UserModel person;

  String get resolvedChatId => _resolvedChatId.value;

  @override
  void onInit() {
    super.onInit();
    final db = MockDatabase.instance;
    person = otherUser ?? db.otherUsers.first;

    final existing = chatId != null ? db.chatById(chatId!) : db.chatWith(person);
    final chat = existing ?? db.openChatWith(person);
    _resolvedChatId.value = chat.id;

    messages.value = List<MessageModel>.from(db.messagesFor(chat.id));
    db.markChatRead(chat.id);
    _refreshChatList();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _refreshChatList() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().reloadChats();
    }
  }

  bool get isOnline => person.isOnline;

  String get lastSeenText {
    if (person.isOnline) {
      return 'Online';
    }
    final difference = DateTime.now().difference(person.lastSeen);
    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inHours < 1) {
      return 'Last seen ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours} hours ago';
    } else {
      return 'Last seen ${difference.inDays} days ago';
    }
  }

  bool isMessageMine(MessageModel message) {
    return message.senderId == _authController.currentUserId;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String dateLabel(DateTime time) {
    final now = DateTime.now();
    if (isSameDay(time, now)) {
      return 'Today';
    }
    if (isSameDay(time, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${time.day} ${months[time.month - 1]} ${time.year}';
  }

  String messageTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    MockDatabase.instance.sendMessage(_resolvedChatId.value, text);
    messages.value = List<MessageModel>.from(
      MockDatabase.instance.messagesFor(_resolvedChatId.value),
    );
    messageController.clear();
    _refreshChatList();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
