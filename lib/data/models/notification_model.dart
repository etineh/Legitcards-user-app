// models/notification_model.dart

class NotificationResponseM {
  final String status;
  final String message;
  final int noteCount;
  final List<NotificationM> allNote;

  NotificationResponseM({
    required this.status,
    required this.message,
    required this.noteCount,
    required this.allNote,
  });

  factory NotificationResponseM.fromJson(Map<String, dynamic> json) {
    return NotificationResponseM(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      noteCount: json['note_count'] ?? 0,
      allNote: (json['all_note'] as List?)
              ?.map((e) => NotificationM.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class NotificationM {
  final String id;
  final int timer;
  final NotificationContent notification;
  final String receiverId;
  final String reference;
  final String createdAt;
  final String updatedAt;

  NotificationM({
    required this.id,
    required this.timer,
    required this.notification,
    required this.receiverId,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationM.fromJson(Map<String, dynamic> json) {
    return NotificationM(
      id: json['_id'] ?? '',
      timer: json['timer'] ?? 0,
      notification: NotificationContent.fromJson(json['notification'] ?? {}),
      receiverId: json['receiver_id'] ?? '',
      reference: json['reference'] ?? '',
      createdAt: json['createdAt'] ?? '' ?? DateTime.now().toString(),
      updatedAt: json['updatedAt'] ?? '' ?? DateTime.now().toString(),
    );
  }
}

class NotificationContent {
  final String title;
  final String body;

  NotificationContent({
    required this.title,
    required this.body,
  });

  factory NotificationContent.fromJson(Map<String, dynamic> json) {
    return NotificationContent(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }
}
