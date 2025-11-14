// Main Response Model
class WalletBalanceResponse {
  final String? statusCode;
  final int? status;
  final List<WalletM>? data;
  final String? message;

  WalletBalanceResponse({
    this.statusCode,
    this.status,
    this.data,
    this.message,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      statusCode: json['statusCode'] as String?,
      status: json['status'] as int?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => WalletM.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'status': status,
      'data': data?.map((item) => item.toJson()).toList(),
      'message': message,
    };
  }

  factory WalletBalanceResponse.error(String msg, {String? statusCode}) {
    return WalletBalanceResponse(
      statusCode: statusCode ?? 'ERROR',
      status: 404,
      data: null,
      message: msg,
    );
  }

  // Helper to get first wallet (most common use case)
  WalletM? get wallet => data?.isNotEmpty == true ? data!.first : null;
}

// Wallet Model
class WalletM {
  final String? walletId;
  final double? balance;
  final bool? lock;
  final String? status;
  final WalletUserM? user;
  final String? userId;
  final String? userid;

  WalletM({
    this.walletId,
    this.balance,
    this.lock,
    this.status,
    this.user,
    this.userId,
    this.userid,
  });

  factory WalletM.fromJson(Map<String, dynamic> json) {
    return WalletM(
      walletId: json['wallet_id'] as String?,
      balance: json['balance'] != null
          ? (json['balance'] is int
              ? (json['balance'] as int).toDouble()
              : json['balance'] as double?)
          : null,
      lock: json['lock'] as bool?,
      status: json['status'] as String?,
      user: json['user'] != null
          ? WalletUserM.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      userId: json['user_id'] as String?,
      userid: json['userid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'balance': balance,
      'lock': lock,
      'status': status,
      'user': user?.toJson(),
      'user_id': userId,
      'userid': userid,
    };
  }

  // Helper to check if wallet is active and unlocked
  bool get isUsable => status == 'ACTIVE' && lock == false;
}

// Wallet User Model
class WalletUserM {
  final String? lastname;
  final String? firstname;
  final String? email;
  final String? phoneNumber;
  final String? username;

  WalletUserM({
    this.lastname,
    this.firstname,
    this.email,
    this.phoneNumber,
    this.username,
  });

  factory WalletUserM.fromJson(Map<String, dynamic> json) {
    return WalletUserM(
      lastname: json['lastname'] as String?,
      firstname: json['firstname'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastname': lastname,
      'firstname': firstname,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
    };
  }
}

/// withdrawal responds when user make a withdraw;
// Main Response Model
class WithdrawalResponse {
  final String? status;
  // final String? message;
  final WithdrawalDataM? data;

  WithdrawalResponse({
    this.status,
    // this.message,
    this.data,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      status: json['status'] as String?,
      // message: json['message'] as String?,
      data: json['data'] != null
          ? WithdrawalDataM.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      // 'message': message,
      'data': data?.toJson(),
    };
  }

  factory WithdrawalResponse.error(String msg, {String? statusCode}) {
    return WithdrawalResponse(
      status: msg,
      // message: msg,
      data: null,
    );
  }

  // Helper to check if withdrawal was successful
  bool get isSuccess => status == 'success';
}

// Withdrawal Data Model
class WithdrawalDataM {
  final String? id;
  final String? amount;
  final String? fee;
  final String? narration;
  final String? type;
  final String? initiatedAt;
  final String? completedAt;
  final String? failedAt;
  final String? accountId;
  final WithdrawalDetailsM? details;
  final String? status;
  final String? reasonForFailure;
  final String? clientReference;
  final String? transactionReference;
  final String? nipSessionId;

  WithdrawalDataM({
    this.id,
    this.amount,
    this.fee,
    this.narration,
    this.type,
    this.initiatedAt,
    this.completedAt,
    this.failedAt,
    this.accountId,
    this.details,
    this.status,
    this.reasonForFailure,
    this.clientReference,
    this.transactionReference,
    this.nipSessionId,
  });

