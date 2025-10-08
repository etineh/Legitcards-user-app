class BankAccountsResponse {
  final String statusCode;
  final int status;
  final List<BankAccount>? data;
  final String message;

  BankAccountsResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.message,
  });

  factory BankAccountsResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountsResponse(
      statusCode: json['statusCode'] ?? '',
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => BankAccount.fromJson(item))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  // error fallback model
  factory BankAccountsResponse.error(String msg) {
    return BankAccountsResponse(
      statusCode: "Failed",
      status: 404,
      message: msg,
      data: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "status": status,
      "data": data?.map((e) => e.toJson()).toList(),
      "message": message,
    };
  }

  @override
  String toString() {
    return 'BankAccountsResponse(statusCode: $statusCode, status: $status, message: $message, data: ${data?.length} account(s): $data)';
  }
}

class BankAccount {
  final String createdAt;
  final String id;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String userId;
  final BankExtraData? data;
  final int v;

  BankAccount({
    required this.createdAt,
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.userId,
    this.data,
    required this.v,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      createdAt: json['createdAt'] ?? '',
      id: json['_id'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      userId: json['userId'] ?? '',
      data: json['data'] != null ? BankExtraData.fromJson(json['data']) : null,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "createdAt": createdAt,
      "_id": id,
      "accountName": accountName,
      "accountNumber": accountNumber,
      "bankName": bankName,
      "userId": userId,
      "data": data?.toJson(),
      "__v": v,
    };
  }

  @override
  String toString() {
    return 'BankAccount(id: $id, accountName: $accountName, accountNumber: $accountNumber, bankName: $bankName, userId: $userId, createdAt: $createdAt, data: $data, __v: $v)';
  }
}

class BankExtraData {
  final String lenco;

  BankExtraData({required this.lenco});

  factory BankExtraData.fromJson(Map<String, dynamic> json) {
    return BankExtraData(
      lenco: json['LENCO'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "LENCO": lenco,
    };
  }

  @override
  String toString() {
    return 'BankExtraData(LENCO: $lenco)';
  }
}
