import '../models/chat_model.dart';
import '../models/friend_request_model.dart';
import '../models/friendship_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

/// In-memory stand-in for the Firebase backend.
///
/// The app is UI-only for now, so every screen reads from these sample lists
/// instead of Firestore. Actions (sending a message, accepting a request,
/// marking a notification read) mutate these lists so the UI behaves like the
/// real app while it runs.
class MockDatabase {
  MockDatabase._() {
    _seed();
  }

  static final MockDatabase instance = MockDatabase._();

  late UserModel currentUser;
  final List<UserModel> users = <UserModel>[];
  final List<ChatModel> chats = <ChatModel>[];
  final Map<String, List<MessageModel>> chatMessages =
      <String, List<MessageModel>>{};
  final List<FriendRequestModel> friendRequests = <FriendRequestModel>[];
  final List<FriendshipModel> friendships = <FriendshipModel>[];
  final List<NotificationModel> notifications = <NotificationModel>[];

  // ---------------------------------------------------------------- lookups

  UserModel? userById(String id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  List<UserModel> get otherUsers =>
      users.where((user) => user.id != currentUser.id).toList();

  ChatModel? chatById(String id) {
    for (final chat in chats) {
      if (chat.id == id) return chat;
    }
    return null;
  }

  ChatModel? chatWith(UserModel other) {
    for (final chat in chats) {
      if (chat.participants.contains(currentUser.id) &&
          chat.participants.contains(other.id)) {
        return chat;
      }
    }
    return null;
  }

  List<MessageModel> messagesFor(String chatId) =>
      chatMessages[chatId] ?? <MessageModel>[];

  FriendshipModel? friendshipWith(String userId) {
    for (final friendship in friendships) {
      final matches = (friendship.user1Id == currentUser.id &&
              friendship.user2Id == userId) ||
          (friendship.user2Id == currentUser.id &&
              friendship.user1Id == userId);
      if (matches) return friendship;
    }
    return null;
  }

  FriendRequestModel? sentPendingRequestTo(String userId) {
    for (final request in friendRequests) {
      if (request.senderId == currentUser.id &&
          request.receiverId == userId &&
          request.status == FriendRequestStatus.pending) {
        return request;
      }
    }
    return null;
  }

  FriendRequestModel? receivedPendingRequestFrom(String userId) {
    for (final request in friendRequests) {
      if (request.receiverId == currentUser.id &&
          request.senderId == userId &&
          request.status == FriendRequestStatus.pending) {
        return request;
      }
    }
    return null;
  }

  // -------------------------------------------------------------- mutations

  ChatModel openChatWith(UserModel other) {
    final existing = chatWith(other);
    if (existing != null) return existing;

    final now = DateTime.now();
    final chat = ChatModel(
      id: _newId('c'),
      participants: [currentUser.id, other.id],
      unreadCount: {currentUser.id: 0, other.id: 0},
      createdAt: now,
      updatedAt: now,
    );
    chats.insert(0, chat);
    chatMessages[chat.id] = <MessageModel>[];
    return chat;
  }

  void sendMessage(String chatId, String content) {
    final chat = chatById(chatId);
    if (chat == null) return;

    final otherId = chat.getOtherParticipant(currentUser.id);
    final message = MessageModel(
      id: _newId('m'),
      senderId: currentUser.id,
      receiverId: otherId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    chatMessages.putIfAbsent(chatId, () => <MessageModel>[]).add(message);

    final index = chats.indexWhere((item) => item.id == chatId);
    if (index != -1) {
      chats[index] = chat.copyWith(
        lastMessage: content,
        lastMessageTime: message.timestamp,
        lastMessageSenderId: currentUser.id,
        unreadCount: {
          ...chat.unreadCount,
          currentUser.id: 0,
          otherId: (chat.unreadCount[otherId] ?? 0) + 1,
        },
        updatedAt: message.timestamp,
      );
    }
  }

  void markChatRead(String chatId) {
    final index = chats.indexWhere((chat) => chat.id == chatId);
    if (index == -1) return;
    final chat = chats[index];
    chats[index] = chat.copyWith(
      unreadCount: {...chat.unreadCount, currentUser.id: 0},
      lastSeenBy: {...chat.lastSeenBy, currentUser.id: DateTime.now()},
    );
  }

  void deleteChat(String chatId) {
    chats.removeWhere((chat) => chat.id == chatId);
  }

  void updateCurrentUser({String? displayName}) {
    if (displayName != null && displayName.isNotEmpty) {
      currentUser = currentUser.copyWith(displayName: displayName);
      final index = users.indexWhere((user) => user.id == currentUser.id);
      if (index != -1) users[index] = currentUser;
    }
  }

  void sendFriendRequest(String receiverId) {
    friendRequests.add(
      FriendRequestModel(
        id: _newId('r'),
        senderId: currentUser.id,
        receiverId: receiverId,
        createdAt: DateTime.now(),
      ),
    );
  }

  void cancelFriendRequest(String requestId) {
    friendRequests.removeWhere((request) => request.id == requestId);
  }

  void respondToFriendRequest(String requestId, FriendRequestStatus status) {
    final index = friendRequests.indexWhere((request) => request.id == requestId);
    if (index == -1) return;

    final request = friendRequests[index];
    friendRequests[index] = FriendRequestModel(
      id: request.id,
      senderId: request.senderId,
      receiverId: request.receiverId,
      status: status,
      createdAt: request.createdAt,
      respondedAt: DateTime.now(),
      message: request.message,
    );

    if (status == FriendRequestStatus.accepted) {
      final otherId = request.senderId == currentUser.id
          ? request.receiverId
          : request.senderId;
      addFriendship(otherId);
    }
  }

  void addFriendship(String otherId) {
    if (friendshipWith(otherId) != null) return;
    friendships.add(
      FriendshipModel(
        id: _newId('f'),
        user1Id: currentUser.id,
        user2Id: otherId,
        createdAt: DateTime.now(),
      ),
    );
  }

  void removeFriendship(String otherId) {
    friendships.removeWhere(
      (friendship) =>
          friendship.getOtherUserId(currentUser.id) == otherId,
    );
  }

  void blockFriend(String otherId) {
    final index = friendships.indexWhere(
      (friendship) => friendship.getOtherUserId(currentUser.id) == otherId,
    );
    if (index == -1) return;
    friendships[index] = friendships[index].copyWith(
      isBlocked: true,
      blockedBy: currentUser.id,
    );
  }

  void unblockUser(String otherId) {
    final index = friendships.indexWhere(
      (friendship) => friendship.getOtherUserId(currentUser.id) == otherId,
    );
    if (index == -1) return;
    friendships[index] =
        friendships[index].copyWith(isBlocked: false, blockedBy: null);
  }

  void markNotificationRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;
    notifications[index] = notifications[index].copyWith(isRead: true);
  }

  void markAllNotificationsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((item) => item.id == id);
  }

