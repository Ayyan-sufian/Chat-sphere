import 'package:flutter/material.dart';
import 'package:messanger/models/user_model.dart';
import 'package:messanger/theme/app_theme.dart';

class FriendListItem extends StatelessWidget {
  final UserModel friend;
  final String lastSeenText;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onBlock;

  const FriendListItem({
    super.key,
    required this.lastSeenText,
    required this.onTap,
    required this.onRemove,
    required this.onBlock,
    required this.friend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: friend.photoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.network(
                              friend.photoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _buildDefaultAvatar(),
                  ),
                  if (friend.isOnline) ...[
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      friend.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSceTheme,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      lastSeenText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: friend.isOnline ? Colors.green: AppTheme.textSceTheme,
                        fontWeight: friend.isOnline ? FontWeight.w600: FontWeight.normal
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'message':
                      onTap();
                      break;
                    case 'Remove':
                      onRemove();
                      break;
                    case 'Block':
                      onBlock();
                      break;
                  }
                },
                itemBuilder: (context) => [
                   PopupMenuItem(
                    value: 'message',
                    child: ListTile(
                      leading: Icon(Icons.chat_bubble_outline,color: AppTheme.primaryColor,),
                      title: Text('Message'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Remove',
                    child: ListTile(
                      leading: Icon(Icons.remove,color: AppTheme.primaryColor,),
                      title: Text('Remove'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Block',
                    child: ListTile(
                      leading: Icon(Icons.block,color: AppTheme.primaryColor,),
                      title: Text('Block'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Text(
      friend.displayName.isNotEmpty
          ? friend.displayName[0].toUpperCase()
          : 'No Name',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
