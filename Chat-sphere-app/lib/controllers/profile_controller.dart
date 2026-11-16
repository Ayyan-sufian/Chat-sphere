import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/mock_database.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;

  bool get isEditing => _isEditing.value;

  String get error => _error.value;

  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    displayNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void loadUserData() {
    final user = MockDatabase.instance.currentUser;
    _currentUser.value = user;
    displayNameController.text = user.displayName;
    emailController.text = user.email;
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;

    if (!_isEditing.value) {
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        emailController.text = user.email;
      }
    }
  }

  Future<void> updateProfile() async {
    _isLoading.value = true;
    _error.value = '';

    MockDatabase.instance
        .updateCurrentUser(displayName: displayNameController.text.trim());
    _currentUser.value = MockDatabase.instance.currentUser;
    _isEditing.value = false;
    _isLoading.value = false;

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> signOut() async {
    await _authController.signOut();
  }

  Future<void> deleteAccount() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (result != true) return;

    _isLoading.value = true;
    await _authController.deleteAccount();
    _isLoading.value = false;
  }

  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) {
      return '';
    }
    final date = user.createdAt;
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];

    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  void clearError() {
    _error.value = '';
  }
}
