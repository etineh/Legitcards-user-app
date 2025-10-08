import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Simulate API response - replace with your real API
  static const String _baseUrl =
      'https://api.legitcards.com'; // Your API base URL

  // Signup method - only handles API call and returns result
  Future<AuthResult> signup({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullName,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AuthResult.success(
          userId: data['userId'],
          token: data['token'],
          message: data['message'] ?? 'Account created successfully!',
        );
      } else {
        // Parse error response
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Signup failed';

        return AuthResult.failure(
          error: AuthError.fromCode(response.statusCode, errorMessage),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        error: AuthError.network('Network error: ${e.toString()}'),
      );
    }
  }

  // Login method (for future use)
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Similar implementation for login
    throw UnimplementedError('Login not implemented yet');
  }
}

// Result wrapper for clean error handling
class AuthResult {
  final bool isSuccess;
  final String? userId;
  final String? token;
  final String? message;
  final AuthError? error;

  const AuthResult._({
    this.isSuccess = false,
    this.userId,
    this.token,
    this.message,
    this.error,
  });

  factory AuthResult.success({
    required String userId,
    required String token,
    required String message,
  }) {
    return AuthResult._(
      isSuccess: true,
      userId: userId,
      token: token,
      message: message,
    );
  }

  factory AuthResult.failure({required AuthError error}) {
    return AuthResult._(error: error);
  }

  bool get isFailure => !isSuccess;
}

// Error types for better error handling
enum AuthErrorType {
  network,
  validation,
  server,
  unauthorized,
}

class AuthError {
  final AuthErrorType type;
  final String message;
  final int? statusCode;

  const AuthError._({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory AuthError.network(String message) {
    return AuthError._(type: AuthErrorType.network, message: message);
  }

  factory AuthError.validation(String message) {
    return AuthError._(type: AuthErrorType.validation, message: message);
  }

  factory AuthError.server(String message, {int? statusCode}) {
    return AuthError._(
      type: AuthErrorType.server,
      message: message,
      statusCode: statusCode,
    );
  }

  factory AuthError.fromCode(int statusCode, String message) {
    switch (statusCode) {
      case 401:
        return AuthError._(type: AuthErrorType.unauthorized, message: message);
      case 422:
        return AuthError.validation(message);
      default:
        return AuthError.server(message, statusCode: statusCode);
    }
  }

  String get userMessage {
    switch (type) {
      case AuthErrorType.network:
        return 'Network error. Please check your connection.';
      case AuthErrorType.validation:
        return message;
      case AuthErrorType.server:
        return 'Server error. Please try again later.';
      case AuthErrorType.unauthorized:
        return 'Authentication failed. Please check your credentials.';
    }
  }
}