  factory WithdrawalDataM.fromJson(Map<String, dynamic> json) {
    return WithdrawalDataM(
      id: json['id'] as String?,
      amount: json['amount'] as String?,
      fee: json['fee'] as String?,
      narration: json['narration'] as String?,
      type: json['type'] as String?,
      initiatedAt: json['initiatedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      failedAt: json['failedAt'] as String?,
      accountId: json['accountId'] as String?,
      details: json['details'] != null
          ? WithdrawalDetailsM.fromJson(json['details'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      reasonForFailure: json['reasonForFailure'] as String?,
      clientReference: json['clientReference'] as String?,
      transactionReference: json['transactionReference'] as String?,
      nipSessionId: json['nipSessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'fee': fee,
      'narration': narration,
      'type': type,
      'initiatedAt': initiatedAt,
      'completedAt': completedAt,
      'failedAt': failedAt,
      'accountId': accountId,
      'details': details?.toJson(),
      'status': status,
      'reasonForFailure': reasonForFailure,
      'clientReference': clientReference,
      'transactionReference': transactionReference,
      'nipSessionId': nipSessionId,
    };
  }

  // Helper methods
  double get amountValue => double.tryParse(amount ?? '0') ?? 0.0;
  double get feeValue => double.tryParse(fee ?? '0') ?? 0.0;
  double get totalAmount => amountValue + feeValue;

  String get formattedAmount {
    return '₦${amountValue.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed' || completedAt != null;
  bool get isFailed => status == 'failed' || failedAt != null;

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return status ?? 'Unknown';
    }
  }
}

// Withdrawal Details Model
class WithdrawalDetailsM {
  final String? accountName;
  final String? accountNumber;
  final WithdrawalBankM? bank;

  WithdrawalDetailsM({
    this.accountName,
    this.accountNumber,
    this.bank,
  });

  factory WithdrawalDetailsM.fromJson(Map<String, dynamic> json) {
    return WithdrawalDetailsM(
      accountName: json['accountName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      bank: json['bank'] != null
          ? WithdrawalBankM.fromJson(json['bank'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bank': bank?.toJson(),
    };
  }
}

// Bank Model
class WithdrawalBankM {
  final String? code;
  final String? name;

  WithdrawalBankM({
    this.code,
    this.name,
  });

  factory WithdrawalBankM.fromJson(Map<String, dynamic> json) {
    return WithdrawalBankM(
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}

/// withdraw records
// Withdraw Record Response Model
class WithdrawRecordResM {
  final String? status;
  final String? message;
  final int? recordCount;
  final List<WithdrawRecordM>? record;

  WithdrawRecordResM({
    this.status,
    this.message,
    this.recordCount,
    this.record,
  });

  factory WithdrawRecordResM.fromJson(Map<String, dynamic> json) {
    return WithdrawRecordResM(
      status: json['status'] as String?,
      message: json['message'] as String?,
      recordCount: json['recordCount'] as int?,
      record: json['record'] != null
          ? (json['record'] as List)
              .map((item) =>
                  WithdrawRecordM.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'recordCount': recordCount,
      'record': record?.map((item) => item.toJson()).toList(),
    };
  }

  factory WithdrawRecordResM.error(String msg) {
    return WithdrawRecordResM(
      status: 'error',
      message: msg,
      recordCount: 0,
      record: null,
    );
  }

  // Helper to get first record
  WithdrawRecordM? get firstRecord =>
      record?.isNotEmpty == true ? record!.first : null;
}

// Withdraw Record Model
class WithdrawRecordM {
  final String? id;
  final String? userId;
  final String? reference;
  final String? bankCode;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final double? amount;
  final String? withdrawalMethod;
  final String? userEmail;
  final double? balance;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? status; // pending, completed, failed

  WithdrawRecordM({
    this.id,
    this.userId,
    this.reference,
    this.bankCode,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.amount,
    this.withdrawalMethod,
    this.userEmail,
    this.balance,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.status,
  });

  factory WithdrawRecordM.fromJson(Map<String, dynamic> json) {
    return WithdrawRecordM(
      id: json['_id'] as String?,
      userId: json['user_id'] as String?,
      reference: json['reference'] as String?,
      bankCode: json['bankCode'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      amount: json['amount'] != null
          ? (json['amount'] is int
              ? (json['amount'] as int).toDouble()
              : json['amount'] as double?)
          : null,
      withdrawalMethod: json['withdrawal_method'] as String?,
      userEmail: json['user_email'] as String?,
      balance: json['balance'] != null
          ? (json['balance'] is int
              ? (json['balance'] as int).toDouble()
              : json['balance'] as double?)
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
      status: json['status'] as String? ?? 'completed', // Default to pending
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': userId,
      'reference': reference,
      'bankCode': bankCode,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'amount': amount,
      'withdrawal_method': withdrawalMethod,
      'user_email': userEmail,
      'balance': balance,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'status': status,
    };
  }

  // Factory to create from WithdrawalDataM
  factory WithdrawRecordM.fromWithdrawalData(WithdrawalDataM data) {
    return WithdrawRecordM(
      id: data.id,
      reference: data.clientReference,
      bankCode: data.details?.bank?.code,
      bankName: data.details?.bank?.name,
      bankAccountNumber: data.details?.accountNumber,
      bankAccountName: data.details?.accountName,
      amount: data.amountValue,
      withdrawalMethod: 'instant', // From your API
      balance: null, // Not available in WithdrawalDataM
      createdAt: data.initiatedAt ?? DateTime.now().toIso8601String(),
      updatedAt: data.completedAt ??
          data.initiatedAt ??
          DateTime.now().toIso8601String(),
      status: data.status,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return status ?? 'Pending';
    }
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
