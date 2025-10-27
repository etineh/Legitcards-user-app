import 'package:firebase_database/firebase_database.dart';

import '../data/models/message_model.dart';

class LiveSupportService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Create or get chat session
  Future<String> createOrGetChatSession({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      // Check if user has any open chats
      final snapshot = await _database
          .child('support_chats')
          .child(userId)
          .orderByChild('status')
          .equalTo('open')
          .limitToLast(1)
          .get();

      if (snapshot.exists) {
        // Return existing open chat
        final chats = snapshot.value as Map<dynamic, dynamic>;
        return chats.keys.first as String;
      }

      // Create new chat session
      final chatId = _database.child('support_chats').child(userId).push().key;

      await _database.child('support_chats').child(userId).child(chatId!).set({
        'chatId': chatId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'status': 'open',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'unreadCount': 0,
      });

      return chatId;
    } catch (e) {
      print('Error creating chat session: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String userId,
    required String chatId,
    required String userName,
    required String message,
    bool isAdmin = false,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final messageId = _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .child('messages')
          .push()
          .key;

      final messageData = {
        'messageId': messageId,
        'senderId': userId,
        'senderName': userName,
        'message': message,
        'timestamp': timestamp,
        'isAdmin': isAdmin,
        'isRead': false,
      };

      // Save message
      await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .child('messages')
          .child(messageId!)
          .set(messageData);

      // Update chat session
      await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .update({
        'lastMessage': message,
        'lastMessageTime': timestamp,
      });

      // Increment unread count for admin if user sent message
      if (!isAdmin) {
        await _incrementUnreadCount(userId, chatId);
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get all chat sessions for user
  Stream<List<SupportChatM>> getUserChats(String userId) {
    return _database.child('support_chats').child(userId).onValue.map((event) {
      if (event.snapshot.value == null) return <SupportChatM>[];

      final chatsMap = event.snapshot.value as Map<dynamic, dynamic>;
      final chats = chatsMap.entries
          .map((entry) => SupportChatM.fromJson(entry.value))
          .toList()
        ..sort((a, b) =>
            (b.lastMessageTime ?? 0).compareTo(a.lastMessageTime ?? 0));

      return chats;
    });
  }

  // Get chat status
  Future<String> getChatStatus(String userId, String chatId) async {
    final snapshot = await _database
        .child('support_chats')
        .child(userId)
        .child(chatId)
        .child('status')
        .get();

    return (snapshot.value as String?) ?? 'open';
  }

  // Listen to messages for specific chat
  Stream<List<SupportMessageM>> listenToMessages(String userId, String chatId) {
    return _database
        .child('support_chats')
        .child(userId)
        .child(chatId)
        .child('messages')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <SupportMessageM>[];

      final messagesMap = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = messagesMap.entries
          .map((entry) => SupportMessageM.fromJson(entry.value))
          .toList()
        ..sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));

      return messages;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
      String userId, String chatId, bool isAdmin) async {
    try {
      final snapshot = await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .child('messages')
          .get();

      if (snapshot.value != null) {
        final messagesMap = snapshot.value as Map<dynamic, dynamic>;

        for (var entry in messagesMap.entries) {
          final message = entry.value as Map<dynamic, dynamic>;
          final messageIsAdmin = message['isAdmin'] as bool? ?? false;

          if (messageIsAdmin != isAdmin && message['isRead'] == false) {
            await _database
                .child('support_chats')
                .child(userId)
                .child(chatId)
                .child('messages')
                .child(entry.key)
                .update({'isRead': true});
          }
        }
      }

      // Reset unread count
      if (!isAdmin) {
        await _database
            .child('support_chats')
            .child(userId)
            .child(chatId)
            .update({'unreadCount': 0});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread count for specific chat
  Stream<int> getUnreadCount(String userId, String chatId) {
    return _database
        .child('support_chats')
        .child(userId)
        .child(chatId)
        .child('unreadCount')
        .onValue
        .map((event) => (event.snapshot.value as int?) ?? 0);
  }

  // Get total unread count for all user chats
  Stream<int> getTotalUnreadCount(String userId) {
    return _database.child('support_chats').child(userId).onValue.map((event) {
      if (event.snapshot.value == null) return 0;

      final chatsMap = event.snapshot.value as Map<dynamic, dynamic>;
      int totalUnread = 0;

      for (var entry in chatsMap.values) {
        if (entry is Map) {
          totalUnread += (entry['unreadCount'] as int?) ?? 0;
        }
      }

      return totalUnread;
    });
  }

  // Close chat
  Future<void> closeChat(String userId, String chatId) async {
    try {
      await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .update({
        'status': 'closed',
        'closedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error closing chat: $e');
    }
  }

  // Reopen chat
  Future<void> reopenChat(String userId, String chatId) async {
    try {
      await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .update({
        'status': 'open',
        'reopenedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error reopening chat: $e');
    }
  }

  // Private helper to increment unread count
  Future<void> _incrementUnreadCount(String userId, String chatId) async {
    try {
      final snapshot = await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .child('unreadCount')
          .get();

      final currentCount = (snapshot.value as int?) ?? 0;

      await _database
          .child('support_chats')
          .child(userId)
          .child(chatId)
          .update({'unreadCount': currentCount + 1});
    } catch (e) {
      print('Error incrementing unread count: $e');
    }
  }

  // Check if chat exists
  Future<bool> chatExists(String userId, String chatId) async {
    final snapshot = await _database
        .child('support_chats')
        .child(userId)
        .child(chatId)
        .get();
    return snapshot.exists;
  }
}
