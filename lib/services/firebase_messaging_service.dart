import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../data/models/user_model.dart';
import '../data/repository/app_repository.dart';
import '../screens/notification/notification_view_model.dart';

// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  try {
    // Get saved user data from SharedPreferences
    final user = await SecureStorageRepo.getUserProfile();

    if (user != null) {
      SecureStorageRepo.saveNotificationIsUnread(user, true); // for indicator
      // Prepare payload
      final payload = {
        "notification": {
          "title": message.notification?.title ?? '',
          "body": message.notification?.body ?? '',
        },
        "receiver_id": AdjustUtils.extractObjectId(user.userid!),
      };

      String? token = await FirebaseMessagingService().getDeviceToken();
      // Save to backend
      await _saveNotificationToBackend(payload, token ?? "a");
      // print('General log: Notification saved to backend successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('General log: Error saving notification to backend: $e');
    }
  }
}

Future<ProfileResponseM> _saveNotificationToBackend(
    Map<String, dynamic> payload, String token) async {
  try {
    final response = await http.post(
      Uri.parse('${K.baseUrl}/api/feedback/notification'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);
    return ProfileResponseM.fromJson(data);
  } catch (e) {
    // print('Error saving notification: $e');
    throw Exception('Failed to save notification');
  }
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  // Stream controller for notification taps
  final StreamController<Map<String, dynamic>> _notificationTapStream =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationTapStream =>
      _notificationTapStream.stream;

  // Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Initialize awesome notifications
      await _initializeAwesomeNotifications();

      // Request permission
      await requestPermission();

      // Setup message handlers
      _setupMessageHandlers();

      // Setup background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // print('General log: Firebase Messaging initialized successfully');
    } catch (e) {
      if (kDebugMode) {
        print('General log: Error initializing Firebase Messaging: $e');
      }
    }
  }

  // Initialize awesome notifications
  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'legitcards_channel',
          channelName: 'Legitcards Notifications',
          channelDescription: 'Notification channel for Legitcards',
          defaultColor: const Color(0xFF6B21A8),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        )
      ],
    );

    // Listen to notification actions
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  // Handle notification tap
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('General log: Notification tapped: ${receivedAction.payload}');

    if (receivedAction.payload != null) {
      final instance = FirebaseMessagingService();
      final data = {
        'action': 'notification_tapped',
        'title': receivedAction.payload?['title'] ?? '',
        'body': receivedAction.payload?['body'] ?? '',
        'data': receivedAction.payload ?? {},
      };
      instance._notificationTapStream.add(data);
    }
  }

  // Request notification permission
  Future<bool> requestPermission() async {
    try {
      // Firebase messaging permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Awesome notifications permission
      await AwesomeNotifications().requestPermissionToSendNotifications();

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  // Get device token
  Future<String?> getDeviceToken() async {
    try {
      _deviceToken = await _firebaseMessaging.getToken();
      // print('General log: Device Token: $_deviceToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _deviceToken = newToken;
        print('Token refreshed: $newToken');
      });
// e2dK-VcCSUSOFSujrxtWdb:APA91bFy_OP3vFxEAWAvMKhkXPbf3eZBMJFJdB3BZxf-d4ZaZcah0QAu3-SFsWsYw2giKYD8BMQ2AhvKbQ7RiSmp2dLtNAgry1BQWxQV0hQgwEQ8oniH9Js
      return _deviceToken;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  // Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('General log: Foreground message received: ${message.messageId}');
      _showLocalNotification(message);
    });

    // When app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App opened from terminated state: ${message.messageId}');
        _handleNotificationNavigation(message);
      }
    });

    // When app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background: ${message.messageId}');
      _handleNotificationNavigation(message);
    });
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notification.hashCode,
          channelKey: 'legitcards_channel',
          title: notification.title,
          body: notification.body,
          notificationLayout: NotificationLayout.Default,
          color: const Color(0xFF6B21A8),
          payload: {
            'title': notification.title ?? '',
            'body': notification.body ?? '',
            ...message.data,
          },
        ),
      );
    }
  }

  // Handle notification navigation
  void _handleNotificationNavigation(RemoteMessage message) {
    final data = {
      'action': 'navigate_to_detail',
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
    };
    _notificationTapStream.add(data);
  }

  // Save device token to backend
  Future<bool> saveDeviceToken(String token, String email) async {
    try {
      final payload = {
        'pushToken': token,
        'email': email,
      };

      print('Saving device token to backend: $payload');
      return true;
    } catch (e) {
      print('Error saving device token: $e');
      return false;
    }
  }

  // Dispose
  void dispose() {
    _notificationTapStream.close();
  }
}

