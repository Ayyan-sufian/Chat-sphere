import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messanger/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('user').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create account ${e}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user ${e}');
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user')
          .doc(userId)
          .get();
      if (doc.exists) {
        return _firestore.collection('user').doc(userId).update({
          'isOnline': isOnline,
          'lastSeen': DateTime.now().microsecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception('Failed to update online Status ${e}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('user').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete account ${e}');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection('user')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<void> updateUser(UserModel user) async {
      try{
        await _firestore.collection('user').doc(user.id).update(user.toMap());
      }catch(e){
        throw Exception('Failed to update user');
      }
  }
}
