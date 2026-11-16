import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  bool _obscurePass = true;
  bool _obscureCheckPass = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _checkPassController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _checkPassController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    "Create an account",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Fill the blanks to create account",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSceTheme,
                        ),
                  ),
                  const SizedBox(height: 25),

                  TextFormField(
                    controller: _displayNameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      label: Text("Email"),
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      label: const Text("Password"),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePass = !_obscurePass;
                          });
                        },
                        icon: _obscurePass
                            ? const Icon(Icons.remove_red_eye_outlined)
                            : const Icon(Icons.visibility_off),
                      ),
                      hintText: 'Enter your password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _checkPassController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _obscureCheckPass,
                    decoration: InputDecoration(
                      label: const Text("Confirm Password"),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureCheckPass = !_obscureCheckPass;
                          });
                        },
                        icon: _obscureCheckPass
                            ? const Icon(Icons.remove_red_eye_outlined)
                            : const Icon(Icons.visibility_off),
                      ),
                      hintText: 'Enter your confirm password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your confirm password';
                      }
                      if (value != _passController.text) {
                        return 'Password do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _authController.registerWithEmailAndPass(
                                    _emailController.text.trim(),
                                    _passController.text,
                                    _displayNameController.text,
                                  );
                                }
                              },
                        child: _authController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign up'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppTheme.borderColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppTheme.borderColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.login);
                        },
                        child: Text(
                          "Sign In",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
