import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

import '../../../data/models/crypto_trade_m.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repository/app_repository.dart';

class CryptoViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Map of coinName → list of rate models
  final Map<String, List<CryptoRateM>> _rates = {};
  Map<String, List<CryptoRateM>> get rates => _rates;

  Future<void> fetchCryptoRates(
    UserProfileM user,
    String coinName, {
    bool shouldLoad = true,
    BuildContext? context,
  }) async {
    // Fetch when first time or force refresh
    if (_rates[coinName] == null) {
      if (context != null && context.mounted) {
        context.toastMsg("Fetching rate...", timeInSec: 2);
      }

      // Fetch from repo - api
      final response = await getResponse(
        _repository.fetchCryptoRate(user, coinName),
        shouldLoad: shouldLoad,
      );

      if (response.statusCode == "RATE_FETCHED") {
        _rates[coinName] = response.data ?? [];
        notifyListeners();
        getRate(coinName); // update the rate to the UI
      } else if (context != null && context.mounted) {
        context.toastMsg(response.message!);
      }
    }
  }

  Future<CryptoTransactionResM> sellCrypto(
    Map<String, dynamic> payload,
    String token,
  ) async {
    return getResponse(_repository.sellCrypto(payload, token));
  }

  // Clear cached rates (useful for refresh)
  void clearRates() {
    _rates.clear();
    notifyListeners();
  }

  // Reusable function
  Future<T> getResponse<T>(
    Future<T> repoCall, {
    bool shouldLoad = true,
  }) async {
    if (shouldLoad) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      return await repoCall;
    } catch (e) {
      rethrow;
    } finally {
      if (shouldLoad) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setIsLoadToTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setIsLoadToFalse() {
    _isLoading = false;
    notifyListeners();
  }

  // other helper methods

  /// Get rate for specific amount
  CryptoRateM? getRateForAmount(String coinName, double amount) {
    final coinRates = _rates[coinName.toLowerCase()];
    if (coinRates == null || coinRates.isEmpty) return null;

    try {
      return coinRates.firstWhere(
        (rate) => rate.isInRange(amount),
        orElse: () => coinRates.last,
      );
    } catch (e) {
      return coinRates.first;
    }
  }

  /// Return the least 'from' amount range among all the rate list
  String getLeastAmount(String coinName) {
    final coinRates = _rates[coinName];
    if (coinRates == null || coinRates.isEmpty) return '0';

    try {
      final minFrom = coinRates
          .where((rate) => rate.from != null)
          .map((rate) => rate.from!)
          .reduce((a, b) => a < b ? a : b);

      return minFrom.toString();
    } catch (e) {
      return '0';
    }
  }

  /// Return the highest 'to' amount range among all the rate list
  String getHighestAmount(String coinName) {
    final coinRates = _rates[coinName];
    if (coinRates == null || coinRates.isEmpty) return '0';

    try {
      final maxTo = coinRates
          .where((rate) => rate.to != null)
          .map((rate) => rate.to!)
          .reduce((a, b) => a > b ? a : b);

      return maxTo.toString();
    } catch (e) {
      return '0';
    }
  }

  /// Return the least rate among all the rate list
  String getLeastRate(String coinName) {
    final coinRates = _rates[coinName];
    if (coinRates == null || coinRates.isEmpty) return '0';
    try {
      final minRate = coinRates
          .where((rate) => rate.rate != null)
          .map((rate) => rate.rate!)
          .reduce((a, b) => a < b ? a : b);

      return minRate.toStringAsFixed(2);
    } catch (e) {
      return '0';
    }
  }

  /// Return the highest rate among all the rate list
  String getHighestRate(String coinName) {
    final coinRates = _rates[coinName];
    if (coinRates == null || coinRates.isEmpty) return '0';

    try {
      final maxRate = coinRates
          .where((rate) => rate.rate != null)
          .map((rate) => rate.rate!)
          .reduce((a, b) => a > b ? a : b);

      return maxRate.toStringAsFixed(2);
    } catch (e) {
      return '0';
    }
  }

  String toNairaRate = "0/﹩"; // ₦1440 per $1 USDT

  void getRate(String? coinName) {
    if (coinName == null) return;
    // final cryptoOuterVM = Provider.of<CryptoViewModel>(context, listen: false);
    String leastRate = getLeastRate(coinName.toLowerCase());
    String highestRate = getHighestRate(coinName.toLowerCase());

    if (leastRate == highestRate) {
      // If rates are the same, show single rate
      toNairaRate = "Rate: ₦$leastRate/＄";
      notifyListeners();
    } else {
      // If rates differ, show range
      toNairaRate = "Rate: ₦$leastRate/＄ - ₦$highestRate/＄";
      notifyListeners();
    }
  }
}
