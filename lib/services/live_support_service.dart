import 'package:firebase_database/firebase_database.dart';

import '../data/models/message_model.dart';

class LiveSupportService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Send message
  Future<void> sendMessage({
    required String userId,
    required String userName,
    required String userEmail,
    required String message,
    bool isAdmin = false,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final messageId = _database
          .child('support_chats')
          .child(userId)
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
          .child('messages')
          .child(messageId!)
          .set(messageData);

      // Update chat session
      await _database.child('support_chats').child(userId).update({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'lastMessage': message,
        'lastMessageTime': timestamp,
        'status': 'open',
      });

      // Increment unread count for admin if user sent message
      if (!isAdmin) {
        await _incrementUnreadCount(userId);
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Listen to messages
  Stream<List<SupportMessageM>> listenToMessages(String userId) {
    return _database
        .child('support_chats')
        .child(userId)
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
  Future<void> markMessagesAsRead(String userId, bool isAdmin) async {
    try {
      final snapshot = await _database
          .child('support_chats')
          .child(userId)
          .child('messages')
          .get();

      if (snapshot.value != null) {
        final messagesMap = snapshot.value as Map<dynamic, dynamic>;

        for (var entry in messagesMap.entries) {
          final message = entry.value as Map<dynamic, dynamic>;
          final messageIsAdmin = message['isAdmin'] as bool? ?? false;

          // Mark unread messages from the other party as read
          if (messageIsAdmin != isAdmin && message['isRead'] == false) {
            await _database
                .child('support_chats')
                .child(userId)
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
            .update({'unreadCount': 0});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread count
  Stream<int> getUnreadCount(String userId) {
    return _database
        .child('support_chats')
        .child(userId)
        .child('unreadCount')
        .onValue
        .map((event) => (event.snapshot.value as int?) ?? 0);
  }

  // Close chat
  Future<void> closeChat(String userId) async {
    try {
      await _database.child('support_chats').child(userId).update({
        'status': 'closed',
      });
    } catch (e) {
      print('Error closing chat: $e');
    }
  }

  // Private helper to increment unread count
  Future<void> _incrementUnreadCount(String userId) async {
    try {
      final snapshot = await _database
          .child('support_chats')
          .child(userId)
          .child('unreadCount')
          .get();

      final currentCount = (snapshot.value as int?) ?? 0;

      await _database
          .child('support_chats')
          .child(userId)
          .update({'unreadCount': currentCount + 1});
    } catch (e) {
      print('Error incrementing unread count: $e');
    }
  }

  // Check if chat exists
  Future<bool> chatExists(String userId) async {
    final snapshot = await _database.child('support_chats').child(userId).get();
    return snapshot.exists;
  }
}
