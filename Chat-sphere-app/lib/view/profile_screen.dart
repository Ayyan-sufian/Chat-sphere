import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          onPressed: () => Navigator.pop(Get.context!),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.toggleEditing,
              child: Text(
                controller.isEditing ? 'Cancel' : "Edit",
                style: TextStyle(
                  color: controller.isEditing
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser;

        if (user == null) {
          return _buildLoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor,
                    child: (user.photoUrl.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              user.photoUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTace) {
                                return _buildDefaultAvatar(user);
                              },
                            ),
                          )
                        : _buildDefaultAvatar(user),
                  ),
                  if (controller.isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.snackbar(
                              "Info",
                              "Photo update coming soon!",
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                user.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),

              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSceTheme,
                    ),
              ),

              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: user.isOnline
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.textSceTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: user.isOnline
                            ? AppTheme.successColor
                            : AppTheme.textSceTheme,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: user.isOnline
                                ? AppTheme.successColor
                                : AppTheme.textSceTheme,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                controller.getJoinedData(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSceTheme,
                    ),
              ),

              const SizedBox(height: 32),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Information",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller.displayNameController,
                        enabled: controller.isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller.emailController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          helperText: "Email can't be changed",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      if (controller.isEditing) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : controller.updateProfile,
                            child: controller.isLoading
                                ? const CircularProgressIndicator(
                                    color: AppTheme.primaryColor,
                                    strokeWidth: 2,
                                  )
                                : const Text("Save changes"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.security,
                        color: AppTheme.primaryColor,
                      ),
                      title: const Text("Change Password"),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryColor,
                      ),
                      onTap: () => Get.toNamed(AppRoutes.changePass),
                    ),
                    const Divider(color: Colors.green, height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorColor,
                      ),
                      title: const Text("Delete Account"),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryColor,
                      ),
                      onTap: () => controller.deleteAccount(),
                    ),
                    const Divider(height: 1, color: AppTheme.errorColor),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: AppTheme.errorColor,
                      ),
                      title: const Text("Sign out"),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryColor,
                      ),
                      onTap: () => controller.signOut(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "ChatSphere V1.0.0",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSceTheme,
                    ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          const Text(
            "Loading profile...",
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSceTheme,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Get.find<ProfileController>().loadUserData();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(UserModel user) {
    return Text(
      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
    );
  }
}
