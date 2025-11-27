import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/friends_controller.dart';
import 'package:messanger/theme/app_theme.dart';
import 'package:messanger/view/widget/friend_list_item.dart';

class FriendsScreen extends GetView<FriendsController> {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        leading: SizedBox(),
        actions: [
          IconButton(onPressed: () => controller.openFriendRequest(), icon: Icon(Icons.person_add_alt_1))
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor.withOpacity(0.5),
                  width: 1
                )
              )
            ),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Obx((){
                  return controller.searchQuery.isNotEmpty
                      ? IconButton(onPressed: controller.clearSearchQuery, icon: Icon(Icons.clear))
                      : SizedBox();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderColor)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderColor)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 1)
                ),
                filled: true,
                fillColor: Colors.white
              )
            ),
          ),
          Expanded(child: RefreshIndicator(onRefresh: controller.refreshFriends, child: Obx((){
            if(controller.isLoading && controller.friends.isNotEmpty){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(controller.filteredFriends.isEmpty){
              return _buildEmptyState();
            }
            return ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: controller.filteredFriends.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final friend = controller.filteredFriends[index];
                return  FriendListItem(
                  friend: friend,
                  lastSeenText: controller.getLastSeenText(friend),
                  onTap: () => controller.startChat(friend),
                  onRemove: () => controller.removeFriend(friend),
                  onBlock: () => controller.blockFriend(friend),
                );
              },

            );
          })))
        ],
      )
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
              child: Icon(
                Icons.person_2_outlined,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              controller.searchQuery.isNotEmpty
                  ? "No result found."
                  : 'No friends yet.',
              style: Theme
                  .of(Get.context!)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                color: AppTheme.textSceTheme,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add friends to start chatting with them',
              style: Theme
                  .of(Get.context!)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: AppTheme.textSceTheme,
              ),
              textAlign: TextAlign.center,
            ),

            if (controller.searchQuery.isNotEmpty) ...[
              SizedBox(height: 8),
              ElevatedButton.icon(onPressed: () => controller.openFriendRequest(), icon: Icon(Icons.person_add_alt_1),
              label: Text('View friend requests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              )
            ],
            ],
        ),
      ),
    );
  }
}