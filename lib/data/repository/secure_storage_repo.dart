import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utilities/crypt_aes_util.dart';
import '../models/user_model.dart';

class SecureStorageRepo {
  static const _userProfileKey = "USER_PROFILE";
  static const _userIdKey = "USER_ID";

  static Future<void> saveUserProfile(UserProfileM user) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonStr = jsonEncode(user.toJson());

    await prefs.setString(_userProfileKey, jsonStr);
  }

  /// Save user profile securely
  // static Future<void> saveUserProfile(UserProfileM user) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final key = await KeystoreHelper.getUserProfileKey(user.userid!);
  //
  //   final jsonStr = jsonEncode(user.toJson());
  //   final encrypted = CryptAESUtil.encrypt(jsonStr, key!);
  //
  //   await prefs.setString(_userProfileKey, encrypted);
  //   await prefs.setString(_userIdKey, user.userid!); // save plain userid
  // }

  // Get user profile
  static Future<UserProfileM?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_userProfileKey);

      if (jsonStr == null) return null;

      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfileM.fromJson(jsonMap);
    } catch (e) {
      // print('Error getting user profile: $e');
      return null;
    }
  }

  /// Get user profile securely
  // static Future<UserProfileM?> getUserProfile() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final encrypted = prefs.getString(_userProfileKey);
  //   final userid = prefs.getString(_userIdKey); // get id back
  //
  //   if (encrypted == null || userid == null) return null;
  //
  //   final key = await KeystoreHelper.getUserProfileKey(userid);
  //   final decrypted = CryptAESUtil.decrypt(encrypted, key!);
  //
  //   return UserProfileM.fromJson(jsonDecode(decrypted));
  // }

  /// Clear stored profile
  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_userIdKey);
  }

  static Future<void> saveNotificationIsUnread(
      UserProfileM user, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(user.userid ?? "a", isRead);
  }

  // check if notification is unread
  static Future<bool> notificationIsUnread(UserProfileM user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(user.userid ?? "a") ?? false;
  }
}
