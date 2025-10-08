import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/services/api/profile_api.dart';

import '../../extension/inbuilt_ext.dart';
import '../../services/api/auth_api.dart';
import '../../services/api/gift_card_api.dart';
import '../models/auth_model.dart';
import '../models/gift_card_trades_m.dart';
import '../models/history_model.dart';
import '../models/user_bank_model.dart';

class AppRepository {
  final AuthApi _authApi = AuthApi();
  final ProfileApi _profileApi = ProfileApi();
  final GiftCardApi _giftCardApi = GiftCardApi();

  Future<ApiResponseM> signup(SignModel user) async {
    try {
      return await _authApi.createUser(user);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> signIn(SignModel user) async {
    try {
      return await _authApi.signIn(user);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> loginWith2Fa(Map<String, dynamic> user) async {
    try {
      return await _authApi.loginWith2Fa(user);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> requestCode(Map<String, dynamic> emailMap) async {
    try {
      return await _authApi.requestCode(emailMap);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> resetPassword(Map<String, dynamic> resetMap) async {
    try {
      return await _authApi.resetPassword(resetMap);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> activateAccount(ActivateAccountRequest request) async {
    try {
      return await _authApi.activateAccount(request);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> resendCode(String email) async {
    try {
      return await _authApi.resendCode(email);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ApiResponseM> updateNewUserProfile(UpdateUserM user) async {
    try {
      return await _authApi.updateNewUserProfile(user);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ApiResponseM.error(message));
    }
  }

  Future<ProfileResponseM> getMyProfile(UserProfileM user) async {
    try {
      var userRes = await _profileApi.getMyProfile(user);
      if (userRes.statusCode == "USER_FOUND") {
        // get old profile first
        final oldProfile = await SecureStorageRepo.getUserProfile();

        // preserve token if missing
        if (userRes.data != null) {
          userRes.data!.token ??= oldProfile?.token;
          await SecureStorageRepo.saveUserProfile(userRes.data!);
        }
      }
      return userRes;
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> editProfile(
      Map<String, dynamic> profileMap, String token) async {
    try {
      return await _profileApi.editProfile(profileMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> changePassword(
      Map<String, dynamic> passwordMap, String token) async {
    try {
      return await _profileApi.changePassword(passwordMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> sendOtpForPin(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.sendOtpForPin(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> setPin(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.setPin(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> enable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.enable2Fa(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> disable2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.disable2Fa(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> allowed2FaType(UserProfileM user) async {
    try {
      return await _profileApi.allowed2FaType(user);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> sendCode2Fa(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _profileApi.sendCode2Fa(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> getBanks() async {
    try {
      return await _profileApi.getBanks();
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> verifyAccount(Map<String, dynamic> payload) async {
    try {
      return await _profileApi.verifyAccount(payload);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<ProfileResponseM> addBankAccount(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _profileApi.addBankAccount(payload, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  Future<BankAccountsResponse> getMyBankInfo(UserProfileM user) async {
    try {
      return await _profileApi.getMyBankInfo(user);
    } catch (e) {
      return checkError(e,
          createError: (String message) => BankAccountsResponse.error(message));
    }
  }

  Future<ProfileResponseM> deleteBankAccount(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _profileApi.deleteBankAccount(payload, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => ProfileResponseM.error(message));
    }
  }

  //  ==============  Gift Card Trade

  Future<GiftCardResponseM> fetchCardAsset(String token) async {
    try {
      return await _giftCardApi.fetchAllAssets(token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => GiftCardResponseM.error(message));
    }
  }

  Future<GiftCardRateResM> fetchAssetRate(
      UserProfileM user, String assetId) async {
    try {
      return await _giftCardApi.fetchAssetRate(user, assetId);
    } catch (e) {
      return checkError(e,
          createError: (String message) => GiftCardRateResM.error(message));
    }
  }

  Future<GiftCardResponseM> sellGiftCard(
      Map<String, dynamic> fieldMap, String token) async {
    try {
      return await _giftCardApi.sellGiftCard(fieldMap, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => GiftCardResponseM.error(message));
    }
  }

  Future<GiftCardResponseM> cancelCardTrade(
      UserProfileM user, String tradeId) async {
    try {
      return await _giftCardApi.cancelCardTrade(user, tradeId);
    } catch (e) {
      return checkError(e,
          createError: (String message) => GiftCardResponseM.error(message));
    }
  }

  //  ==============  Gift Card History

  Future<HistoryResponseM> getCardHistory(
      Map<String, dynamic> payload, String token) async {
    try {
      return await _giftCardApi.getCardHistory(payload, token);
    } catch (e) {
      return checkError(e,
          createError: (String message) => HistoryResponseM.error(message));
    }
  }

// reusable method
  Future<T> checkError<T>(
    dynamic e, {
    required T Function(String message) createError,
  }) async {
    return await checkNetwork().then((networkIsOkay) {
      if (networkIsOkay) {
        return createError('Error: ${e.toString()}');
      } else {
        return createError('No network connection');
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
