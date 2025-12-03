import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/controllers/friend_request_controller.dart';
import 'package:messanger/models/friend_request_model.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/theme/app_theme.dart';
import 'package:messanger/view/widget/friend_request_item.dart';

class FriendRequestScreen extends GetView<FriendRequestController> {
  FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.selectedTabIndex == 0
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              color: controller.selectedTabIndex == 0
                                  ? Colors.white
                                  : AppTheme.textSceTheme,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Receive (${controller.receivedRequests.length})',
                              style: TextStyle(
                                color: controller.selectedTabIndex == 0
                                    ? Colors.white
                                    : AppTheme.textSceTheme,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: controller.selectedTabIndex == 1
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              color: controller.selectedTabIndex == 1
                                  ? Colors.white
                                  : AppTheme.textSceTheme,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sent (${controller.sentRequests.length})',
                              style: TextStyle(
                                color: controller.selectedTabIndex == 1
                                    ? Colors.white
                                    : AppTheme.textSceTheme,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(controller.selectedTabIndex),
                  child: controller.selectedTabIndex == 0 
                    ? _buildReceiveRequestsTab()
                    : _buildSendRequestsTab(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiveRequestsTab() {
    return Obx(() {
      if (controller.receivedRequests.isEmpty) {
        return _buildEmptyState(
          icon: Icons.inbox,
          title: 'No friend requests',
          message: 'You have no friend requests yet',
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final request = controller.receivedRequests[index];
          final sender = controller.getUser(request.senderId);
          if (sender == null) {
            return Container();
          }
          return FriendRequestItem(
            request: request,
            user: sender,
            timeText: controller.getRequestTime(request.createdAt),
            isReceived: true,
            onAccept: () => controller.acceptFriendRequest(request),
            onDecline: () => controller.declineFriendRequest(request),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemCount: controller.receivedRequests.length,
      );
    });
  }

  Widget _buildSendRequestsTab() {
    return Obx(() {
      if (controller.sentRequests.isEmpty) {
        return _buildEmptyState(
          icon: Icons.send,
          title: 'No sent requests',
          message: 'You have no sent friend requests yet',
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final request = controller.sentRequests[index];
          final receiver = controller.getUser(request.receiverId);
          if (receiver == null) {
            return Container();
          }
          return FriendRequestItem(
            request: request,
            user: receiver,
            timeText: controller.getRequestTime(request.createdAt),
            isReceived: false,
            statusText: controller.getRequestStatus(request.status),
            statusColor: controller.getStatusColor(request.status),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemCount: controller.sentRequests.length,
      );
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, size: 40, color: AppTheme.primaryColor),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                Get.context!,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryColor),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                Get.context!,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSceTheme),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
