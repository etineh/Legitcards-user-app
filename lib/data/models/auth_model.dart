import 'package:legit_cards/data/models/user_model.dart';

class UpdateUserM {
  String? userid;
  final String firstname;
  final String lastname;
  final String phoneNumber;
  // String? email;
  final String password;
  final String gender;
  final String username;

  UpdateUserM({
    required this.userid,
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    // required this.email,
    required this.password,
    required this.gender,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      "userid": userid,
      "firstname": firstname,
      "lastname": lastname,
      "phoneNumber": phoneNumber,
      // "email": email,
      "password": password,
      "gender": gender,
      "username": username,
    };
  }

  @override
  String toString() {
    return "UpdateUserM(userid: $userid, firstName: $firstname, lastName: $lastname, phoneNumber: $phoneNumber, gender: $gender, username: $username)";
  }
}

class UserNavigationData {
  final UpdateUserM updateUserM;
  final String email;
  final SignModel signIn;

  UserNavigationData(
      {required this.updateUserM, required this.email, required this.signIn});
}

// signup user
class SignModel {
  final String email;
  final String password;
  final String phoneNumber;
  final String devicename;
  final String devicetype;
  final String deviceos;

  SignModel({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.devicename,
    required this.devicetype,
    required this.deviceos,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "devicename": devicename,
      "devicetype": devicetype,
      "deviceos": deviceos,
    };
  }

  @override
  String toString() {
    return "SignModel(email: $email, phoneNumber: $phoneNumber, devicename: $devicename, devicetype: $devicetype, deviceos: $deviceos)";
  }
}

// Request model
class ActivateAccountRequest {
  final String email;
  final String code;

  ActivateAccountRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "code": code,
    };
  }
}

class OtpModel {
  final bool sentStatus;
  final int trial;
  final String value;
  final DateTime expiryTime;

  OtpModel({
    this.sentStatus = false,
    this.trial = 0,
    this.value = "",
    required this.expiryTime,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      sentStatus: json['sent_status'] ?? false,
      trial: json['trial'] ?? 0,
      value: json['value'] ?? "",
      expiryTime: json['expiry_time'] != null
          ? DateTime.parse(json['expiry_time'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sent_status': sentStatus,
      'trial': trial,
      'value': value,
      'expiry_time': expiryTime.toIso8601String(),
    };
  }
}

class ResetPasswordModel {
  final String? token;
  final DateTime? sent;
  final int trial;
  final bool verify;
  final DateTime? expiry;

  ResetPasswordModel({
    this.token,
    this.sent,
    this.trial = 0,
    this.verify = false,
    this.expiry,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(
      token: json['token'],
      sent: json['sent'] != null ? DateTime.parse(json['sent']) : null,
      trial: json['trial'] ?? 0,
      verify: json['verify'] ?? false,
      expiry: json['expiry'] != null ? DateTime.parse(json['expiry']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'sent': sent?.toIso8601String(),
      'trial': trial,
      'verify': verify,
      'expiry': expiry?.toIso8601String(),
    };
  }
}

class ApiResponseM {
  final String statusCode;
  final int status;
  final String message;
  final List<GeneralData>? data;

  ApiResponseM({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponseM.fromJson(Map<String, dynamic> json) {
    return ApiResponseM(
      statusCode: json['statusCode'] ?? '',
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => GeneralData.fromJson(item))
          .toList(),
    );
  }

  factory ApiResponseM.error(String msg) {
    return ApiResponseM(
      statusCode: "Failed",
      status: 404,
      message: msg,
      data: [],
    );
  }

  @override
  String toString() {
    return 'ApiResponseM(statusCode: $statusCode, status: $status, message: $message, data: $data)';
  }
}

class GeneralData {
  final int resendInMins;
  final String userid;
  final String token;
  final String id;
  final UserProfileM? userInfo;

  GeneralData({
    required this.resendInMins,
    required this.userid,
    required this.token,
    required this.id,
    required this.userInfo,
  });

  factory GeneralData.fromJson(Map<String, dynamic> json) {
    return GeneralData(
      resendInMins: json['resend_in_mins'] ?? 0,
      userid: json['userid'] ?? '',
      token: json['token'] ?? '',
      id: json['id'] ?? '',
      userInfo: json['userInfo'] != null
          ? UserProfileM.fromJson(json['userInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resend_in_mins': resendInMins,
      'userid': userid,
      'token': token,
      'id': id,
      'userInfo': userInfo?.toJson(),
    };
  }

  @override
  String toString() {
    return 'GeneralData(resendInMins: $resendInMins, userid: $userid, token: $token, id: $id, userInfo: $userInfo)';
  }
}
