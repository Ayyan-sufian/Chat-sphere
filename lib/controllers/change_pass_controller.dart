import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';

class ChangePassController extends GetxController{
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;
  final RxString _error = "".obs;
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
    // TODO: implement onClose
    super.onClose();
    currentPassController.dispose();
    confirmPassController.dispose();
  }

  void toggleCurrentPassVisibilty (){
    _obscureCurrentPass.value = !_obscureCurrentPass.value;
  }
  void toggleNewPassVisibilty (){
    _obscureNewPass.value = !_obscureNewPass.value;
  }
  void toggleConfirmPassVisibility (){
    _obscureConfirmPass.value = !_obscureConfirmPass.value;
  }

  Future<void> changePass()async{
    if(!formKey.currentState!.validate()) return;

    try{
      _isLoading.value = true;
      _error.value = '';

      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('No User Logged In');
      }

      final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassController.text);

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassController.text);
      
      Get.snackbar('Success', "Password change successfully",
      backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3)
      );

      currentPassController.clear();
      newPassController.clear();
      confirmPassController.clear();

      Navigator.pop(Get.context!);
    }on FirebaseAuthException catch (e){
      String errorMessage;
      switch(e.code){
        case 'wrong-password':
          errorMessage = 'Current passwords is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New passwords is weak';
          break;
        case 'require-recent-login':
          errorMessage = 'Please sign out and sign in again before changing password';
          break;

        default:
          errorMessage = 'Failed To change password';
      }

      _error.value = errorMessage;
      Get.snackbar('Error', errorMessage,
      backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3)
      );
    }catch (e) {
      _error.value = 'Failed to change password';
      Get.snackbar('Error', _error.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3)
      );
    }finally{
      _isLoading.value = false;
    }
  }

  String? validateCurrentPass(String? value){
    if (value?.isEmpty ?? true) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? validateNewPass(String? value){
    if (value?.isEmpty ?? true) {
      return 'Please enter your New password';
    }
    if(value!.length < 6) {
      return 'Password must be at least 6 character';
    }

    if (value == currentPassController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? validateConfirmPass(String? value){
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }


    if (value != newPassController.text) {
      return 'Password do not match';
    }
    return null;
  }

  void clearError(){
    _error.value = '';
  }
}