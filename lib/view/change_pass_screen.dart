import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:messanger/controllers/change_pass_controller.dart';
import 'package:messanger/theme/app_theme.dart';

class ChangePassScreen extends StatelessWidget {
  const ChangePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePassController());
    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Update your password",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Enter your current password and enter a secure password.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSceTheme,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 40),
                Obx(
                  () => TextFormField(
                    controller: controller.currentPassController,
                    obscureText: controller.obscureCurrentPass,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      helperText: 'Enter your current password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: controller.toggleCurrentPassVisibilty,
                        icon: Icon(
                          controller.obscureCurrentPass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: controller.validateCurrentPass,
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: controller.newPassController,
                    obscureText: controller.obscureNewPass,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      helperText: 'Enter your new password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: controller.toggleNewPassVisibilty,
                        icon: Icon(
                          controller.obscureNewPass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: controller.validateNewPass,
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => TextFormField(
                    controller: controller.confirmPassController,
                    obscureText: controller.obscureConfirmPass,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      helperText: 'Enter your confirm password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: controller.toggleConfirmPassVisibility,
                        icon: Icon(
                          controller.obscureConfirmPass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: controller.validateConfirmPass,
                  ),
                ),
                SizedBox(height: 40),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : controller.changePass,
                      icon: controller.isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Icon(Icons.security),
                      label: Text(
                        controller.isLoading ? 'Update..' : 'Update password',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
