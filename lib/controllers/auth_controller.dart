import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/routes/app_routes.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isInitialize = false.obs;

  User? get user => _user.value;

  UserModel? get userModel => _userModel.value;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  bool get isAuthenticate => _user.value != null;

  bool get isInitialize => _isInitialize.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    ever(_user, _handleAuthStateChanges);
  }

  void _handleAuthStateChanges(User? user) {
    // Only handle auth state changes after initialization
    if (!_isInitialize.value) {
      _isInitialize.value = true;
      return;
    }
    
    if (user == null) {
      // Only navigate to login if we're not already on the login screen
      if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      // When user signs in, fetch their data
      _fetchUserData(user.uid);
      
      // Only navigate to main if we're not already on the main screen
      if (Get.currentRoute != AppRoutes.main && Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.main);
      }
    }
  }

  /// Fetch user data from Firestore when user signs in
  Future<void> _fetchUserData(String userId) async {
    try {
      print('AuthController: Fetching user data for ID: $userId');
      final userData = await _authService.getUserData(userId);
      if (userData != null) {
        _userModel.value = userData;
        print('AuthController: User data fetched successfully');
      } else {
        print('AuthController: No user data found');
      }
    } catch (e) {
      print('AuthController: Error fetching user data: $e');
    }
  }

  void checkInitialAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      // Fetch user data for the current user
      _fetchUserData(currentUser.uid);
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
    _isInitialize.value = true;
  }

  Future<void> signInWithEmailAndPass(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      UserModel? userModel = await _authService.signInWithEmailAndPass(
        email,
        password,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        // Make sure we always navigate to main screen after successful sign in
        Get.offAllNamed(AppRoutes.main);
      } else {
        // Handle case where sign in was successful but user data wasn't fetched
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error', 
        'Failed to login: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print('AuthController: Error signing in: $e');
    } finally {
      // Always reset loading state
      _isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPass(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      UserModel? userModel = await _authService.registerWithEmailAndPass(
        email,
        password,
        displayName,
      );
      if (userModel != null) {
        _userModel.value = userModel;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error', 
        'Failed to Create account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      print('AuthController: Attempting to sign out');
      _isLoading.value = true;
      final userEmail = userModel?.email ?? 'Unknown';
      print('AuthController: Signing out user with email: $userEmail');
      await _authService.signOut(userEmail);
      _userModel.value = null;
      print('AuthController: Sign out successful, navigating to login');
      // Clear the user model and navigate to login
      _user.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error', 
        'Failed to sign out',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print('AuthController: Error signing out: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      print('AuthController: Attempting to delete account');
      _isLoading.value = true;
      final userEmail = userModel?.email ?? 'Unknown';
      print('AuthController: Deleting account for user with email: $userEmail');
      await _authService.deleteAccount(userEmail);
      _userModel.value = null;
      print('AuthController: Account deletion successful, navigating to login');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error', 
        'Failed to delete account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print('AuthController: Error deleting account: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}