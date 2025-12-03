import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messanger/controllers/auth_controller.dart';
import 'package:messanger/controllers/home_controller.dart';
import 'package:messanger/controllers/main_controller.dart';
import 'package:messanger/theme/app_theme.dart';
import 'package:messanger/view/widget/chat_list_item.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, _authController),
      body: Column(
        children: [
          _buildSearchBar(),

          Obx(
            () => controller.isSearching && controller.searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildQuickFilter(),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshChats,
              child: Obx(() {
                if (controller.chats.isEmpty) {
                  if (controller.isSearching &&
                      controller.searchQuery.isNotEmpty) {
                    return _buildNoSearchResults();
                  } else if (controller.activeFilter != 'All') {
                    return _buildNoFilterResults();
                  } else {
                    return _buildEmptyState();
                  }
                }
                return _buildChatsList();
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AuthController authController,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textSceTheme,
      elevation: 0,
      title: Obx(
        () => Text(
          controller.isSearching ? 'Searching results' : 'Message',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        controller.isSearching
            ? IconButton(
                onPressed: controller.clearSearch,
                icon: Icon(Icons.clear_rounded),
              )
            : _buildNotificationButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Obx(() {
      final unreadNotifications = controller.getUnreadNotificationsCount();

      return Container(
        margin: EdgeInsets.only(right: 8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: controller.openNotifications,
                icon: Icon(Icons.notifications_outlined),
                iconSize: 22,
                splashRadius: 20,
              ),
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadNotifications > 99
                        ? '99+'
                        : unreadNotifications.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 12, 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search Conversation...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: Colors.grey[500],
            ),
            suffixIcon: Obx(
              () => controller.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: controller.clearSearch,
                      icon: Icon(
                        Icons.clear_rounded,
                        size: 20,
                        color: Colors.grey[500],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilter() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(
              () => _buildFilterChip(
                'All',
                () => controller.setFilter('All'),
                controller.activeFilter == 'All',
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => _buildFilterChip(
                'Unread (${controller.getUnreadChats().length})',
                () => controller.setFilter('Unread'),
                controller.activeFilter == 'Unread',
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => _buildFilterChip(
                'Recent (${controller.getUnreadChats().length})',
                () => controller.setFilter('Recent'),
                controller.activeFilter == 'Recent',
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => _buildFilterChip(
                'Active (${controller.getActiveChats().length})',
                () => controller.setFilter('Active'),
                controller.activeFilter == 'Active',
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 18, 8),
      child: Row(
        children: [
          Obx(
            () => Text(
              'Found ${controller.filteredChats.length} results ${controller.filteredChats.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 14, color: AppTheme.textSceTheme),
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: controller.clearSearch,
            child: Text(
              "Clear",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 64,
                color: Colors.grey[500],
              ),
              SizedBox(height: 16),
              Text(
                'No conversation found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textPrimaryTheme,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'No result found ${controller.searchQuery}',
                style: TextStyle(fontSize: 18, color: AppTheme.textSceTheme),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFilterResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFilterIcon(controller.activeFilter),
                size: 64,
                color: Colors.grey[500],
              ),
              SizedBox(height: 16),
              Text(
                'No ${controller.activeFilter.toLowerCase()} conversations',
                style: TextStyle(fontSize: 18, color: AppTheme.primaryColor),
              ),
              SizedBox(height: 8),
              Text(
                _getFilterEmptyMessage(controller.activeFilter),
                style: TextStyle(color: AppTheme.textSceTheme),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.setFilter('All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Show All conversations"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Unread':
        return Icons.mark_email_unread_rounded;
      case 'Recent':
        return Icons.schedule_outlined;
      case 'Active':
        return Icons.trending_up_outlined;

      default:
        return Icons.filter_list_outlined;
    }
  }

  String _getFilterEmptyMessage(String filter) {
    switch (filter) {
      case 'Unread':
        return 'All your conversations are up to date';
      case 'Recent':
        return 'No conversation from last 3 days';
      case 'Active':
        return 'No conversation from last week days';

      default:
        return 'No conversation found';
    }
  }

  Widget _buildChatsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          if (!controller.isSearching || controller.searchQuery.isNotEmpty)
            _buildChatHeader(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: controller.isSearching ? 16 : 8,
                horizontal: 16,
              ),
              itemBuilder: (context, index) {
                final chat = controller.chats[index];
                final otherUser = controller.getOtherUser(chat);

                if (otherUser == null) {
                  return SizedBox.shrink();
                }

                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: ChatListItem(
                    chat: chat,
                    otherUser: otherUser,
                    lastMessageTime: controller.formatLastMessageDate(
                      chat.lastMessageTime,
                    ),
                    onTap: () => controller.openChat(chat),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey[200], indent: 72),
              itemCount: controller.chats.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: controller.openFriends,
        icon: Icon(Icons.chat_outlined),
        label: Text(
          "New chat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            String title = 'Recent Chats';
            switch (controller.activeFilter) {
              case 'Unread':
                title = 'Unread Message';
                break;
              case 'Recent':
                title = 'Recent Message';
                break;
              case 'Active':
                title = 'Unread Message';
                break;
            }
            return Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryTheme,
              ),
            );
          }),

          Row(
            children: [
              if (controller.activeFilter != 'All')
                TextButton(
                  onPressed: controller.clearAllFilters,
                  child: Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 24),
              Column(
                children: [
                  Text(
                    "No conversation yet",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryTheme,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Connect with friends and start meaningful conversation.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppTheme.textSceTheme,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 24),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final mainController = Get.find<MainController>();
                        mainController.changeTabIndex(2);
                      },
                      icon: Icon(Icons.person_search_rounded),
                      label: Text(
                        "Find people",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final mainController = Get.find<MainController>();
                        mainController.changeTabIndex(1);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: AppTheme.primaryColor)
                      ),
                      icon: Icon(Icons.person_search_rounded),
                      label: Text(
                        "View people",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
