import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/date_utils.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/live_support_service.dart';
import 'live_support_screen.dart';

class SupportChatListScreen extends StatelessWidget {
  final UserProfileM userProfile;

  const SupportChatListScreen({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final supportService = LiveSupportService();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "Support Chats"),
      body: StreamBuilder<List<SupportChatM>>(
        stream: supportService.getUserChats(userProfile.userid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation with support',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _startNewChat(context),
                    icon: const Icon(Icons.add_comment),
                    label: const Text('Start New Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatItem(context, chat);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context),
        backgroundColor: AppColors.lightPurple,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, SupportChatM chat) {
    final isClosed = chat.status == "closed";

    return InkWell(
      onTap: () => _openChat(context, chat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isClosed
                ? Colors.grey.shade300.withOpacity(0.3)
                : AppColors.lightPurple.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: isClosed
                  ? Colors.grey.shade300
                  : AppColors.lightPurple.withOpacity(0.2),
              child: Icon(
                Icons.support_agent,
                color: isClosed ? Colors.grey : AppColors.lightPurple,
              ),
            ),
            const SizedBox(width: 12),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Support Chat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.blackWhite,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isClosed
                              ? Colors.grey.shade200
                              : AppColors.lightPurple.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isClosed ? 'CLOSED' : "OPEN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                isClosed ? Colors.grey : AppColors.lightPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage ?? 'No messages',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateAndTimeUtils.formatTimestamp(chat.lastMessageTime!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Unread badge
            if (chat.unreadCount! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat.unreadCount! > 9 ? '9+' : '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, SupportChatM chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveSupportScreen(
          userProfile: userProfile,
          chatId: chat.chatId!,
          isClosed: chat.status == "closed",
        ),
      ),
    );
  }

  void _startNewChat(BuildContext context) async {
    final supportService = LiveSupportService();

    try {
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
          SnackBar(content: Text('Error creating chat: $e')),
        );
      }
    }
  }
}
