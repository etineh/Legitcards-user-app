import 'package:flutter/cupertino.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import '../constants/k.dart';
import '../data/models/user_bank_model.dart';

class CacheUtils {
  static void logout(BuildContext context) {
    SecureStorageRepo.clearUserProfile();
    // Clear backstack and go to login
    context.goNextScreenAndRemoveUntil(K.loginPath);
  }

  static List<BankAccount> myBankAccount = [];
  // List<BankAccount> get bankAccount => _bankAccount;
}
