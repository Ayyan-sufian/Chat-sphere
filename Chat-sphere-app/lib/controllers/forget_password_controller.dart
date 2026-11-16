import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _emailSent = false.obs;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  bool get emailSent => _emailSent.value;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendPasswordResetEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';
      await Future.delayed(const Duration(milliseconds: 800));
      _emailSent.value = true;
      Get.snackbar(
        'Success',
        'Password reset email sent to ${emailController.text.trim()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to send reset email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void goBackToLogin() {
    Navigator.pop(Get.context!);
  }

  void resendEmail() {
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value!)) {
      return 'Please enter valid email';
    }
    return null;
  }

  void clearEmailSent() {
    _emailSent.value = false;
  }
}
