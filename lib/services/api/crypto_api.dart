import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../constants/k.dart';
import '../../data/models/crypto_trade_m.dart';
import '../../data/models/user_model.dart';

class CryptoApi {
  static final String baseUrl = K.baseUrl;
  // static String baseUrl = "http://172.20.10.2:7000";

  Future<CryptoRateResponse> fetchCryptoRate(
    UserProfileM user,
    String coinName,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/crypto/rates/users/get/coin_name?coin_name=$coinName&id=${user.userid}',
    );

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${user.token}"},
    );

    return _parseResponse(
      response,
      (json) => CryptoRateResponse.fromJson(json),
    );
  }

  Future<CryptoTransactionResM> sellCrypto(
    Map<String, dynamic> fieldMap,
    String token,
  ) async {
    final url = Uri.parse("$baseUrl/api/crypto/trade/users/start");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );

    return _parseResponse(
      response,
      (json) => CryptoTransactionResM.fromJson(json),
    );
  }

  T _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (kDebugMode) {
      debugPrint("Crypto API log: ${response.body}", wrapWidth: 1024);
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
