import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/data/models/wallet_model.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/services/api/notification_api.dart';
import 'package:legit_cards/services/api/profile_api.dart';
import 'package:legit_cards/services/api/wallet_api.dart';

import '../../constants/k.dart';
import '../../extension/inbuilt_ext.dart';
import '../../services/api/auth_api.dart';
import '../../services/api/crypto_api.dart';
import '../../services/api/gift_card_api.dart';
import '../models/auth_model.dart';
import '../models/crypto_trade_m.dart';
import '../models/gift_card_trades_m.dart';
import '../models/history_model.dart';
import '../models/notification_model.dart';
import '../models/user_bank_model.dart';

class AppRepository {
  final AuthApi _authApi = AuthApi();
  final ProfileApi _profileApi = ProfileApi();
  final GiftCardApi _giftCardApi = GiftCardApi();
  final CryptoApi _cryptoApi = CryptoApi();
  final WalletApi _walletApi = WalletApi();
  final NotificationApi _notificationApi = NotificationApi();

  Future<ApiResponseM> signup(SignModel user) async {
    try {
      return await _authApi.createUser(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> signIn(SignModel user) async {
    try {
      return await _authApi.signIn(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> loginWith2Fa(Map<String, dynamic> user) async {
    try {
      return await _authApi.loginWith2Fa(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> requestCode(Map<String, dynamic> emailMap) async {
    try {
      return await _authApi.requestCode(emailMap);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> resetPassword(Map<String, dynamic> resetMap) async {
    try {
      return await _authApi.resetPassword(resetMap);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> activateAccount(ActivateAccountRequest request) async {
    try {
      return await _authApi.activateAccount(request);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> resendCode(String email) async {
    try {
      return await _authApi.resendCode(email);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ApiResponseM> updateNewUserProfile(UpdateUserM user) async {
    try {
      return await _authApi.updateNewUserProfile(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ApiResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> getMyProfile(UserProfileM user) async {
    try {
      var userRes = await _profileApi.getMyProfile(user);
      // if (userRes.statusCode == "USER_FOUND") {
      // get old profile first
      // final oldProfile = await SecureStorageRepo.getUserProfile();

      // preserve token if missing
      // if (userRes.data != null) {
      //   userRes.data!.token ??= oldProfile?.token;
      //   // await SecureStorageRepo.saveUserProfile(userRes.data!);
      // }
      // }
      return userRes;
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> editProfile(
      Map<String, dynamic> profileMap, String token) async {
    try {
      return await _profileApi.editProfile(profileMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> changePassword(
      Map<String, dynamic> passwordMap, String token) async {
    try {
      return await _profileApi.changePassword(passwordMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> sendOtpForPin(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.sendOtpForPin(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> setPin(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.setPin(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> enable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.enable2Fa(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> disable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.disable2Fa(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> allowed2FaType(UserProfileM user) async {
    try {
      return await _profileApi.allowed2FaType(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> sendCode2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.sendCode2Fa(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> getBanks() async {
    try {
      return await _profileApi.getBanks();
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> verifyAccount(Map<String, dynamic> payload) async {
    try {
      return await _profileApi.verifyAccount(payload);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> addBankAccount(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _profileApi.addBankAccount(payload, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<BankAccountsResponse> getMyBankInfo(UserProfileM user) async {
    try {
      return await _profileApi.getMyBankInfo(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              BankAccountsResponse.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> deleteBankAccount(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _profileApi.deleteBankAccount(payload, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<ProfileResponseM> deleteAccount(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _profileApi.deleteAccount(payload, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              ProfileResponseM.error(message, statusCode: statusCode));
    }
  }

  //  ==============  Gift Card Trade

  Future<GiftCardResponseM> fetchCardAsset(String token) async {
    try {
      return await _giftCardApi.fetchAllAssets(token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              GiftCardResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<GiftCardRateResM> fetchAssetRate(
      UserProfileM user, String assetId) async {
    try {
      return await _giftCardApi.fetchAssetRate(user, assetId);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              GiftCardRateResM.error(message, statusCode: statusCode));
    }
  }

  Future<GiftCardResponseM> sellGiftCard(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _giftCardApi.sellGiftCard(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              GiftCardResponseM.error(message, statusCode: statusCode));
    }
  }

  Future<GiftCardResponseM> cancelTrade(
      UserProfileM user, String tradeId, String from) async {
    try {
      return await _giftCardApi.cancelTrade(user, tradeId, from);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              GiftCardResponseM.error(message, statusCode: statusCode));
    }
  }

  //  ==============  Gift Card History

  Future<HistoryResponseM> getTradeHistory(
      Map<String, dynamic> payload, String token,
      {String from = K.CARD}) async {
    try {
      return await _giftCardApi.getTradeHistory(payload, token, from: from);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              HistoryResponseM.error(message, statusCode));
    }
  }

  //  ==============  Crypto Trade

  Future<CryptoRateResponse> fetchCryptoRate(
    UserProfileM user,
    String coinName,
  ) async {
    try {
      return await _cryptoApi.fetchCryptoRate(user, coinName);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              CryptoRateResponse.error(message, statusCode: statusCode));
    }
  }

  Future<CryptoTransactionResM> sellCrypto(
    Map<String, dynamic> fieldMap,
    String token,
  ) async {
    try {
      return await _cryptoApi.sellCrypto(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              CryptoTransactionResM.error(message, statusCode: statusCode));
    }
  }

  //  ==============  Wallet

  Future<WalletBalanceResponse> fetchBalance(UserProfileM user) async {
    try {
      return await _walletApi.fetchBalance(user);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              WalletBalanceResponse.error(message, statusCode: statusCode));
    }
  }

  Future<WithdrawalResponse> withdraw(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _walletApi.withdraw(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              WithdrawalResponse.error(message));
    }
  }

  Future<WithdrawRecordResM> fetchWithdrawRecords(String userId) async {
    try {
      return await _walletApi.fetchWithdrawRecords(userId);
    } catch (e) {
      return checkError(e,
          createError: (String message, {String? statusCode}) =>
              WithdrawRecordResM.error(message));
    }
  }

  //  ==============  Notification

  Future<NotificationResponseM> getNotifications(
    String userid,
    String token, {
    int page = 0,
  }) async {
    try {
      return await _notificationApi.getNotifications(userid, token, page: page);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<ProfileResponseM> savePushToken(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _notificationApi.saveDeviceToken(payload, token);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Future<ProfileResponseM> saveNotificationToBackend(
  //     Map<String, dynamic> payload, String token) async {
  //   try {
  //     return await _notificationApi.saveNotificationToBackend(payload, token);
  //   } catch (e) {
  //     throw Exception('Failed to fetch notifications: $e');
  //   }
  // }

// reusable method
  Future<T> checkError<T>(
    dynamic e, {
    required T Function(String message, {String? statusCode}) createError,
  }) async {
    String message = e.toString();
    String statusCode = 'Failed';
    if (e is Map) {
      message = e['message'];
      statusCode = e['statusCode'];
    }
    return await checkNetwork().then((networkIsOkay) {
      if (networkIsOkay) {
        return createError('Error: $message', statusCode: statusCode);
      } else {
        return createError('No network connection', statusCode: statusCode);
      }
    });
  }

  // check error from network first;
  // Future<T> checkError(dynamic e) async {
  //   return await checkNetwork().then((networkIsOkay) {
  //     if (networkIsOkay) {
  //       return ApiResponseM(
  //           statusCode: "Failed",
  //           status: 404,
  //           message: 'Error: ${e.toString()}',
  //           data: []);
  //     } else {
  //       return ApiResponseM(
  //           statusCode: "Failed - no network",
  //           status: 404,
  //           message: 'No network connection',
  //           data: []);
  //     }
  //   });
  // }
}
