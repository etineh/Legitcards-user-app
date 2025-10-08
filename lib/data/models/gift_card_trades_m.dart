class GiftCardResponseM {
  final String statusCode;
  final String message;
  final int status;
  final List<GiftCardAssetM> data;

  GiftCardResponseM({
    required this.statusCode,
    required this.message,
    required this.status,
    required this.data,
  });

  factory GiftCardResponseM.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data'] ?? [];
    return GiftCardResponseM(
      statusCode: json['statusCode'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: list.map((e) => GiftCardAssetM.fromJson(e)).toList(),
    );
  }

  factory GiftCardResponseM.error(String msg) {
    return GiftCardResponseM(
      statusCode: 'ERROR',
      message: msg,
      status: 404,
      data: [],
    );
  }
}

class GiftCardAssetM {
  final String id;
  final String name;
  final List<String> images;
  // final String tradingPeriodStart;
  // final String tradingPeriodStop;
  final bool cardActive;
  final String? specialInfo;

  GiftCardAssetM({
    required this.id,
    required this.name,
    required this.images,
    // required this.tradingPeriodStart,
    // required this.tradingPeriodStop,
    this.cardActive = true,
    this.specialInfo,
  });

  factory GiftCardAssetM.fromJson(Map<String, dynamic> json) {
    return GiftCardAssetM(
      id: json['_id'] ?? '',
      name: json['name']?.trim() ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      // tradingPeriodStart: json['trading_period_start'] ?? '',
      // tradingPeriodStop: json['trading_period_stop'] ?? '',
      cardActive: json['cardActive'] ?? true,
      specialInfo: json['special_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      // 'trading_period_start': tradingPeriodStart,
      // 'trading_period_stop': tradingPeriodStop,
      'cardActive': cardActive,
      if (specialInfo != null) 'special_info': specialInfo,
    };
  }
}

//    =========== rates

class GiftCardRateResM {
  final String statusCode;
  final String message;
  final int status;
  final List<GiftCardRateM> data;

  GiftCardRateResM({
    required this.statusCode,
    required this.message,
    required this.status,
    required this.data,
  });

  factory GiftCardRateResM.fromJson(Map<String, dynamic> json) {
    return GiftCardRateResM(
      statusCode: json['statusCode'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => GiftCardRateM.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory GiftCardRateResM.error(String msg) {
    return GiftCardRateResM(
      statusCode: "FAILED",
      message: msg,
      status: 404,
      data: [],
    );
  }
}

class GiftCardRateM {
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
  final GiftCardAssetM? asset;

  GiftCardRateM({
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

  factory GiftCardRateM.fromJson(Map<String, dynamic> json) {
    return GiftCardRateM(
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
      asset:
          json['asset'] != null ? GiftCardAssetM.fromJson(json['asset']) : null,
    );
  }
}

class CountryInfoM {
  final String name;

  CountryInfoM({required this.name});

  factory CountryInfoM.fromJson(Map<String, dynamic> json) {
    return CountryInfoM(
      name: json['name'] ?? '',
    );
  }
}
