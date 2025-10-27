class SupportMessageM {
  final String? messageId;
  final String? senderId;
  final String? senderName;
  final String? message;
  final int? timestamp;
  final bool? isAdmin;
  final bool? isRead;

  SupportMessageM({
    this.messageId,
    this.senderId,
    this.senderName,
    this.message,
    this.timestamp,
    this.isAdmin,
    this.isRead,
  });

  factory SupportMessageM.fromJson(Map<dynamic, dynamic> json) {
    return SupportMessageM(
      messageId: json['messageId'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as int?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'isAdmin': isAdmin,
      'isRead': isRead,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0);

  String get formattedTime {
    final date = dateTime;
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month} ${date.hour}:${date.minute}';
  }
}

// Chat Session Model
class SupportChatM {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? lastMessage;
  final int? lastMessageTime;
  final int? unreadCount;
  final String? status; // open, closed, pending
  final List<SupportMessageM>? messages;
  // final bool isClosed;
  final String? chatId;

  const SupportChatM({
    this.userId,
    this.userName,
    this.userEmail,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    this.status,
    this.messages,
    // this.isClosed = true,
    this.chatId,
  });

  factory SupportChatM.fromJson(Map<dynamic, dynamic> json) {
    List<SupportMessageM> messagesList = [];

    if (json['messages'] != null) {
      final messagesMap = json['messages'] as Map<dynamic, dynamic>;
      messagesList = messagesMap.entries
          .map((entry) => SupportMessageM.fromJson(entry.value))
          .toList()
        ..sort((a, b) => (a.timestamp ?? 0).compareTo(b.timestamp ?? 0));
    }

    return SupportChatM(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] as int?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'open',
      messages: messagesList,
      // isClosed: json['isClosed'] as bool? ?? true,
      chatId: json['chatId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'status': status,
      // 'isClosed': isClosed,
      'chatId': chatId,
    };
  }
}
