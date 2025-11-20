import 'package:firebase_auth/firebase_auth.dart';
import 'package:messanger/models/user_model.dart';

import 'firestore_service.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService  = FirestoreService();

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPass(String email, String password)async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if(user != null){
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        return await _firestoreService.getUser(user.uid);
      }
      return null;
    }catch(e){
      print('AuthService.signInWithEmailAndPass error: $e');
      throw Exception('Failed to sign in: ${e}');
    }
  }
  Future<UserModel?> registerWithEmailAndPass(String email, String password, String displayName)async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password,);
      User? user = result.user;
      if(user != null){
        await user.updateDisplayName(displayName);
        final userModel = UserModel(id: user.uid, email: email, displayName: displayName,photoUrl: '', isOnline: true, lastSeen: DateTime.now(), createdAt: DateTime.now());
        await _firestoreService.createUser(userModel);
        return userModel;
              }
      return null;
    }catch(e){
      print('AuthService.registerWithEmailAndPass error: $e');
      throw Exception('Failed to register: ${e}');
    }
  }

  Future<void> sendPassResetEmail(String email)async{
    try{
      print('AuthService: Attempting to send password reset email to: $email');
      print('AuthService: Firebase Auth instance: $_auth');
      
      // Check if email is valid
      if (email.isEmpty) {
        print('AuthService: Email is empty, throwing exception');
        throw Exception('Email cannot be empty');
      }

      
      print('AuthService: Calling Firebase sendPasswordResetEmail');
      await _auth.sendPasswordResetEmail(email: email);
      print('AuthService: Password reset email sent successfully to: $email');
    }catch(e){
      print('AuthService.sendPassResetEmail error: $e');
      // Let's also check the type of exception
      if (e is FirebaseAuthException) {
        print('AuthService.sendPassResetEmail FirebaseAuthException code: ${e.code}, message: ${e.message}');
      }
      throw Exception('Failed to send password reset email: ${e}');
    }
  }

  Future<void> signOut(String email)async{
    try{
      if(currentUser!=null){
        await _firestoreService.updateUserOnlineStatus(currentUserId!, false);
      }
      await _auth.signOut();
    }catch(e){
      print('AuthService.signOut error: $e');
      throw Exception('Failed to sign out: ${e}');
    }
  }

  Future<void> deleteAccount(String email)async{
    try{
     User? user = _auth.currentUser;
     if(user != null){
       await _firestoreService.deleteUser(user.uid);
       await user.delete();
     }
    }catch(e){
      print('AuthService.deleteAccount error: $e');
      throw Exception('Failed to delete account: ${e}');
    }
  }
}