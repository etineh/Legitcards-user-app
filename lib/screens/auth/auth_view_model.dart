import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/repository/app_repository.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import '../../data/models/auth_model.dart';
import '../../data/repository/secure_storage_repo.dart';

class AuthViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<ApiResponseM> signup(SignModel user) async {
    return getResponse(_repository.signup(user));
  }

  Future<ApiResponseM> signIn(SignModel user) async {
    return getResponse(_repository.signIn(user));
  }

  Future<ApiResponseM> loginWith2Fa(Map<String, dynamic> user) async {
    return getResponse(_repository.loginWith2Fa(user));
  }

  Future<ApiResponseM> requestCode(Map<String, dynamic> emailMap) async {
    return getResponse(_repository.requestCode(emailMap));
  }

  Future<ApiResponseM> resetPassword(Map<String, dynamic> resetMap) async {
    return getResponse(_repository.resetPassword(resetMap));
  }

  Future<ApiResponseM> activateAccount(ActivateAccountRequest req) {
    return getResponse(_repository.activateAccount(req));
  }

  Future<ApiResponseM> resendCode(String email) {
    return getResponse(_repository.resendCode(email));
  }

  Future<ApiResponseM> updateNewUserProfile(UpdateUserM user) {
    return getResponse(_repository.updateNewUserProfile(user));
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

  void setIsLoadingToTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setIsLoadingToFalse() {
    _isLoading = false;
    notifyListeners();
  }

  // =========  other methods

  Future<void> loginUser(
    SignModel signModel,
    BuildContext context, {
    bool use2Fa = false,
    Map<String, dynamic>? payload, // for 2Fa
    bool goScreen = true,
  }) async {
    final signRes = use2Fa
        ? await loginWith2Fa(payload!)
        : await signIn(signModel); // login user

    if (!context.mounted) return;

    if (signRes.statusCode == "AUTHENTICATED" && signRes.status == 200) {
      final userProfileM = signRes.data!.first.userInfo!;
      userProfileM.token = signRes.data?.first.token;

      // save userProfile data to local shareRef
      SecureStorageRepo.saveUserProfile(userProfileM);

      // Sign in to Firebase anonymously
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        if (kDebugMode) {
          print('General log: Firebase auth error: $e');
        }
      }
      // Navigate to dashboard
      if (context.mounted) {
        context.goNextScreenWithData(K.dashboardScreen, extra: userProfileM);
      }
    } else if (signRes.statusCode == "LOGIN_CODE_SENT" && goScreen) {
      // user has 2fa login screen to enter 2fa code
      context.goNextScreenWithData(K.login2Fa, extra: signModel);
    } else {
      // print("General log: the resss lgin is $signRes");
      context.toastMsg(signRes.message, timeInSec: 6);
    }
  }
}
