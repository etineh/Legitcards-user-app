import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../services/live_support_service.dart';
import '../profile/support/live_support_screen.dart';

// Floating Support Button (for Home Screen)
class FloatingSupportButton extends StatelessWidget {
  final UserProfileM userProfile;

  const FloatingSupportButton({
    super.key,
    required this.userProfile,
  });

  Future<void> _openSupport(BuildContext context) async {
    final supportService = LiveSupportService();

    try {
      // Create or get existing open chat
      final chatId = await supportService.createOrGetChatSession(
        userId: userProfile.userid!,
        userName: '${userProfile.firstname} ${userProfile.lastname}',
        userEmail: userProfile.email!,
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveSupportScreen(
              userProfile: userProfile,
              chatId: chatId,
              isClosed: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportService = LiveSupportService();

    return StreamBuilder<int>(
      stream: supportService.getTotalUnreadCount(userProfile.userid!),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return FloatingActionButton(
          onPressed: () => _openSupport(context),
          backgroundColor: const Color(0xFF7C3AED),
          child: Stack(
            children: [
              const Icon(Icons.support_agent, color: Colors.white),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// List Tile with Badge (for Settings/Profile Screen)
class SupportListTile extends StatelessWidget {
  final UserProfileM userProfile;

  const SupportListTile({
    super.key,
    required this.userProfile,
  });

  Future<void> _openSupport(BuildContext context) async {
    final supportService = LiveSupportService();

    try {
      // Create or get existing open chat
      final chatId = await supportService.createOrGetChatSession(
        userId: userProfile.userid!,
        userName: '${userProfile.firstname} ${userProfile.lastname}',
        userEmail: userProfile.email!,
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveSupportScreen(
              userProfile: userProfile,
              chatId: chatId,
              isClosed: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportService = LiveSupportService();

    return StreamBuilder<int>(
      stream: supportService.getTotalUnreadCount(userProfile.userid!),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return ListTile(
          leading: const Icon(Icons.support_agent, color: Color(0xFF7C3AED)),
          title: const Text('Live Support'),
          subtitle: const Text('Chat with our support team'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _openSupport(context),
        );
      },
    );
  }
}

// Badge Widget (Reusable)
class UnreadBadge extends StatelessWidget {
  final String userId;
  final Widget child;
  final VoidCallback? onTap;

  const UnreadBadge({
    super.key,
    required this.userId,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final supportService = LiveSupportService();

    return StreamBuilder<int>(
      stream: supportService.getTotalUnreadCount(userId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              child,
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Usage Examples:
/*
// 1. Add floating button to home screen
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: YourHomeContent(),
    floatingActionButton: FloatingSupportButton(
      userProfile: userProfileM,
    ),
  );
}

// 2. Add to settings/profile screen
SupportListTile(userProfile: userProfileM),

// 3. Custom usage with badge
UnreadBadge(
  userId: userProfileM.userid!,
  onTap: () async {
    final supportService = LiveSupportService();
    final chatId = await supportService.createOrGetChatSession(
      userId: userProfileM.userid!,
      userName: '${userProfileM.firstname} ${userProfileM.lastname}',
      userEmail: userProfileM.email!,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveSupportScreen(
          userProfile: userProfileM,
          chatId: chatId,
          isClosed: false,
        ),
      ),
    );
  },
  child: Icon(Icons.support_agent),
)
*/