  String _newId(String prefix) =>
      '$prefix${DateTime.now().microsecondsSinceEpoch}';

  // ------------------------------------------------------------------- seed

  void _seed() {
    final now = DateTime.now();

    currentUser = UserModel(
      id: 'u0',
      email: 'ayesha.khan@example.com',
      displayName: 'Ayesha Khan',
      isOnline: true,
      lastSeen: now,
      createdAt: DateTime(2023, 3, 14),
    );

    users.addAll([
      currentUser,
      UserModel(
        id: 'u1',
        email: 'david.miller@example.com',
        displayName: 'David Miller',
        isOnline: true,
        lastSeen: now,
        createdAt: DateTime(2023, 5, 2),
      ),
      UserModel(
        id: 'u2',
        email: 'sofia.rossi@example.com',
        displayName: 'Sofia Rossi',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 25)),
        createdAt: DateTime(2023, 6, 18),
      ),
      UserModel(
        id: 'u3',
        email: 'liam.chen@example.com',
        displayName: 'Liam Chen',
        isOnline: true,
        lastSeen: now,
        createdAt: DateTime(2023, 8, 4),
      ),
      UserModel(
        id: 'u4',
        email: 'noah.williams@example.com',
        displayName: 'Noah Williams',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 3)),
        createdAt: DateTime(2023, 9, 21),
      ),
      UserModel(
        id: 'u5',
        email: 'emma.johnson@example.com',
        displayName: 'Emma Johnson',
        isOnline: false,
        lastSeen: now.subtract(const Duration(days: 2)),
        createdAt: DateTime(2024, 1, 9),
      ),
      UserModel(
        id: 'u6',
        email: 'olivia.brown@example.com',
        displayName: 'Olivia Brown',
        isOnline: true,
        lastSeen: now,
        createdAt: DateTime(2024, 2, 27),
      ),
      UserModel(
        id: 'u7',
        email: 'ethan.davis@example.com',
        displayName: 'Ethan Davis',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 40)),
        createdAt: DateTime(2024, 4, 12),
      ),
      UserModel(
        id: 'u8',
        email: 'mia.patel@example.com',
        displayName: 'Mia Patel',
        isOnline: true,
        lastSeen: now,
        createdAt: DateTime(2024, 6, 30),
      ),
      UserModel(
        id: 'u9',
        email: 'lucas.garcia@example.com',
        displayName: 'Lucas Garcia',
        isOnline: false,
        lastSeen: now.subtract(const Duration(days: 1)),
        createdAt: DateTime(2024, 8, 15),
      ),
      UserModel(
        id: 'u10',
        email: 'zara.ahmed@example.com',
        displayName: 'Zara Ahmed',
        isOnline: false,
        lastSeen: now.subtract(const Duration(days: 5)),
        createdAt: DateTime(2024, 11, 3),
      ),
    ]);

    for (var i = 0; i < 5; i++) {
      friendships.add(
        FriendshipModel(
          id: 'f${i + 1}',
          user1Id: currentUser.id,
          user2Id: 'u${i + 1}',
          createdAt: DateTime(2024, 1, 10 + i),
        ),
      );
    }

    friendRequests.addAll([
      FriendRequestModel(
        id: 'r1',
        senderId: 'u6',
        receiverId: currentUser.id,
        createdAt: now.subtract(const Duration(minutes: 20)),
        message: 'Hi Ayesha! We met at the design meetup.',
      ),
      FriendRequestModel(
        id: 'r2',
        senderId: 'u7',
        receiverId: currentUser.id,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      FriendRequestModel(
        id: 'r3',
        senderId: 'u9',
        receiverId: currentUser.id,
        status: FriendRequestStatus.accepted,
        createdAt: now.subtract(const Duration(days: 6)),
        respondedAt: now.subtract(const Duration(days: 5)),
      ),
      FriendRequestModel(
        id: 'r4',
        senderId: currentUser.id,
        receiverId: 'u8',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      FriendRequestModel(
        id: 'r5',
        senderId: currentUser.id,
        receiverId: 'u10',
        status: FriendRequestStatus.declined,
        createdAt: now.subtract(const Duration(days: 4)),
        respondedAt: now.subtract(const Duration(days: 3)),
      ),
    ]);

    chats.addAll([
      ChatModel(
        id: 'c1',
        participants: [currentUser.id, 'u1'],
        lastMessage: 'Are we still meeting at 6?',
        lastMessageTime: now.subtract(const Duration(minutes: 4)),
        lastMessageSenderId: 'u1',
        unreadCount: {currentUser.id: 2, 'u1': 0},
        createdAt: DateTime(2024, 2, 11),
        updatedAt: now.subtract(const Duration(minutes: 4)),
      ),
      ChatModel(
        id: 'c2',
        participants: [currentUser.id, 'u2'],
        lastMessage: 'Perfect, thank you! 🙌',
        lastMessageTime: now.subtract(const Duration(minutes: 35)),
        lastMessageSenderId: currentUser.id,
        unreadCount: {currentUser.id: 0, 'u2': 0},
        lastSeenBy: {'u2': now.subtract(const Duration(minutes: 30))},
        createdAt: DateTime(2024, 3, 2),
        updatedAt: now.subtract(const Duration(minutes: 35)),
      ),
      ChatModel(
        id: 'c3',
        participants: [currentUser.id, 'u3'],
        lastMessage: "I'll send the files tonight.",
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        lastMessageSenderId: 'u3',
        unreadCount: {currentUser.id: 1, 'u3': 0},
        createdAt: DateTime(2024, 4, 19),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ChatModel(
        id: 'c4',
        participants: [currentUser.id, 'u5'],
        lastMessage: "Haha that's amazing 😂",
        lastMessageTime: now.subtract(const Duration(hours: 5)),
        lastMessageSenderId: 'u5',
        unreadCount: {currentUser.id: 2, 'u5': 0},
        createdAt: DateTime(2024, 5, 7),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      ChatModel(
        id: 'c5',
        participants: [currentUser.id, 'u4'],
        lastMessage: 'Sounds good 👍',
        lastMessageTime: now.subtract(const Duration(days: 2)),
        lastMessageSenderId: currentUser.id,
        unreadCount: {currentUser.id: 0, 'u4': 0},
        lastSeenBy: {'u4': now.subtract(const Duration(days: 3))},
        createdAt: DateTime(2024, 6, 25),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

    chatMessages['c1'] = [
      _message('m1', 'u1', currentUser.id,
          'Hey! Did you get a chance to look at the new designs?',
          now.subtract(const Duration(hours: 2, minutes: 55))),
      _message('m2', currentUser.id, 'u1',
          'Just opened them. The colour palette looks great.',
          now.subtract(const Duration(hours: 2, minutes: 40))),
      _message('m3', 'u1', currentUser.id, "I knew you'd like it 😄",
          now.subtract(const Duration(hours: 2, minutes: 30))),
      _message('m4', currentUser.id, 'u1',
          'Should we present it tomorrow morning?',
          now.subtract(const Duration(minutes: 35))),
      _message('m5', 'u1', currentUser.id, 'Are we still meeting at 6?',
          now.subtract(const Duration(minutes: 4)), isRead: false),
    ];

    chatMessages['c2'] = [
      _message('m6', 'u2', currentUser.id, 'Thank you for the quick review!',
          now.subtract(const Duration(minutes: 50))),
      _message('m7', currentUser.id, 'u2',
          'Anytime. Your copy is really clear.',
          now.subtract(const Duration(minutes: 42))),
      _message('m8', 'u2', currentUser.id,
          'Sending over the final version now.',
          now.subtract(const Duration(minutes: 38))),
      _message('m9', currentUser.id, 'u2', 'Perfect, thank you! 🙌',
          now.subtract(const Duration(minutes: 35))),
    ];

    chatMessages['c3'] = [
      _message('m10', currentUser.id, 'u3', 'How is the migration going?',
          now.subtract(const Duration(hours: 3))),
      _message('m11', 'u3', currentUser.id, 'Almost done. Two tables left.',
          now.subtract(const Duration(hours: 2))),
      _message('m12', 'u3', currentUser.id, "I'll send the files tonight.",
          now.subtract(const Duration(hours: 1)), isRead: false),
    ];

    chatMessages['c4'] = [
      _message('m13', 'u5', currentUser.id,
          'Guess who just got the tickets 😎',
          now.subtract(const Duration(hours: 8))),
      _message('m14', currentUser.id, 'u5',
          'No way! For the Friday show?',
          now.subtract(const Duration(hours: 6))),
      _message('m15', 'u5', currentUser.id, "Haha that's amazing 😂",
          now.subtract(const Duration(hours: 5)), isRead: false),
    ];

    chatMessages['c5'] = [
      _message('m16', 'u4', currentUser.id, 'Can we move the call to 3?',
          now.subtract(const Duration(days: 2, hours: 3))),
      _message('m17', currentUser.id, 'u4', 'Sounds good 👍',
          now.subtract(const Duration(days: 2))),
    ];

    notifications.addAll([
      NotificationModel(
        id: 'n1',
        userId: currentUser.id,
        type: NotificationType.friendRequest,
        title: 'New friend request',
        body: 'Olivia Brown sent you a friend request',
        data: const {'senderId': 'u6'},
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
      NotificationModel(
        id: 'n2',
        userId: currentUser.id,
        type: NotificationType.newMessage,
        title: 'New message',
        body: 'David Miller sent you a message',
        data: const {'senderId': 'u1', 'userId': 'u1'},
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
      NotificationModel(
        id: 'n3',
        userId: currentUser.id,
        type: NotificationType.friendRequestAccept,
        title: 'Friend request accepted',
        body: 'Lucas Garcia accepted your friend request',
        data: const {'senderId': 'u9'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      NotificationModel(
        id: 'n4',
        userId: currentUser.id,
        type: NotificationType.newMessage,
        title: 'New message',
        body: 'Sofia Rossi sent you a message',
        data: const {'senderId': 'u2', 'userId': 'u2'},
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 50)),
      ),
    ]);
  }

  MessageModel _message(
    String id,
    String senderId,
    String receiverId,
    String content,
    DateTime timestamp, {
    bool isRead = true,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
    );
  }
}
