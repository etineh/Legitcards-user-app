import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/data/models/wallet_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

import '../../../data/repository/app_repository.dart';
import '../../../data/repository/share_ref_repo.dart';

class WalletViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  WalletM? _wallet;
  WalletM? get wallet => _wallet;

  Future<void> fetchBalance(UserProfileM user,
      {bool shouldLoad = true, BuildContext? context}) async {
    final response = await getResponse(_repository.fetchBalance(user));

    if (response.statusCode == "WALLET_FETCHED") {
      _wallet = response.wallet;
      notifyListeners();
    } else if (response.statusCode == "AUTHENTICATION_FAILED") {
      if (context!.mounted) CacheUtils.logout(context);
    } else if (context!.mounted) {
      // print("General log: Error fetching balance ${response.message}");
      context.toastMsg(response.message ?? "Error from server");
    }
  }

  Future<WithdrawalResponse> withdraw(
      Map<String, dynamic> payload, String token) async {
    return getResponse(_repository.withdraw(payload, token));
  }

// Initialize the list to avoid null issues
  List<WithdrawRecordM> _withdrawRecords = [];
  List<WithdrawRecordM> get withdrawRecords => _withdrawRecords;

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

  void setIsLoadToTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setIsLoadToFalse() {
    _isLoading = false;
    notifyListeners();
  }
}
