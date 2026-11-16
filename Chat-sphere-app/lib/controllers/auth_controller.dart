import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

/// Local, UI-only replacement for the Firebase AuthController.
class AuthController extends GetxController {
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  UserModel? get user => _user.value;

  String get currentUserId =>
      _user.value?.id ?? MockDatabase.instance.currentUser.id;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  bool get isAuthenticate => _user.value != null;

  void checkInitialAuthState() {
    _user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> signInWithEmailAndPass(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      await Future.delayed(const Duration(milliseconds: 700));
      _user.value = MockDatabase.instance.currentUser;
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to login',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
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
      await Future.delayed(const Duration(milliseconds: 700));
      MockDatabase.instance.updateCurrentUser(displayName: displayName);
      _user.value = MockDatabase.instance.currentUser;
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to Create account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    _isLoading.value = true;
    _user.value = null;
    _isLoading.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccount() async {
    _isLoading.value = true;
    _user.value = null;
    _isLoading.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  void clearError() {
    _error.value = '';
  }
}
