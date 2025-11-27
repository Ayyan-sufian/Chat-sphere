import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
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
    // TODO: implement onInit
    print('ProfileController: onInit called');
    super.onInit();
    loadUserData();
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure data is loaded when controller is ready
    if (_currentUser.value == null) {
      loadUserData();
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    displayNameController.dispose();
    emailController.dispose();
  }

  void loadUserData() {
    print('ProfileController: loadUserData called');
    // Load initial user data
    final currentUserId = _authController.user?.uid;
    print('ProfileController: Current user ID: $currentUserId');
    
    if (currentUserId != null) {
      print('ProfileController: Loading user data for UID: $currentUserId');
      // Bind to the user stream to get real-time updates
      _currentUser.bindStream(_firestoreService.getUserStream(currentUserId));
      
      // Set up listener for user data changes
      ever(_currentUser, (UserModel? user) {
        print('ProfileController: User data changed: $user');
        if (user != null) {
          displayNameController.text = user.displayName;
          emailController.text = user.email;
        }
      });
    } else {
      print('ProfileController: No current user ID found, checking again in 500ms');
      // Try to reload after a short delay in case auth state hasn't been initialized yet
      Future.delayed(Duration(milliseconds: 500), () {
        final userId = _authController.user?.uid;
        if (userId != null) {
          print('ProfileController: Retrying to load user data for UID: $userId');
          _currentUser.bindStream(_firestoreService.getUserStream(userId));
        } else {
          // If still no user ID, try one more time after another delay
          Future.delayed(Duration(milliseconds: 500), () {
            final userId = _authController.user?.uid;
            if (userId != null) {
              print('ProfileController: Final attempt to load user data for UID: $userId');
              _currentUser.bindStream(_firestoreService.getUserStream(userId));
            }
          });
        }
      });
    }
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
    try {
      _isLoading.value = true;
      _error.value = '';

      final user = _currentUser.value;
      if (user == null) {
        return;
      }

      final updateUser = user.copyWith(displayName: displayNameController.text);

      await _firestoreService.updateUser(updateUser);
      _isEditing.value = false;
      Get.snackbar(
        'Success', 
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      _error.value = e.toString();
      print(e.toString());
      Get.snackbar(
        'Error', 
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      print('ProfileController: Attempting to sign out');
      await _authController.signOut();
      print('ProfileController: Sign out successful');
    } catch (e) {
      print('ProfileController: Error signing out: $e');
      Get.snackbar(
        'Error', 
        'Failed to sign out: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      print('ProfileController: Showing delete account confirmation dialog');

      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Delete Account"),
          content: Text("Are you sure you want to delete this account?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(Get.context!, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(Get.context!, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text("Delete"),
            ),
          ],
        ),
        barrierDismissible: false, // IMPORTANT FIX
      );

      if (result != true) {
        print("ProfileController: User cancelled delete");
        return;
      }

      print('ProfileController: User confirmed account deletion');

      _isLoading.value = true;

      await _authController.deleteAccount();
      print('ProfileController: Account deletion successful');

    } catch (e) {
      print('ProfileController: Error deleting account: $e');
      Get.snackbar(
        'Error',
        'Failed to delete account: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }


  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) {
      return '';
    }
    final date = user.createdAt;
    final months = [
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

  void clearError(){
    _error.value = '';
  }
}