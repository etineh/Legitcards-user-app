import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:legit_cards/data/models/gift_card_trades_m.dart';
import 'package:legit_cards/data/models/user_model.dart';
import '../../constants/k.dart';
import '../../data/models/history_model.dart';

class GiftCardApi {
  static final String baseUrl = K.baseUrl;
// static String baseUrl = "http://172.20.10.2:7000";

  Future<GiftCardResponseM> fetchAllAssets(String token) async {
    final url = Uri.parse('$baseUrl/api/assets/users/get/all');
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    return _parseResponse(response, (json) => GiftCardResponseM.fromJson(json));
  }

  Future<GiftCardRateResM> fetchAssetRate(
      UserProfileM user, String assetId) async {
    final url = Uri.parse(
      '$baseUrl/api/rates/users/get/asset?id=${user.userid}&assetId=$assetId&start=0',
    );

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${user.token}"},
    );

    return _parseResponse(response, (json) => GiftCardRateResM.fromJson(json));
  }

  Future<GiftCardResponseM> sellGiftCard(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse("$baseUrl/api/trade/users/start");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return _parseResponse(response, (json) => GiftCardResponseM.fromJson(json));
  }

  Future<GiftCardResponseM> cancelCardTrade(
      UserProfileM user, String tradeId) async {
    final url = Uri.parse(
        "$baseUrl/api/trade/users/cancel?id=${user.userid}&tradeId=$tradeId");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${user.token}",
      },
    );
    return _parseResponse(response, (json) => GiftCardResponseM.fromJson(json));
  }

  Future<HistoryResponseM> getCardHistory(
      Map<String, dynamic> payload, String token) async {
    final url = Uri.parse("$baseUrl/api/trade/users/get");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );
    return _parseResponse(response, (json) => HistoryResponseM.fromJson(json));
  }

  T _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (kDebugMode) {
      debugPrint("General log: ${response.body}", wrapWidth: 1024);
    }

    final decoded = jsonDecode(response.body);
    final data = decoded is String ? jsonDecode(decoded) : decoded;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Unknown error');
    }
  }
}
