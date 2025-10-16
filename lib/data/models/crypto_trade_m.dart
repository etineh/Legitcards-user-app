// Main Response Model
class CryptoRateResponse {
  final String? statusCode;
  final String? message;
  final int? status;
  final List<CryptoRateM>? data;

  CryptoRateResponse({
    this.statusCode,
    this.message,
    this.status,
    this.data,
  });

  factory CryptoRateResponse.fromJson(Map<String, dynamic> json) {
    return CryptoRateResponse(
      statusCode: json['statusCode'] as String?,
      message: json['message'] as String?,
      status: json['status'] as int?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => CryptoRateM.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'status': status,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }

  factory CryptoRateResponse.error(String msg) {
    return CryptoRateResponse(
      statusCode: 'ERROR',
      message: msg,
      status: 404,
      data: null,
    );
  }
}

// Crypto Rate Model
class CryptoRateM {
  final int? from;
  final int? to;
  final CryptoAssetM? asset;
  final double? rate;
  final String? admin;
  final String? id;
  final bool? rangeAbove;

  CryptoRateM({
    this.from,
    this.to,
    this.asset,
    this.rate,
    this.admin,
    this.id,
    this.rangeAbove,
  });

  factory CryptoRateM.fromJson(Map<String, dynamic> json) {
    return CryptoRateM(
      from: json['from'] as int?,
      to: json['to'] as int?,
      asset: json['asset'] != null
          ? CryptoAssetM.fromJson(json['asset'] as Map<String, dynamic>)
          : null,
      rate: json['rate'] != null
          ? (json['rate'] is int
              ? (json['rate'] as int).toDouble()
              : json['rate'] as double?)
          : null,
      admin: json['admin'] as String?,
      id: json['_id'] as String?,
      rangeAbove: json['range_above'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'asset': asset?.toJson(),
      'rate': rate,
      'admin': admin,
      '_id': id,
      'range_above': rangeAbove,
    };
  }

  // Helper method to check if amount is within range
  bool isInRange(double amount) {
    if (from == null || to == null) return false;
    return amount >= from! && amount <= to!;
  }
}

// Crypto Asset Model
class CryptoAssetM {
  final List<String>? images;
  final String? createdAt;
  final String? id;
  final String? name;
  final String? admin;
  final int? v;

  CryptoAssetM({
    this.images,
    this.createdAt,
    this.id,
    this.name,
    this.admin,
    this.v,
  });

  factory CryptoAssetM.fromJson(Map<String, dynamic> json) {
    return CryptoAssetM(
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      createdAt: json['createdAt'] as String?,
      id: json['_id'] as String?,
      name: json['name'] as String?,
      admin: json['admin'] as String?,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images,
      'createdAt': createdAt,
      '_id': id,
      'name': name,
      'admin': admin,
      '__v': v,
    };
  }

  // Helper method to get first image
  String? get firstImage =>
      images != null && images!.isNotEmpty ? images!.first : null;

  // Helper method to get uppercase name
  String get displayName => name?.toUpperCase() ?? '';
}

class CryptoTransactionResM {
  final String statusCode;
  final String message;
  final int status;
  final List<dynamic>? data; // Changed from dynamic to List<dynamic>?

  CryptoTransactionResM({
    required this.statusCode,
    required this.message,
    required this.status,
    this.data,
  });

  factory CryptoTransactionResM.fromJson(Map<String, dynamic> json) {
    return CryptoTransactionResM(
      statusCode: json['statusCode'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: json['data'] != null ? json['data'] as List<dynamic> : null,
    );
  }

  factory CryptoTransactionResM.error(String msg) {
    return CryptoTransactionResM(
      statusCode: 'ERROR',
      message: msg,
      status: 404,
      data: null,
    );
  }
}
