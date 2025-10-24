import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:http/http.dart' as http;

import '../../constants/k.dart';
import '../../data/models/user_bank_model.dart';

class ProfileApi {
  static final String baseUrl = K.baseUrl;
  // static String baseUrl = "http://172.20.10.2:7000";

  // get my profile user
  Future<ProfileResponseM> getMyProfile(UserProfileM user) async {
    final url = Uri.parse(
      "$baseUrl/api/auth/users/account/profile?id=${user.userid}",
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${user.token}",
      },
    );
    return getApiResponse(response);
  }

  //edit  profile user
  Future<ProfileResponseM> editProfile(
      Map<String, dynamic> profileMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/profile/update");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(profileMap),
    );
    return getApiResponse(response);
  }

  //changePassword  profile user
  Future<ProfileResponseM> changePassword(
      Map<String, dynamic> passwordMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/password/update");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(passwordMap),
    );
    return getApiResponse(response);
  }

  // send otp to reset PIN
  Future<ProfileResponseM> sendOtpForPin(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/pin/send_otp");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return getApiResponse(response);
  }

  //update user PIN
  Future<ProfileResponseM> setPin(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/pin/set");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return getApiResponse(response);
  }

  // send code to enable 2fa // just id
  Future<ProfileResponseM> sendCode2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    final url =
        Uri.parse("$baseUrl/api/auth/users/account/2fa/activation/code");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return getApiResponse(response);
  }

  //enable 2fa
  Future<ProfileResponseM> enable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/2fa/enable");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return getApiResponse(response);
  }

  //disable 2fa // JUST ID
  Future<ProfileResponseM> disable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/2fa/disable");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return getApiResponse(response);
  }

  //allowed 2fa types // JUST ID
  Future<ProfileResponseM> allowed2FaType(UserProfileM user) async {
    final url = Uri.parse(
        "$baseUrl/api/auth/users/account/2fa/types?id=${user.userid}");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${user.token}",
      },
    );
    return getApiResponse(response);
  }

  //get all banks available | profile_api
  Future<ProfileResponseM> getBanks() async {
    final url = Uri.parse("$baseUrl/api/withdraw/banks");
    final response = await http.get(
      url,
    );
    return getApiResponse(response);
  }

  // validate and fetch out the name of the account number
  Future<ProfileResponseM> verifyAccount(Map<String, dynamic> payload) async {
    final url = Uri.parse("$baseUrl/api/withdraw/validateAccount");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );
    return getApiResponse(response);
  }

// Add user account number after verified
  Future<ProfileResponseM> addBankAccount(
      Map<String, dynamic> payload, String token) async {
    final url = Uri.parse("$baseUrl/api/banks/users/accounts/add");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );
    return getApiResponse(response);
  }

  // Add user account number after verified
  Future<BankAccountsResponse> getMyBankInfo(UserProfileM user) async {
    final url =
        Uri.parse("$baseUrl/api/banks/users/accounts/get?id=${user.userid}");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${user.token}",
      },
    );
    BankAccountsResponse model =
        BankAccountsResponse.fromJson(jsonDecode(response.body));
    // print("General log: the api model is $model");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return model;
    } else {
      throw Exception(model.message);
    }
  }

  Future<ProfileResponseM> deleteBankAccount(
      Map<String, dynamic> payload, String token) async {
    final url = Uri.parse("$baseUrl/api/banks/users/accounts/delete");
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );
    return getApiResponse(response);
  }

  //update user PIN
  Future<ProfileResponseM> deleteAccount(
      Map<String, dynamic> fieldMap, String token) async {
    final url = Uri.parse("$baseUrl/api/auth/users/account/delete");
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(fieldMap),
    );
    return getApiResponse(response);
  }

  // =========  reusable method to get api response
  ProfileResponseM getApiResponse(Response response) {
    try {
      // print("General log: raw data mode is ${response.body}");
      ProfileResponseM model =
          ProfileResponseM.fromJson(jsonDecode(response.body));
      if (kDebugMode) {
        print("General log: the api model is $model");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return model;
      } else {
        throw Exception(model.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print("General log: ❌ API Error: $e");
      }
      throw Exception("$e");
    }
  }
}
