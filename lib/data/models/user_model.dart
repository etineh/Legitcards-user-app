class ProfileResponseM {
  final String statusCode;
  final dynamic status; // can be int or string
  final String message;
  final UserProfileM? data;
  final BankListM? bankList;
  final BankAccountDetails? bankAccountDetails;

  ProfileResponseM({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    this.bankList,
    this.bankAccountDetails,
  });

  factory ProfileResponseM.fromJson(Map<String, dynamic> json) {
    return ProfileResponseM(
      statusCode: json['statusCode'] ?? '',
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? UserProfileM.fromJson(json['data'])
          : null,
      bankList: json['bank_list'] != null
          ? BankListM.fromJson(json['bank_list'])
          : null,
      bankAccountDetails: json['bankAccountDetails'] != null
          ? BankAccountDetails.fromJson(json['bankAccountDetails'])
          : null,
    );
  }

  // error fallback model
  factory ProfileResponseM.error(String msg) {
    return ProfileResponseM(
      statusCode: "Failed",
      status: 404,
      message: msg,
      data: null,
      bankList: null,
      bankAccountDetails: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
      if (bankList != null) 'bank_list': bankList!.toJson(),
      if (bankAccountDetails != null)
        'bankAccountDetails': bankAccountDetails!.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProfileResponseM(statusCode: $statusCode, status: $status, message: $message, data: $data, bankList: $bankList, bankAccountDetails: $bankAccountDetails)';
  }
}

class UserProfileM {
  String? userid;
  bool? disabled;
  String? firstname;
  String? lastname;
  String phoneNumber;
  Map<String, dynamic>? phoneNumberInfo;
  String? email;
  String? username;
  String? referralId;
  String? pushToken;
  bool? profileUpdate;
  String? token;
  final int? loginTrial;
  final String? pin;
  final int pinTrial;
  final int? pinBlockDate;
  final bool pinBlocked;
  final String dob;
  final String? country;
  final String? ipAddress;
  final String? bvn;
  final String? profilePic;
  // final OtpModel? otp;
  final String? usertype;
  final String? regId;
  final String? gender;
  bool? is2fa;
  final String? twofaType;
  // final ResetPasswordModel? resetPassword;
  final DateTime? createdAt;
  final bool? accountVerify;

  UserProfileM({
    required this.userid,
    this.disabled = false,
    this.firstname,
    this.lastname,
    required this.phoneNumber,
    this.phoneNumberInfo,
    this.email,
    this.username,
    this.referralId,
    this.pushToken,
    this.profileUpdate = false,
    this.token,
    this.loginTrial = 0,
    this.pin = "0",
    this.pinTrial = 0,
    this.pinBlockDate,
    this.pinBlocked = false,
    this.dob = "DD/MM/YYYY",
    this.country,
    this.ipAddress,
    this.bvn,
    this.profilePic,
    // this.otp,
    this.usertype = "user",
    required this.regId,
    this.gender,
    this.is2fa = false,
    this.twofaType = "email",
    // this.resetPassword,
    DateTime? createdAt,
    this.accountVerify = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // 🔹 From JSON
  factory UserProfileM.fromJson(Map<String, dynamic> json) {
    return UserProfileM(
      userid: json['userid'],
      disabled: json['disabled'] ?? false,
      firstname: json['firstname'],
      lastname: json['lastname'],
      phoneNumber: json['phoneNumber'],
      phoneNumberInfo: json['phoneNumber_info'],
      email: json['email'],
      username: json['username'],
      referralId: json['referral_id'],
      pushToken: json['pushToken'],
      profileUpdate: json['profile_update'] ?? false,
      token: json['token'],
      loginTrial: json['logintrial'] ?? 0,
      pin: json['pin'] ?? "0",
      pinTrial: json['pin_trial'] ?? 0,
      pinBlockDate: json['pin_block_date'],
      pinBlocked: json['pin_blocked'] ?? false,
      dob: json['dob'] ?? "DD/MM/YYYY",
      country: json['country'],
      ipAddress: json['ip_address'],
      bvn: json['bvn'],
      profilePic: json['profile_pic'],
      // otp: json['otp'] != null ? OtpModel.fromJson(json['otp']) : null,
      usertype: json['usertype'] ?? "user",
      regId: json['reg_id'],
      gender: json['gender'],
      is2fa: json['is2fa'] ?? false,
      twofaType: json['twofa_type'] ?? "email",
      // resetPassword: json['reset_password'] != null
      //     ? ResetPasswordModel.fromJson(json['reset_password'])
      //     : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      accountVerify: json['account_verify'] ?? false,
    );
  }

  // 🔹 To JSON
  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'disabled': disabled,
      'firstname': firstname,
      'lastname': lastname,
      'phoneNumber': phoneNumber,
      'phoneNumber_info': phoneNumberInfo,
      'email': email,
      'username': username,
      'referral_id': referralId,
      'pushToken': pushToken,
      'profile_update': profileUpdate,
      'token': token,
      'logintrial': loginTrial,
      'pin': pin,
      'pin_trial': pinTrial,
      'pin_block_date': pinBlockDate,
      'pin_blocked': pinBlocked,
      'dob': dob,
      'country': country,
      'ip_address': ipAddress,
      'bvn': bvn,
      'profile_pic': profilePic,
      // 'otp': otp?.toJson(),
      'usertype': usertype,
      'reg_id': regId,
      'gender': gender,
      'is2fa': is2fa,
      'twofa_type': twofaType,
      // 'reset_password': resetPassword?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'account_verify': accountVerify,
    };
  }

  // to enable printing on print console
  @override
  String toString() {
    return 'UserProfileM('
        'userid: $userid, '
        'disabled: $disabled, '
        'firstname: $firstname, '
        'lastname: $lastname, '
        'phoneNumber: $phoneNumber, '
        'phoneNumberInfo: $phoneNumberInfo, '
        'email: $email, '
        'username: $username, '
        'referralId: $referralId, '
        'pushToken: $pushToken, '
        'profileUpdate: $profileUpdate, '
        'token: $token, '
        'loginTrial: $loginTrial, '
        'pin: $pin, '
        'pinTrial: $pinTrial, '
        'pinBlockDate: $pinBlockDate, '
        'pinBlocked: $pinBlocked, '
        'dob: $dob, '
        'country: $country, '
        'ipAddress: $ipAddress, '
        'bvn: $bvn, '
        'profilePic: $profilePic, '
        'usertype: $usertype, '
        'regId: $regId, '
        'gender: $gender, '
        'is2fa: $is2fa, '
        'twofaType: $twofaType, '
        'createdAt: $createdAt, '
        'accountVerify: $accountVerify'
        ')';
  }
}

class BankListM {
  final String? option;
  final List<BankM> result;

  BankListM({this.option, required this.result});

  factory BankListM.fromJson(Map<String, dynamic> json) {
    var list = json['Result'] as List? ?? [];
    return BankListM(
      option: json['Option'],
      result: list.map((e) => BankM.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Option': option,
      'Result': result.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'BankListM(option: $option, result: $result)';
}

class BankM {
  final String code;
  final String name;

  BankM({required this.code, required this.name});

  factory BankM.fromJson(Map<String, dynamic> json) {
    return BankM(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  @override
  String toString() => 'BankM(code: $code, name: $name)';
}

class BankAccountDetails {
  final String bankAccountName;
  final String bankAccountNumber;

  BankAccountDetails({
    required this.bankAccountName,
    required this.bankAccountNumber,
  });

  factory BankAccountDetails.fromJson(Map<String, dynamic> json) {
    return BankAccountDetails(
      bankAccountName: json['bankAccountName'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankAccountName': bankAccountName,
      'bankAccountNumber': bankAccountNumber,
    };
  }

  @override
  String toString() =>
      'BankAccountDetails(bankAccountName: $bankAccountName, bankAccountNumber: $bankAccountNumber)';
}
