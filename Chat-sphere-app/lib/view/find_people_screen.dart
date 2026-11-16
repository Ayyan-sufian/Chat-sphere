import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_list_controller.dart';
import '../theme/app_theme.dart';
import '../view/widget/user_list_item.dart';

class FindPeopleScreen extends GetView<UsersListController> {
  const FindPeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find People'),
        leading: const SizedBox(),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshUsers,
              child: Obx(() {
                if (controller.filteredUsers.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return UserListItem(
                      user: user,
                      onTap: () => controller.handleRelationshipAction(user),
                      controller: controller,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: controller.filteredUsers.length,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
        ),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search here',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            return controller.searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      controller.clearSearch();
                    },
                    icon: const Icon(Icons.clear),
                  )
                : const SizedBox.shrink();
          }),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              controller.searchQuery.isNotEmpty
                  ? "No result found."
                  : 'No people found.',
              style: Theme.of(Get.context!)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: AppTheme.textSceTheme,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'All user will show here',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimaryTheme,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
