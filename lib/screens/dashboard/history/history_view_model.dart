import 'package:flutter/cupertino.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import '../../../Utilities/cache_utils.dart';
import '../../../constants/k.dart';
import '../../../data/models/gift_card_trades_m.dart';
import '../../../data/models/history_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repository/app_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Card History
  List<GiftCardTradeM> _cardHistory = [];
  List<GiftCardTradeM> get cardHistory => _cardHistory;

// Coin History
  List<GiftCardTradeM> _coinHistory = [];
  List<GiftCardTradeM> get coinHistory => _coinHistory;

// Withdraw Records
  List<WithdrawRecordM> _withdrawRecords = [];
  List<WithdrawRecordM> get withdrawRecords => _withdrawRecords;

// Fetch Card History
  Future<void> fetchCardHistory(
    Map<String, dynamic> payload,
    String token, {
    BuildContext? context,
  }) async {
    final response = await getResponse(
      _repository.getTradeHistory(payload, token, from: K.CARD),
    );

    if (response.statusCode == "TRADE_FOUND") {
      _cardHistory = response.data ?? [];
      notifyListeners();
    } else if (response.statusCode == "AUTHENTICATION_FAILED") {
      if (context != null && context.mounted) {
        CacheUtils.logout(context);
      }
    } else {
      if (context != null && context.mounted) {
        context.toastMsg(response.message ?? "Error from server");
      }
    }
  }

// Fetch Coin History
  Future<void> fetchCoinHistory(
    Map<String, dynamic> payload,
    String token, {
    BuildContext? context,
  }) async {
    final response = await getResponse(
      _repository.getTradeHistory(payload, token, from: K.COIN),
    );

    if (response.statusCode == "TRADE_FOUND") {
      _coinHistory = response.data ?? [];
      notifyListeners();
    } else if (response.statusCode == "AUTHENTICATION_FAILED") {
      if (context != null && context.mounted) {
        CacheUtils.logout(context);
      }
    } else {
      if (context != null && context.mounted) {
        context.toastMsg(response.message ?? "Error from server");
      }
    }
  }

// Fetch Withdraw Records
  Future<void> fetchWithdrawRecords(
    String userId, {
    BuildContext? context,
  }) async {
    final response = await getResponse(
      _repository.fetchWithdrawRecords(userId),
    );

    if (response.status == "success") {
      _withdrawRecords = response.record ?? [];
      notifyListeners();
    } else if (response.status == "AUTHENTICATION_FAILED") {
      if (context != null && context.mounted) {
        CacheUtils.logout(context);
      }
    } else {
      if (context != null && context.mounted) {
        context.toastMsg(response.message ?? "Error from server");
      }
    }
  }

  Future<GiftCardResponseM> cancelTrade(
      UserProfileM user, String tradeId, String from) async {
    return getResponse(_repository.cancelTrade(user, tradeId, from));
  }

  // reusable function
  Future<T> getResponse<T>(Future<T> repoCall, {bool shouldLoad = true}) async {
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
}
