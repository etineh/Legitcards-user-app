import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:legit_cards/data/models/user_model.dart';
import '../../constants/k.dart';
import '../../data/models/wallet_model.dart';

class WalletApi {
  // I am using localUri to withdraw for now
  static final String baseUrl = K.baseUrl;
  // static String baseUrl = "http://172.20.10.2:7000";

  /// fetch user balance
  Future<WalletBalanceResponse> fetchBalance(UserProfileM user) async {
    final url = Uri.parse(
      '$baseUrl/api/wallet/users/get?id=${user.userid}',
    );

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer ${user.token}"},
    );

    return _parseResponse(
        response, (json) => WalletBalanceResponse.fromJson(json));
  }

  /// withdraw funds  - // use localUri to withdraw for now because of PIN verification
  Future<WithdrawalResponse> withdraw(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse('$baseUrl/api/withdraw');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );

    return _parseResponse(
        response, (json) => WithdrawalResponse.fromJson(json));
  }

  /// get withdraw records
  Future<WithdrawRecordResM> fetchWithdrawRecords(String userId) async {
    final url = Uri.parse(
      '$baseUrl/api/withdraw/user/$userId',
    );

    final response = await http.get(
      url,
      // headers: {"Authorization": "Bearer ${user.token}"},
    );

    return _parseResponse(
        response, (json) => WithdrawRecordResM.fromJson(json));
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
