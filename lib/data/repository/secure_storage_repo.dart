import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utilities/crypt_aes_util.dart';
import '../models/user_model.dart';

class SecureStorageRepo {
  static const _userProfileKey = "USER_PROFILE";
  static const _userIdKey = "USER_ID";

  /// Save user profile securely
  static Future<void> saveUserProfile(UserProfileM user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await KeystoreHelper.getUserProfileKey(user.userid!);

    final jsonStr = jsonEncode(user.toJson());
    final encrypted = CryptAESUtil.encrypt(jsonStr, key!);

    await prefs.setString(_userProfileKey, encrypted);
    await prefs.setString(_userIdKey, user.userid!); // save plain userid
  }

  /// Get user profile securely
  static Future<UserProfileM?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_userProfileKey);
    final userid = prefs.getString(_userIdKey); // get id back

    if (encrypted == null || userid == null) return null;

    final key = await KeystoreHelper.getUserProfileKey(userid);
    final decrypted = CryptAESUtil.decrypt(encrypted, key!);

    return UserProfileM.fromJson(jsonDecode(decrypted));
  }

  /// Clear stored profile
  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_userIdKey);
  }
}

/*
// Save
await SecureStorageRepo.saveUserProfile(userProfile);

// Read
final profile = await SecureStorageRepo.getUserProfile();
print("Decrypted profile: $profile");

// Clear (logout)
await SecureStorageRepo.clearUserProfile();

 */
