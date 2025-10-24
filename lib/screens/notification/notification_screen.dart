// screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../data/repository/secure_storage_repo.dart';
import '../widgets/notification_card_wg.dart';
import 'notification_detail_screen.dart';
import 'notification_view_model.dart';

class NotificationScreen extends StatefulWidget {
  final UserProfileM user;

  const NotificationScreen({super.key, required this.user});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationVM =
          Provider.of<NotificationViewModel>(context, listen: false);
      notificationVM.fetchNotifications(widget.user.userid!, widget.user.token!,
          refresh: true);
    });

    SecureStorageRepo.saveNotificationIsUnread(widget.user, false);

    // Setup pagination
    // _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final notificationVM =
          Provider.of<NotificationViewModel>(context, listen: false);
      notificationVM.fetchNotifications(
          widget.user.userid!, widget.user.token!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "Notifications"),
      body: Consumer<NotificationViewModel>(
        builder: (context, notificationVM, child) {
          // Loading state (first load)
          if (notificationVM.isLoading &&
              notificationVM.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (notificationVM.errorMessage != null &&
              notificationVM.notifications.isEmpty) {
            errorState(notificationVM);
          }

          // Empty state
          if (notificationVM.notifications.isEmpty) {
            emptyState(notificationVM);
          }

          // Notification list
          return RefreshIndicator(
            onRefresh: () async {
              await notificationVM.fetchNotifications(
                widget.user.userid!,
                widget.user.token!,
                refresh: true,
              );
            },
            child: _listView(notificationVM),
          );
        },
      ),
    );
  }

  Widget errorState(NotificationViewModel notificationVM) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            notificationVM.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              notificationVM.fetchNotifications(
                widget.user.userid!,
                widget.user.token!,
                refresh: true,
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget emptyState(NotificationViewModel notificationVM) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll show up here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  ListView _listView(NotificationViewModel notificationVM) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: notificationVM.notifications.length + 1,
      itemBuilder: (context, index) {
        // Loading indicator at bottom
        if (index == notificationVM.notifications.length) {
          if (notificationVM.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        final notification = notificationVM.notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailScreen(
                  notification: notification,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
