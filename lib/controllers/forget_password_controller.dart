import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/services/auth_service.dart';

class ForgetPasswordController extends GetxController {
  final AuthService _authService = AuthService();
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
    // TODO: implement onClose
    super.onClose();
    emailController.dispose();
  }

  Future<void> sendPasswordResetEmail() async {
    print('ForgetPasswordController: sendPasswordResetEmail called');
    if (!formKey.currentState!.validate()) {
      print('ForgetPasswordController: Form validation failed');
      return;
    }
    
    final email = emailController.text.trim();
    print('ForgetPasswordController: Validated email: $email');
    
    if (email.isEmpty) {
      print('ForgetPasswordController: Email is empty');
      return;
    }
    
    try {
      _isLoading.value = true;
      _error.value = '';
      
      print('ForgetPasswordController: Sending password reset email to $email');

      await _authService.sendPassResetEmail(email);

      _emailSent.value = true;
      print('ForgetPasswordController: Password reset email marked as sent');
      Get.snackbar(
        'Success',
        'Password reset email sent to $email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      print('ForgetPasswordController: Error sending password reset email: $e');
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }finally{
      _isLoading.value = false;
    }
  }

  void goBackToLogin(){
    Navigator.pop(Get.context!);
  }


  void resendEmail(){
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

    String? validateEmail(String? value) {
    print('ForgetPasswordController: validateEmail called with value: $value');
    if(value?.isEmpty ?? true){
      print('ForgetPasswordController: Email validation failed - empty value');
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value!)) {
      print('ForgetPasswordController: Email validation failed - invalid format');
      return 'Please enter valid email';
    }
    print('ForgetPasswordController: Email validation passed');
    return null;
    }

    void _clearError(){
    _error.value = '';
    }

    void clearEmailSent() {
      _emailSent.value = false;
    }
}