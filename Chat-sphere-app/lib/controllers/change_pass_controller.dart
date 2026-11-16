import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePassController extends GetxController {
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _obscureCurrentPass = true.obs;
  final RxBool _obscureNewPass = true.obs;
  final RxBool _obscureConfirmPass = true.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get obscureCurrentPass => _obscureCurrentPass.value;
  bool get obscureNewPass => _obscureNewPass.value;
  bool get obscureConfirmPass => _obscureConfirmPass.value;

  @override
  void onClose() {
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.onClose();
  }

  void toggleCurrentPassVisibilty() {
    _obscureCurrentPass.value = !_obscureCurrentPass.value;
  }

  void toggleNewPassVisibilty() {
    _obscureNewPass.value = !_obscureNewPass.value;
  }

  void toggleConfirmPassVisibility() {
    _obscureConfirmPass.value = !_obscureConfirmPass.value;
  }

  Future<void> changePass() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _isLoading.value = true;
    _error.value = '';
    await Future.delayed(const Duration(milliseconds: 700));

    Get.snackbar(
      'Success',
      'Password change successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    currentPassController.clear();
    newPassController.clear();
    confirmPassController.clear();
    _isLoading.value = false;
    Navigator.pop(Get.context!);
  }

  String? validateCurrentPass(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? validateNewPass(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your New password';
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 character';
    }
    if (value == currentPassController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? validateConfirmPass(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }
    if (value != newPassController.text) {
      return 'Password do not match';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}
