import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gift_card_trades_m.dart';

class LocalShareRefRepo {
  static const _keyCardAssets = 'cached_card_assets';

  static Future<void> saveCardAssets(List<GiftCardAssetM> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(assets.map((e) => e.toJson()).toList());
    await prefs.setString(_keyCardAssets, jsonString);
  }

  static Future<List<GiftCardAssetM>?> getCachedCardAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCardAssets);
    if (jsonString == null) return null;
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => GiftCardAssetM.fromJson(e)).toList();
  }
}
