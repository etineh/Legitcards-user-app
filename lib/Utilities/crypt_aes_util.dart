import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

class CryptAESUtil {
  static String encrypt(String data, String secretKey) {
    final decodedKey = base64Decode(secretKey); // 🔥 Decode Base64 key
    if (decodedKey.length != 16 &&
        decodedKey.length != 24 &&
        decodedKey.length != 32) {
      throw ArgumentError("Key length must be 128, 192, or 256 bits.");
    }

    final key = Key(decodedKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

    final encrypted = encrypter.encrypt(data, iv: iv);
    return base64Encode(iv.bytes + encrypted.bytes);
  }

  static String decrypt(String data, String secretKey) {
    final decodedKey = base64Decode(secretKey); // 🔥 Decode Base64 key
    if (decodedKey.length != 16 &&
        decodedKey.length != 24 &&
        decodedKey.length != 32) {
      throw ArgumentError("Key length must be 128, 192, or 256 bits.");
    }

    final key = Key(decodedKey);
    final decodedData = base64Decode(data);

    if (decodedData.length < 16) {
      throw ArgumentError("Invalid encrypted data: Too short to contain IV.");
    }

    final iv = IV
        .fromBase64(base64Encode(decodedData.sublist(0, 16))); // 🔥 Extract IV
    final encryptedData = decodedData.sublist(16); // Extract encrypted text

    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

    try {
      return encrypter.decrypt(Encrypted(encryptedData), iv: iv);
    } catch (e) {
      throw ArgumentError("Decryption failed: Invalid data or key.");
    }
  }
}

class KeystoreHelper {
  static const _storage = FlutterSecureStorage();

  static String _getProfileKeyAlias(String uid) => "UserProfileKey_$uid";
  static const _passwordKeyAlias = "Password_";
  static const _switchKeyAlias = "SwitchAccount";

  // Generate a random 32-byte key
  static String _generateKey() {
    final random = Random.secure();
    final key = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(key);
  }

  // Get or generate a key
  static Future<String?> _getKey(String keyAlias) async {
    String? key = await _storage.read(key: keyAlias);
    if (key == null) {
      key = _generateKey();
      await _storage.write(key: keyAlias, value: key);
    }
    return key;
  }

  static Future<String?> getUserProfileKey(String uid) async {
    return await _getKey(_getProfileKeyAlias(uid));
  }

  // static Future<String?> getAccountPasswordKey() async {
  //   return await _getKey(_passwordKeyAlias);
  // }
  //
  // static Future<String?> getSwitchAccountKey() async {
  //   return await _getKey(_switchKeyAlias);
  // }
}
