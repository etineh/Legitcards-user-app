import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../../constants/k.dart';
import '../../data/models/auth_model.dart';

class AuthApi {
  static final String baseUrl = K.baseUrl;
  // static String baseUrl = "http://172.20.10.2:7000";

  // create account
  Future<ApiResponseM> createUser(SignModel user) async {
    final url = Uri.parse("$baseUrl/api/auth/users/create");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return getApiResponse(response);
  }

  // activate account with otp code
  Future<ApiResponseM> activateAccount(ActivateAccountRequest request) async {
    final url = Uri.parse("$baseUrl/api/auth/users/activate");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    return getApiResponse(response);
  }

  // update profile after creating new user account
  Future<ApiResponseM> updateNewUserProfile(UpdateUserM user) async {
    final url = Uri.parse("$baseUrl/api/auth/users/update");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    return getApiResponse(response);
  }

  // resend otp code
  Future<ApiResponseM> resendCode(String email) async {
    final url = Uri.parse("$baseUrl/api/auth/users/resend_code");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return getApiResponse(response);
  }

  // login user
  Future<ApiResponseM> signIn(SignModel user) async {
    final url = Uri.parse("$baseUrl/api/auth/users/signin");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return getApiResponse(response);
  }

// login with 2fa code
  Future<ApiResponseM> loginWith2Fa(Map<String, dynamic> user) async {
    final url = Uri.parse("$baseUrl/api/auth/users/signin/2fa");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user),
    );
    return getApiResponse(response);
  }

  // request code to reset password
  Future<ApiResponseM> requestCode(Map<String, dynamic> emailMap) async {
    final url = Uri.parse("$baseUrl/api/auth/users/password/sendcode");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(emailMap),
    );
    return getApiResponse(response);
  }

  // reset password
  Future<ApiResponseM> resetPassword(Map<String, dynamic> resetMap) async {
    final url = Uri.parse("$baseUrl/api/auth/users/password/reset");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(resetMap),
    );
    return getApiResponse(response);
  }

  // reusable method to get api response
  ApiResponseM getApiResponse(Response response) {
    // print("General log: raw data mode is ${response.body}");
    ApiResponseM model = ApiResponseM.fromJson(jsonDecode(response.body));
    print("General log: the api model is $model");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return model;
    } else {
      throw Exception(model.message);
    }
  }

  // ApiResponseM getApiResponse(Response response) {
  //   try {
  //     print("General log: raw data mode is ${response.body}");
  //     final decoded = jsonDecode(response.body);
  //     ApiResponseM model = ApiResponseM.fromJson(decoded);
  //     print("General log: the api model is $model");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return model;
  //     } else {
  //       throw Exception(model.message);
  //     }
  //   } catch (e, stackTrace) {
  //     print("General log: Failed to parse API response → $e");
  //     print("Stack trace: $stackTrace");
  //     throw Exception("Unexpected API response format or error: $e");
  //   }
  // }
}
