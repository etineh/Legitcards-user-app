import 'package:flutter/cupertino.dart';
import 'package:legit_cards/data/models/user_model.dart';
import '../../../constants/k.dart';
import '../../../data/models/gift_card_trades_m.dart';
import '../../../data/models/history_model.dart';
import '../../../data/repository/app_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<HistoryResponseM> getCardHistory(
      Map<String, dynamic> payload, String token,
      {String from = K.CARD}) async {
    return getResponse(_repository.getTradeHistory(payload, token, from: from));
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
