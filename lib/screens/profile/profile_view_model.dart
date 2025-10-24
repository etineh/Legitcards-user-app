import 'package:flutter/cupertino.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import '../../data/models/user_bank_model.dart';
import '../../data/repository/app_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<ProfileResponseM> getMyProfile(UserProfileM user) async {
    return getResponse(_repository.getMyProfile(user));
  }

  Future<ProfileResponseM> editProfile(
      Map<String, dynamic> profileMap, String token) async {
    return getResponse(_repository.editProfile(profileMap, token));
  }

  Future<ProfileResponseM> changePassword(
      Map<String, dynamic> passwordMap, String token) async {
    return getResponse(_repository.changePassword(passwordMap, token));
  }

  Future<ProfileResponseM> sendOtpForPin(
      Map<String, dynamic> fieldMap, String token) async {
    return getResponse(_repository.sendOtpForPin(fieldMap, token));
  }

  Future<ProfileResponseM> setPin(
      Map<String, dynamic> fieldMap, String token) async {
    return getResponse(_repository.setPin(fieldMap, token));
  }

  Future<ProfileResponseM> enable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    return getResponse(_repository.enable2Fa(fieldMap, token));
  }

  Future<ProfileResponseM> disable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    return getResponse(_repository.disable2Fa(fieldMap, token));
  }

  Future<ProfileResponseM> allowed2FaType(UserProfileM user) async {
    return getResponse(_repository.allowed2FaType(user));
  }

  Future<ProfileResponseM> sendCode2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    return getResponse(_repository.sendCode2Fa(fieldMap, token));
  }

  List<BankM> _banks = [];
  List<BankM> get banks => _banks; // expose banks

  Future<void> getBanks({bool shouldLoad = true}) async {
    final response =
        await getResponse(_repository.getBanks(), shouldLoad: shouldLoad);
    _banks = response.bankList?.result ?? [];
    notifyListeners();
  }

  Future<ProfileResponseM> verifyAccount(Map<String, dynamic> payload) async {
    return getResponse(_repository.verifyAccount(payload));
  }

  Future<ProfileResponseM> addBankAccount(
      Map<String, dynamic> payload, String token) async {
    return getResponse(_repository.addBankAccount(payload, token));
  }

  List<BankAccount> _bankAccount = [];
  List<BankAccount> get bankAccount => _bankAccount;

  Future<void> getMyBankInfo(UserProfileM user, {BuildContext? context}) async {
    final response = await getResponse(
      _repository.getMyBankInfo(user),
      shouldLoad: false,
    );
    // print("General log: Auth statusCode - ${response.statusCode}");

    if (response.statusCode == "SUCCESS") {
      _bankAccount = response.data!;
      notifyListeners();
      CacheUtils.myBankAccount = response.data!;
      notifyListeners();
    }
    // else if ((response.statusCode == "AUTHENTICATION_FAILED" ||
    //         response.statusCode == "Failed") &&
    //     context!.mounted) {
    //   CacheUtils.logout(context);
    // }
  }

  Future<ProfileResponseM> deleteBankAccount(
      Map<String, dynamic> payload, String token) async {
    return getResponse(_repository.deleteBankAccount(payload, token));
  }

  Future<void> deleteAccount(
      Map<String, dynamic> payload, String token, BuildContext context) async {
    final res = await getResponse(_repository.deleteAccount(payload, token));
    if (!context.mounted) return;

    print(res.message);
    context.toastMsg(res.message);

    if (res.statusCode == "ACCOUNT_DELETED") {
      CacheUtils.logout(context);
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
}
