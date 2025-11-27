import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:messanger/models/user_model.dart';

import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPass(
    String email,
    String password,
  ) async {
    try {
      print('AuthService: Attempting to sign in with email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        print('AuthService: Firebase auth successful for user: ${user.uid}');
        // Update user's online status
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        // Add a small delay to ensure Firestore updates are processed
        await Future.delayed(Duration(milliseconds: 100));
        // Fetch user data from Firestore
        final userData = await _firestoreService.getUser(user.uid);
        if (userData != null) {
          print('AuthService: User data fetched successfully');
          return userData;
        } else {
          print('AuthService: No user data found in Firestore');
          // If user data doesn't exist, create it (this shouldn't happen in normal cases)
          final userModel = UserModel(
            id: user.uid,
            email: email,
            displayName: user.displayName ?? email.split('@')[0],
            photoUrl: '',
            isOnline: true,
            lastSeen: DateTime.now(),
            createdAt: DateTime.now(),
          );
          await _firestoreService.createUser(userModel);
          return userModel;
        }
      }
      print('AuthService: No user returned from Firebase auth');
      return null;
    } catch (e) {
      print('AuthService.signInWithEmailAndPass error: $e');
      throw Exception('Failed to sign in: ${e}');
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      print('AuthService: Getting user data for ID: $userId');
      return await _firestoreService.getUser(userId);
    } catch (e) {
      print('AuthService.getUserData error: $e');
      return null;
    }
  }

  Future<UserModel?> registerWithEmailAndPass(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        final userModel = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
          photoUrl: '',
          isOnline: true,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      print('AuthService.registerWithEmailAndPass error: $e');
      throw Exception('Failed to register: ${e}');
    }
  }

  Future<void> sendPassResetEmail(String email) async {
    try {
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
    } catch (e) {
      print('AuthService.sendPassResetEmail error: $e');
      // Let's also check the type of exception
      if (e is FirebaseAuthException) {
        print(
          'AuthService.sendPassResetEmail FirebaseAuthException code: ${e.code}, message: ${e.message}',
        );
      }
      throw Exception('Failed to send password reset email: ${e}');
    }
  }

  Future<void> signOut(String email) async {
    try {
      print('AuthService: Attempting to sign out user with email: $email');
      print('AuthService: Current user: $currentUser');
      if (currentUser != null) {
        print(
          'AuthService: Updating user online status to false for user: ${currentUser!.uid}',
        );
        await _firestoreService.updateUserOnlineStatus(currentUser!.uid, false);
      }
      print('AuthService: Calling Firebase signOut');
      await _auth.signOut();
      print('AuthService: Sign out successful');
    } catch (e) {
      print('AuthService.signOut error: $e');
      // Let's also check the type of exception
      if (e is FirebaseAuthException) {
        print(
          'AuthService.signOut FirebaseAuthException code: ${e.code}, message: ${e.message}',
        );
      }
      throw Exception('Failed to sign out: ${e}');
    }
  }

  Future<void> deleteAccount(String email) async {
    try {
      print(
        'AuthService: Attempting to delete account for user with email: $email',
      );
      User? user = _auth.currentUser;
      print('AuthService: Current user: $user');
      if (user != null) {
        print(
          'AuthService: Deleting user data from Firestore for user: ${user.uid}',
        );
        await _firestoreService.deleteUser(user.uid);
        print('AuthService: Deleting user account from Firebase Auth');
        await user.delete();
        print('AuthService: Account deletion successful');
      } else {
        print('AuthService: No current user found, cannot delete account');
        throw Exception('No current user found');
      }
    } catch (e) {
      print('AuthService.deleteAccount error: $e');
      // Let's also check the type of exception
      if (e is FirebaseAuthException) {
        print(
          'AuthService.deleteAccount FirebaseAuthException code: ${e.code}, message: ${e.message}',
        );
      }
      throw Exception('Failed to delete account: ${e}');
    }
  }
}