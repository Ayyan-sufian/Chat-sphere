import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/friend_request_controller.dart';
import 'package:messanger/models/friend_request_model.dart';
import 'package:messanger/models/user_model.dart';

import '../../theme/app_theme.dart';

class FriendRequestItem extends StatelessWidget {
  final FriendRequestModel request;
  final UserModel user;
  final String timeText;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? statusText;
  final Color? statusColor;

  const FriendRequestItem({
    super.key,
    required this.request,
    required this.user,
    required this.timeText,
    required this.isReceived,
    this.onAccept,
    this.onDecline,
    this.statusText,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FriendRequestController>();
    final isLoading = controller.requestLoadingStates[request.id] ?? false;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: user.photoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            user.photoUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0].toUpperCase()
                                    : 'No Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : 'No Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSceTheme,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),

                if (isReceived &&
                    request.status == FriendRequestStatus.pending &&
                    !isLoading) ...[
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.check),
                        label: Text('Accept'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onDecline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.close),
                        label: Text('Decline'),
                      ),
                    ],
                  ),
                ] else if (isReceived && isLoading) ...[
                  SizedBox(height: 8),
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                ] else if (isReceived &&
                    (request.status == FriendRequestStatus.accepted ||
                        request.status == FriendRequestStatus.declined)) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: request.status == FriendRequestStatus.accepted
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          size: 16,
                          color: request.status == FriendRequestStatus.accepted
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          request.status == FriendRequestStatus.accepted
                              ? 'Accepted'
                              : 'Declined',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: request.status == FriendRequestStatus.accepted
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!isReceived && statusText != null && !isLoading) ...[
                  SizedBox(height: 8),
                  if (request.status == FriendRequestStatus.pending) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => controller.cancelSentRequest(request.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(Icons.close),
                          label: Text('Cancel'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          size: 16,
                          color: statusColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          statusText!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: statusColor ?? AppTheme.textSceTheme,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!isReceived && isLoading) ...[
                  SizedBox(height: 8),
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.accepted:
        return Icons.check_circle;
      case FriendRequestStatus.declined:
        return Icons.cancel;
      case FriendRequestStatus.pending:
      default:
        return Icons.info;
    }
  }
}