//
// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// // Top-level function for background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling background message: ${message.messageId}');
//   // You can process the notification here if needed
// }
//
// class FirebaseMessagingService {
//   static final FirebaseMessagingService _instance =
//       FirebaseMessagingService._internal();
//   factory FirebaseMessagingService() => _instance;
//   FirebaseMessagingService._internal();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//
//   String? _deviceToken;
//   String? get deviceToken => _deviceToken;
//
//   // Stream controller for notification taps
//   final StreamController<Map<String, dynamic>> _notificationTapStream =
//       StreamController<Map<String, dynamic>>.broadcast();
//
//   Stream<Map<String, dynamic>> get notificationTapStream =>
//       _notificationTapStream.stream;
//
//   // Initialize Firebase Messaging
//   Future<void> initialize() async {
//     try {
//       // Request permission
//       await requestPermission();
//
//       // Initialize local notifications
//       await _initializeLocalNotifications();
//
//       // Get device token
//       await getDeviceToken();
//
//       // Setup message handlers
//       _setupMessageHandlers();
//
//       // Setup background message handler
//       FirebaseMessaging.onBackgroundMessage(
//           _firebaseMessagingBackgroundHandler);
//
//       print('Firebase Messaging initialized successfully');
//     } catch (e) {
//       print('Error initializing Firebase Messaging: $e');
//     }
//   }
//
//   // Request notification permission
//   Future<bool> requestPermission() async {
//     try {
//       // For iOS
//       if (Platform.isIOS) {
//         final settings = await _firebaseMessaging.requestPermission(
//           alert: true,
//           badge: true,
//           sound: true,
//           provisional: false,
//         );
//
//         if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//           print('User granted permission');
//           return true;
//         } else if (settings.authorizationStatus ==
//             AuthorizationStatus.provisional) {
//           print('User granted provisional permission');
//           return true;
//         } else {
//           print('User declined or has not accepted permission');
//           return false;
//         }
//       }
//
//       // For Android 13+ (API level 33+)
//       if (Platform.isAndroid) {
//         final status = await Permission.notification.request();
//         return status.isGranted;
//       }
//
//       return true;
//     } catch (e) {
//       print('Error requesting permission: $e');
//       return false;
//     }
//   }
//
//   // Initialize local notifications
//   Future<void> _initializeLocalNotifications() async {
//     const androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     final initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//
//     // Create Android notification channel
//     const androidChannel = AndroidNotificationChannel(
//       'legitcards_channel',
//       'Legitcards Notifications',
//       description: 'This channel is used for important notifications',
//       importance: Importance.high,
//       playSound: true,
//     );
//
//     await _localNotifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(androidChannel);
//   }
//
//   // Handle notification tap
//   void _onNotificationTapped(NotificationResponse response) {
//     print('Notification tapped with payload: ${response.payload}');
//
//     if (response.payload != null) {
//       // Parse the payload and emit to stream
//       try {
//         final Map<String, dynamic> data = {
//           'action': 'notification_tapped',
//           'payload': response.payload,
//         };
//         _notificationTapStream.add(data);
//       } catch (e) {
//         print('Error parsing notification payload: $e');
//       }
//     }
//   }
//
//   // Get device token
//   Future<String?> getDeviceToken() async {
//     try {
//       _deviceToken = await _firebaseMessaging.getToken();
//       print('Device Token: $_deviceToken');
//
//       // Listen for token refresh
//       _firebaseMessaging.onTokenRefresh.listen((newToken) {
//         _deviceToken = newToken;
//         print('Token refreshed: $newToken');
//         // TODO: Send new token to your backend
//       });
//
//       return _deviceToken;
//     } catch (e) {
//       print('Error getting device token: $e');
//       return null;
//     }
//   }
//
//   // Setup message handlers
//   void _setupMessageHandlers() {
//     // Foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Foreground message received: ${message.messageId}');
//       _showLocalNotification(message);
//     });
//
//     // When app is opened from terminated state
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         print('App opened from terminated state: ${message.messageId}');
//         _handleNotificationNavigation(message);
//       }
//     });
//
//     // When app is opened from background state
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('App opened from background: ${message.messageId}');
//       _handleNotificationNavigation(message);
//     });
//   }
//
//   // Show local notification
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     final notification = message.notification;
//     final android = message.notification?.android;
//
//     if (notification != null) {
//       await _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'legitcards_channel',
//             'Legitcards Notifications',
//             channelDescription:
//                 'This channel is used for important notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//             color: Color(0xFF6B21A8), // Your primary color
//             playSound: true,
//             enableVibration: true,
//           ),
//           iOS: DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//         payload: message.data.toString(), // Pass data as payload
//       );
//     }
//   }
//
//   // Handle notification navigation
//   void _handleNotificationNavigation(RemoteMessage message) {
//     final data = {
//       'action': 'navigate_to_detail',
//       'title': message.notification?.title ?? '',
//       'body': message.notification?.body ?? '',
//       'data': message.data, // This includes receiver_id, reference, etc.
//       'createdAt': DateTime.now().toIso8601String(),
//     };
//     _notificationTapStream.add(data);
//   }
//
//   // Save device token to backend
//   Future<bool> saveDeviceToken(String token, String email) async {
//     try {
//       // TODO: Replace with your actual API call
//       final payload = {
//         'pushToken': token,
//         'email': email,
//       };
//
//       // Example:
//       // final response = await apiRepository.saveDeviceToken(payload);
//       // return response.statusCode == 'SUCCESS';
//
//       print('Saving device token to backend: $payload');
//       return true;
//     } catch (e) {
//       print('Error saving device token: $e');
//       return false;
//     }
//   }
//
//   // Dispose
//   void dispose() {
//     _notificationTapStream.close();
//   }
// }
