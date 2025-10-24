import 'dart:convert';

import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:http/http.dart' as http;
import 'package:legit_cards/data/models/auth_model.dart';
import 'package:legit_cards/data/models/user_model.dart';
import '../../constants/k.dart';
import '../../data/models/notification_model.dart';

class NotificationApi {
  static final String baseUrl = K.baseUrl;
  // Add to your API repository

  Future<NotificationResponseM> getNotifications(String userid, String token,
      {int page = 0}) async {
    try {
      // Clean the userid to get only the ObjectId part
      final cleanUserId = AdjustUtils.extractObjectId(userid);

      final url = Uri.parse(
          "$baseUrl/api/feedback/notification/$cleanUserId?page=$page");

      print("Fetching notifications for: $cleanUserId (original: $userid)");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationResponseM.fromJson(data);
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      // print("General log: Notification API Error: $e");
      throw Exception('Error loading notifications: $e');
    }
  }

  /// save refresh token for notification
  Future<ProfileResponseM> saveDeviceToken(
      Map<String, dynamic> payload, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);
      return ProfileResponseM.fromJson(data);
    } catch (e) {
      print('Error saving device token: $e');
      throw Exception('Failed to save device token');
    }
  }

  // Future<ProfileResponseM> saveNotificationToBackend(
  //     Map<String, dynamic> payload, String token) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/api/feedback/notification'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode(payload),
  //     );
  //
  //     final data = jsonDecode(response.body);
  //     return ProfileResponseM.fromJson(data);
  //   } catch (e) {
  //     // print('Error saving notification: $e');
  //     throw Exception('Failed to save notification');
  //   }
  // }
}
