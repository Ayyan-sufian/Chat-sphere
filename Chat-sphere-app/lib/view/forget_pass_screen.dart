import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forget_password_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class ForgetPassScreen extends StatelessWidget {
  const ForgetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.clearEmailSent();
                        Get.offAllNamed(AppRoutes.login);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Forget Password",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 58.0),
                  child: Text(
                    "Enter your email to receive password reset link",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSceTheme,
                        ),
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.lock_reset_outlined,
                      color: AppTheme.primaryColor,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Obx(() {
                  if (controller.emailSent) {
                    return _buildEmailSent(controller);
                  } else {
                    return _buildEmailForm(controller);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(ForgetPasswordController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              label: Text("Email"),
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'Please enter your email',
            ),
            validator: controller.validateEmail,
          ),
          const SizedBox(height: 32),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading
                    ? null
                    : controller.sendPasswordResetEmail,
                icon: controller.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  controller.isLoading ? "Sending" : "Send email link",
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password?",
                style: Theme.of(Get.context!).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.login);
                },
                child: Text(
                  "Sign In",
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSent(ForgetPasswordController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.mark_email_read_rounded,
                    size: 60,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Email sent!",
                    style: Theme.of(Get.context!)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We have sent a password reset link!",
                    style: Theme.of(Get.context!)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: AppTheme.successColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.emailController.text,
                    style: Theme.of(Get.context!)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Check your email and follow the instructions to reset your password",
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSceTheme,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.resendEmail,
                icon: const Icon(Icons.refresh),
                label: const Text("Resend Email"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.clearEmailSent();
                  Get.offAllNamed(AppRoutes.login);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Sign In"),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Didn't receive the mail? Check your spam folder or try again",
                      style:
                          Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                                color: AppTheme.secondaryColor,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
