class HistoryResponseM {
  final String statusCode;
  final String message;
  final int status;
  final List<GiftCardTradeM> data;

  HistoryResponseM({
    required this.statusCode,
    required this.message,
    required this.status,
    required this.data,
  });

  factory HistoryResponseM.fromJson(Map<String, dynamic> json) {
    return HistoryResponseM(
      statusCode: json['statusCode'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => GiftCardTradeM.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory HistoryResponseM.error(String msg) {
    return HistoryResponseM(
      statusCode: 'ERROR',
      message: msg,
      status: 404,
      data: [],
    );
  }

  @override
  String toString() {
    return 'HistoryResponseM(statusCode: $statusCode, message: $message, status: $status, dataCount: ${data.length})';
  }
}

class GiftCardTradeM {
  final String id;
  final String assetName;
  final List<String> assetImage;
  final String assetId;
  final List<String> images;
  final String status;
  final int createdAt;
  final String country;
  final String type;
  final int quantity;
  final double userAmount;
  final double actualAmount;
  final double cost;
  final int rate;
  final bool dropped;
  final List<String> feedbacks;
  final List<String> imageProve;
  final CardHistoryRateM? rateInfo;
  final CountryInfoM? countryInfo;
  final UserInfoM? user;

  GiftCardTradeM({
    required this.id,
    required this.assetName,
    required this.assetImage,
    required this.assetId,
    required this.images,
    required this.status,
    required this.createdAt,
    required this.country,
    required this.type,
    this.quantity = 1,
    required this.userAmount,
    required this.actualAmount,
    required this.cost,
    required this.rate,
    this.dropped = false,
    this.feedbacks = const [],
    this.imageProve = const [],
    this.rateInfo,
    this.countryInfo,
    this.user,
  });

  factory GiftCardTradeM.fromJson(Map<String, dynamic> json) {
    return GiftCardTradeM(
      id: json['_id'] ?? '',
      assetName: json['assetName'] ?? '',
      assetImage:
          (json['assetImage'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      assetId: json['assetId'] ?? '',
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      country: json['country'] ?? '---',
      type: json['type'] ?? "Crypto",
      quantity: json['quantity'] ?? 1,
      userAmount: (json['userAmount'] ?? 0).toDouble(),
      actualAmount: (json['actualAmount'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
      rate: json['rate'] ?? 0,
      dropped: json['dropped'] ?? false,
      feedbacks:
          (json['feedbacks'] as List?)?.map((e) => e.toString()).toList() ?? [],
      imageProve:
          (json['image_prove'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      countryInfo: json['country_info'] != null
          ? CountryInfoM.fromJson(json['country_info'])
          : null,
      rateInfo: json['rateInfo'] != null
          ? CardHistoryRateM.fromJson(json['rateInfo'])
          : null,
      user: json['user'] != null ? UserInfoM.fromJson(json['user']) : null,
    );
  }

  @override
  String toString() {
    return 'GiftCardTradeM(id: $id, assetName: $assetName, status: $status, country: $country, rate: $rate, amount: $userAmount, createdAt: $createdAt)';
  }
}

class CardHistoryRateM {
  final String id;
  final bool rangeAbove;
  final String currency;
  final String country;
  final CountryInfoM? countryInfo;
  final String type;
  final double from;
  final double to;
  final double rate;
  final String processingTime;
  final String tradingPeriodStart;
  final String tradingPeriodStop;
  final String note;
  final String admin;
  final String? asset;

  CardHistoryRateM({
    required this.id,
    required this.rangeAbove,
    required this.currency,
    required this.country,
    this.countryInfo,
    required this.type,
    required this.from,
    required this.to,
    required this.rate,
    required this.processingTime,
    required this.tradingPeriodStart,
    required this.tradingPeriodStop,
    required this.note,
    required this.admin,
    this.asset,
  });
  factory CardHistoryRateM.fromJson(Map<String, dynamic> json) {
    return CardHistoryRateM(
      id: json['_id'] ?? '',
      rangeAbove: json['range_above'] ?? false,
      currency: json['currency'] ?? '',
      country: json['country'] ?? '',
      countryInfo: json['country_info'] != null
          ? CountryInfoM.fromJson(json['country_info'])
          : null,
      type: json['type'] ?? '',
      from: (json['from'] ?? 0).toDouble(),
      to: (json['to'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      processingTime: json['processing_time'] ?? '',
      tradingPeriodStart: json['trading_period_start'] ?? '',
      tradingPeriodStop: json['trading_period_stop'] ?? '',
      note: json['note'] ?? '',
      admin: json['admin'] ?? '',
      asset: json['asset'],
    );
  }

  @override
  String toString() {
    return 'GiftCardRateM(id: $id, country: $country, rate: $rate, range: $from - $to)';
  }
}

class CountryInfoM {
  final String name;

  CountryInfoM({required this.name});

  factory CountryInfoM.fromJson(Map<String, dynamic> json) {
    return CountryInfoM(name: json['name'] ?? '');
  }

  @override
  String toString() => 'CountryInfoM(name: $name)';
}

class UserInfoM {
  final String lastname;
  final String firstname;
  final String email;
  final String phoneNumber;
  final String userid;
  final String username;

  UserInfoM({
    required this.lastname,
    required this.firstname,
    required this.email,
    required this.phoneNumber,
    required this.userid,
    required this.username,
  });

  factory UserInfoM.fromJson(Map<String, dynamic> json) {
    return UserInfoM(
      lastname: json['lastname'] ?? '',
      firstname: json['firstname'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userid: json['userid'] ?? '',
      username: json['username'] ?? '',
    );
  }

  @override
  String toString() =>
      'UserInfoM(name: $firstname $lastname, email: $email, phone: $phoneNumber)';
}
