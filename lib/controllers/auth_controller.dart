import 'package:firebase_auth/firebase_auth.dart';
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
    if (!_isInitialize.value) {
      _isInitialize.value = true;
      return;
    }
    
    if (user == null) {
      if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      if (Get.currentRoute != AppRoutes.profile && Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.profile);
      }
    }
  }

  void checkInitialAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.profile);
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
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to login');
      print(e);
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
      Get.snackbar('Error', 'Failed to Create account');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut(String email) async {
    try {
      _isLoading.value = true;
      await _authService.signOut(email);
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to sign out');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount(String email) async {
    try {
      _isLoading.value = true;
      await _authService.deleteAccount(email);
      _userModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete account');
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
