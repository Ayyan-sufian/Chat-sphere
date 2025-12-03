import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/user_list_controller.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/theme/app_theme.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final UsersListController controller;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final relationshipStatus = controller.getUserRelationshipStatus(user.id);

      if (relationshipStatus == UserRelationshipStatus.friends) {
        return SizedBox.shrink();
      }
      return Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toLowerCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(Get.context!).textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(Get.context!).textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textSceTheme),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      controller.getLastSeenText(user),
                      style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: user.isOnline ? Colors.green : AppTheme.textSceTheme,
                        fontWeight: user.isOnline ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(children: [_buildActionButton(relationshipStatus),
              if (relationshipStatus == UserRelationshipStatus.friendRequestReceive)... [
                SizedBox(height: 4,),
                OutlinedButton.icon(
                  onPressed: () => controller.deleteFriendRequest(user),
                  label: Text("Decline",style: TextStyle(fontSize: 10, color: Colors.white),),
                  icon: Icon(Icons.close,color: Colors.white),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    minimumSize: Size(0, 24)
                  ),
                )
              ]
              ],),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton(UserRelationshipStatus relationshipStatus) {
    switch (relationshipStatus) {
      case UserRelationshipStatus.none:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          icon: Icon(controller.getRelationshipButtonIcon(relationshipStatus)),
          label: Text(controller.getRelationshipButtonText(relationshipStatus)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getRelationshipButtonColor(
              relationshipStatus,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: Size(0, 32),
          ),
        );

      case UserRelationshipStatus.friendRequestSent:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: controller
                    .getRelationshipButtonColor(relationshipStatus)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.getRelationshipButtonColor(
                    relationshipStatus,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getRelationshipButtonIcon(relationshipStatus),
                    color: controller.getRelationshipButtonColor(
                      relationshipStatus,
                    ),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    controller.getRelationshipButtonText(relationshipStatus),
                    style: TextStyle(
                      color: controller.getRelationshipButtonColor(
                        relationshipStatus,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showCancelRequest(),
              icon: Icon(Icons.cancel_outlined, size: 14),
              label: Text("cancel", style: TextStyle(fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                minimumSize: Size(0, 24),
              ),
            ),
          ],
        );

      case UserRelationshipStatus.friendRequestReceive:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          icon: Icon(controller.getRelationshipButtonIcon(relationshipStatus)),
          label: Text(controller.getRelationshipButtonText(relationshipStatus)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getRelationshipButtonColor(
              relationshipStatus,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: Size(0, 32),
          ),
        );

      case UserRelationshipStatus.blocked:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: AppTheme.errorColor),
              SizedBox(width: 4),
              Text(
                "Blocked",
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );

      case UserRelationshipStatus.friends:
        return SizedBox.shrink();
    }
  }

  void _showCancelRequest() {
    Get.dialog(
      AlertDialog(
        title: Text("Cancel friend request"),
        content: Text(
          "Are you sure you want to cancel the friend request to ${user.displayName}",
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(Get.context!);
          }
              , child: Text("Keep Request")),
          TextButton(
            onPressed: () {
              Navigator.pop(Get.context!);
              controller.cancelFriendRequest(user);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(
              "Cancel Request",
            ),
          ),
        ],
      ),
    );
  }
}
