import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messanger/models/chat_model.dart';
import 'package:messanger/models/friend_request_model.dart';
import 'package:messanger/models/friendship_model.dart';
import 'package:messanger/models/message_model.dart';
import 'package:messanger/models/notification_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      print('FirestoreService: Creating user with ID: ${user.id}');
      await _firestore.collection('user').doc(user.id).set(user.toMap());
      print('FirestoreService: User created successfully');
    } catch (e) {
      print('FirestoreService.createUser error: $e');
      throw Exception('Failed to create account ${e}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      print('FirestoreService: Getting user with ID: $userId');
      DocumentSnapshot doc = await _firestore
          .collection('user')
          .doc(userId)
          .get();
      if (doc.exists) {
        print('FirestoreService: User found');
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      print('FirestoreService: User not found');
      return null;
    } catch (e) {
      print('FirestoreService.getUser error: $e');
      // Return null instead of throwing exception to allow fallback
      return null;
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      print(
        'FirestoreService: Updating online status for user $userId to $isOnline',
      );
      DocumentSnapshot doc = await _firestore
          .collection('user')
          .doc(userId)
          .get();
      if (doc.exists) {
        print('FirestoreService: User exists, updating status');
        return _firestore.collection('user').doc(userId).update({
          'isOnline': isOnline,
          'lastSeen': DateTime.now().microsecondsSinceEpoch,
        });
      } else {
        print('FirestoreService: User does not exist, cannot update status');
      }
    } catch (e) {
      print('FirestoreService.updateUserOnlineStatus error: $e');
      // Don't throw exception here as it shouldn't prevent login
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      print('FirestoreService: Deleting user with ID: $userId');
      await _firestore.collection('user').doc(userId).delete();
      print('FirestoreService: User deleted successfully');
    } catch (e) {
      print('FirestoreService.deleteUser error: $e');
      throw Exception('Failed to delete account ${e}');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    print('FirestoreService: Getting user stream for ID: $userId');
    return _firestore.collection('user').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        try {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } catch (e) {
          print('FirestoreService: Error parsing user data from stream: $e');
          return null;
        }
      }
      return null;
    });
  }

  Future<void> updateUser(UserModel user) async {
    try {
      print('FirestoreService: Updating user with ID: ${user.id}');
      await _firestore.collection('user').doc(user.id).update(user.toMap());
      print('FirestoreService: User updated successfully');
    } catch (e) {
      print('FirestoreService.updateUser error: $e');
      throw Exception('Failed to update user');
    }
  }

  Stream<List<UserModel>> getAllUsersStream() {
    print('FirestoreService: Getting users stream');
    return _firestore
        .collection('user')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(request.id)
          .set(request.toMap());
      String notificationId =
          'friend_request_${request.senderId}_${request.receiverId}_${DateTime.now().microsecondsSinceEpoch} ';
      await createNotification(
        NotificationModel(
          id: notificationId,
          userId: request.receiverId,
          type: NotificationType.friendRequest,
          data: {'senderId': request.senderId, 'requestId': request.id},
          title: 'New friend Request',
          body: 'You have receive a new friend request',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('FirestoreService.sendFriendRequest error: $e');
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      DocumentSnapshot requestDoc = await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>,
        );

        await _firestore.collection('friendRequests').doc(requestId).delete();

        // Notify the receiver that the request has been cancelled
        await createNotification(
          NotificationModel(
            id: 'friend_cancel_${request.senderId}_${request.receiverId}_${DateTime.now().microsecondsSinceEpoch}',
            userId: request.receiverId,
            type: NotificationType.friendRequest,
            data: {'senderId': request.senderId, 'requestId': requestId},
            title: 'Friend Request Cancelled',
            body: 'Friend request has been cancelled',
            createdAt: DateTime.now(),
          ),
        );

        await deleteNotificationByTypeAndUser(
          request.receiverId,
          NotificationType.friendRequest,
          request.senderId,
        );
      }
    } catch (e) {
      throw Exception('FirestoreService.cancelFriendRequest error: $e');
    }
  }

  Future<void> respondToFriendRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': status.name,
        'respondedAt': DateTime.now().microsecondsSinceEpoch,
      });

      DocumentSnapshot requestDoc = await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();
      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>,
        );

        if (status == FriendRequestStatus.accepted) {
          await createFriendship(request.senderId, request.receiverId);

          // Notify the sender that their request was accepted
          await createNotification(
            NotificationModel(
              id: 'friend_accept_${request.senderId}_${request.receiverId}_${DateTime.now().microsecondsSinceEpoch}',
              userId: request.senderId,
              type: NotificationType.friendRequest,
              data: {'senderId': request.receiverId, 'requestId': requestId},
              title: 'Friend Request Accepted',
              body: 'Your friend request has been accepted',
              createdAt: DateTime.now(),
            ),
          );
          
          await _removeNotificationForCancelledRequest(
            request.senderId,
            request.receiverId,
          );
        } else if (status == FriendRequestStatus.declined) {
          // Notify the sender that their request was declined
          await createNotification(
            NotificationModel(
              id: 'friend_decline_${request.senderId}_${request.receiverId}_${DateTime.now().microsecondsSinceEpoch}',
              userId: request.senderId,
              type: NotificationType.friendRequest,
              data: {'senderId': request.receiverId, 'requestId': requestId},
              title: 'Friend Request Declined',
              body: 'Your friend request has been declined',
              createdAt: DateTime.now(),
            ),
          );
          
          await _removeNotificationForCancelledRequest(
            request.senderId,
            request.receiverId,
          );
        }
      }
    } catch (e) {
      throw Exception('FirestoreService.respondToFriendRequest error: $e');
    }
  }

  Stream<List<FriendRequestModel>> getFriendRequestsStream(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<FriendRequestModel>> getSentFriendRequestsStream(String userId) {
    return _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<FriendRequestModel> getFriendRequests(
    String senderId,
    String receiverId,
  ) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (query.docs.isNotEmpty) {
        return FriendRequestModel.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'No friend request found between $senderId and $receiverId',
        );
      }
    } catch (e) {
      throw Exception('FirestoreService.getFriendRequests error: $e');
    }
  }

  Future<void> createFriendship(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';
      FriendshipModel friendship = FriendshipModel(
        id: friendshipId,
        user1Id: userIds[0],
        user2Id: userIds[1],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .set(friendship.toMap());
    } catch (e) {
      throw Exception(
        'FirestoreService.createFriendship error: ${e.toString()}',
      );
    }
  }

  Future<void> removeFriendship(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';
      await _firestore.collection('friendships').doc(friendshipId).delete();

      await createNotification(
        NotificationModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          userId: user2Id,
          type: NotificationType.friendRequest,
          data: {'userId': user1Id},
          title: 'Friendship Removed',
          body: 'You and $user1Id are no longer friends.',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception(
        'FirestoreService.removeFriendship error: ${e.toString()}',
      );
    }
  }

  Future<void> blockUser(String userId, String blockerId) async {
    try {
      List<String> userIds = [userId, blockerId];
      userIds.sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';
      await _firestore.collection("friendships").doc(friendshipId).update({
        'isBlocked': true,
        'isBlockedBy': blockerId,
      });
    } catch (e) {
      throw Exception('FirestoreService.blockUser error: ${e.toString()}');
    }
  }

  Future<void> unBlockUser(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';
      await _firestore.collection("friendships").doc(friendshipId).update({
        'isBlocked': false,
        'isBlockedBy': null,
      });
    } catch (e) {
      throw Exception('FirestoreService.unBlockUser error: ${e.toString()}');
    }
  }

  Stream<List<FriendshipModel>> getFriendsStream(String userId) {
    // Create two streams for friendships where user is user1 or user2
    Stream<QuerySnapshot> stream1 = _firestore
        .collection('friendships')
        .where('user1Id', isEqualTo: userId)
        .snapshots();
        
    Stream<QuerySnapshot> stream2 = _firestore
        .collection('friendships')
        .where('user2Id', isEqualTo: userId)
        .snapshots();
    
    // Combine both streams
    return Rx.combineLatest2(stream1, stream2, (snapshot1, snapshot2) {
      List<FriendshipModel> friendships = [];
      
      // Add friendships where user is user1
      for (var doc in snapshot1.docs) {
        try {
          FriendshipModel friendship = FriendshipModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          if (!friendship.isBlocked) {
            friendships.add(friendship);
          }
        } catch (e) {
          print('Error parsing friendship: $e');
        }
      }
      
      // Add friendships where user is user2
      for (var doc in snapshot2.docs) {
        try {
          FriendshipModel friendship = FriendshipModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          if (!friendship.isBlocked) {
            friendships.add(friendship);
          }
        } catch (e) {
          print('Error parsing friendship: $e');
        }
      }
      
      return friendships;
    });
  }

  Future<FriendshipModel?> getFriendship(String userId1, String userId2) async {
    try {
      List<String> userIds = [userId1, userId2];
      userIds.sort();
      String friendshipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      if (doc.exists) {
        return FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception('FirestoreService.getFriendship error: $e');
    }
  }

  Future<bool> isUserBlocked(String userId, String otherUserId) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();

      String friendshipId = '${userIds[0]}_${userIds[1]}';
      DocumentSnapshot doc = await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      if (doc.exists) {
        FriendshipModel friendship = FriendshipModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );
        return friendship.isBlocked;
      }
      return false;
    } catch (e) {
      throw Exception('FirestoreService.isUserBlocked error: $e');
    }
  }

  Future<bool> isUnfriend(String userId, String otherUserId) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();

      String friendshipId = '${userIds[0]}_${userIds[1]}';
      DocumentSnapshot doc = await _firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      return !doc.exists || (doc.exists && doc.data() == null);
    } catch (e) {
      throw Exception('FirestoreService.isBlocked error: $e');
    }
  }

  Future<String> createOrGetChat(String userId1, String userId2) async {
    try {
      List<String> participants = [userId1, userId2];
      participants.sort();

      String chatId = '${participants[0]}_${participants[1]}';

      QuerySnapshot query = await _firestore
          .collection('chats')
          .where('participants', arrayContains: [userId1, userId2])
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      } else {
        DocumentReference chatRef = await _firestore
            .collection('chats')
            .doc(chatId);
        DocumentSnapshot chatDoc = await chatRef.get();

        if (!chatDoc.exists) {
          ChatModel newChat = ChatModel(
            id: chatId,
            participants: participants,
            unreadCount: {userId1: 0, userId2: 0},
            deleteBy: {userId1: false, userId2: false},
            deleteAt: {userId1: null, userId2: null},
            lastSeenBy: {userId1: DateTime.now(), userId2: DateTime.now()},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await chatRef.set(newChat.toMap());
        } else {
          ChatModel existingChat = ChatModel.fromMap(
            chatDoc.data() as Map<String, dynamic>,
          );
          if (existingChat.isDeletedBy(userId1)) {
            await restoreChatForUser(chatId, userId1);
          }
          if (existingChat.isDeletedBy(userId2)) {
            await restoreChatForUser(chatId, userId2);
          }
        }
        return chatId;
      }
    } catch (e) {
      throw Exception('FirestoreService.createOrGetChat error: $e');
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .where((chat) => !chat.isDeletedBy(userId))
              .toList(),
        );
  }

  Future<void> updateChatLastSeen(String chatId, MessageModel message) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp.microsecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'updatedAt': DateTime.now().microsecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('FirestoreService.updateChatLastSeen error: $e');
    }
  }

  Future<void> updateUserLastSeen(String userId, String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastSeenBy.$userId': DateTime.now().microsecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('FirestoreService.updateUserLastSeen error: $e');
    }
  }

  Future<void> deleteChatForUser(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'deleteBy.$userId': true,
        'deleteAt.$userId': DateTime.now().microsecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('FirestoreService.deleteChatForUser error: $e');
    }
  }

  Future<void> restoreChatForUser(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'deleteBy.$userId': false,
      });
    } catch (e) {
      throw Exception('FirestoreService.restoreChatForUser error: $e');
    }
  }

  Future<void> updateUnreadCount(
    String chatId,
    String userId,
    int count,
  ) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': count,
      });
    } catch (e) {
      throw Exception('FirestoreService.updateChatUnreadCount error: $e');
    }
  }

  Future<void> restoreUnreadCount(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw Exception('FirestoreService.restoreUnreadCount error: $e');
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      String chatId = await createOrGetChat(
        message.senderId,
        message.receiverId,
      );

      await updateChatLastSeen(chatId, message);

      await updateUserLastSeen(message.receiverId, chatId);

      DocumentSnapshot chatDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(
          chatDoc.data() as Map<String, dynamic>,
        );

        int currentUnread = chat.getUnreadCount(message.senderId);

        await updateUnreadCount(chatId, message.senderId, currentUnread + 1);
      }
    } catch (e) {
      throw Exception('FirestoreService.sendMessage error: $e');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String userId1, String userId2) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userId1, userId2])
        .snapshots()
        .asyncMap((snapshot) async {
          List<String> participants = [userId1, userId2];
          participants.sort();
          String chatId = '${participants[0]}_${participants[1]}';

          DocumentSnapshot chatDoc = await _firestore
              .collection('chats')
              .doc(chatId)
              .get();

          ChatModel? chat;
          if (chatDoc.exists) {
            chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
          }

          List<MessageModel> messages = [];
          for (var doc in snapshot.docs) {
            MessageModel message = MessageModel.fromMap(
              doc.data() as Map<String, dynamic>,
            );
            if ((message.senderId == userId1 &&
                    message.receiverId == userId2) ||
                (message.senderId == userId2 &&
                    message.receiverId == userId1)) {
              bool includeMessage = true;

              if (chat != null) {
                DateTime? currentUserDeletedAt = chat.getDeletedAt(userId1);
                if (currentUserDeletedAt != null &&
                    message.timestamp.isBefore(currentUserDeletedAt)) {
                  includeMessage = false;
                }
              }

              if (includeMessage) {
                messages.add(message);
              }
            }
          }
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('FirestoreService.markMessageAsRead error: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      throw Exception('FirestoreService.deleteMessage error: $e');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'editedAt': DateTime.now().microsecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('FirestoreService.editMessage error: $e');
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('FirestoreService.createNotification error: $e');
    }
  }

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('FirestoreService.markNotificationAsRead error: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('FirestoreService.markAllNotificationsAsRead error: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('FirestoreService.deleteNotification error: $e');
    }
  }

  Future<void> deleteNotificationByTypeAndUser(
    String userId,
    NotificationType type,
    String relatedId,
  ) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .get();
      WriteBatch batch = _firestore.batch();
      for (var doc in notifications.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['data'] != null &&
            (data['data']['senderId'] == relatedId ||
                data['data']['receiverId'] == relatedId)) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
    } catch (e) {
      print(' error delete message by type and user: $e');
    }
  }

  Future<void> _removeNotificationForCancelledRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      await deleteNotificationByTypeAndUser(
        senderId,
        NotificationType.friendRequest,
        receiverId,
      );
    } catch (e) {
      throw Exception(
        'FirestoreService._removeNotificationForCancelledRequest error: $e',
      );
    }
  }
}
