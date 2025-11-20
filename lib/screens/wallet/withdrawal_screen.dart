import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/data/models/wallet_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/wallet/wallet_view_model.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../Utilities/adjust_utils.dart';
import '../../constants/k.dart';
import '../../data/models/user_bank_model.dart';
import '../../data/models/user_model.dart';
import '../profile/profile_view_model.dart';
import '../widgets/PrimaryButton.dart';
import '../widgets/code_field_wg.dart';
import '../widgets/custom_text.dart';

class WithdrawalScreen extends StatefulWidget {
  final UserProfileM? userProfileM;
  // final Function(int, {int? historyTab})? onTabChange;

  const WithdrawalScreen({
    super.key,
    this.userProfileM,
    // this.onTabChange,
  });

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  late UserProfileM userProfileM;
  final _amountController = TextEditingController();
  BankAccount? selectedAccount;
  bool _isAmountInvalid = true;
  // double walletBalance = 0.0;
  double minimumWithdrawal = 1000.0;
  double transactionFee = 0.0;

  // Sample bank accounts
  List<BankAccount> bankAccounts = CacheUtils.myBankAccount;

  @override
  void initState() {
    super.initState();
    userProfileM = widget.userProfileM!;
    // TODO: Fetch wallet balance from API
    // WalletViewModel walletVM =
    //     Provider.of<WalletViewModel>(context, listen: false);
    // walletBalance = walletVM.wallet?.balance ?? 0.0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateAmountToReceive(String value) {
    final amount = double.tryParse(value) ?? 0.0;
    WalletViewModel walletVM =
        Provider.of<WalletViewModel>(context, listen: false);

    setState(() {
      _isAmountInvalid = amount < minimumWithdrawal ||
          amount > (walletVM.wallet?.balance ?? 0.0);
    });
  }

  Future<void> _processToPIN() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount < minimumWithdrawal) {
      context.toastMsg(
        "Minimum withdrawal is ₦${AdjustUtils.formatWithComma(minimumWithdrawal)}",
        color: Colors.red,
      );
      return;
    }
    WalletViewModel walletVM =
        Provider.of<WalletViewModel>(context, listen: false);
    if (amount > (walletVM.wallet?.balance ?? 0.0)) {
      context.toastMsg("Insufficient balance", color: Colors.red);
      return;
    }

    if (selectedAccount == null) {
      context.toastMsg("Please select a bank account", color: Colors.red);
      return;
    }

    // Show pin dialog
    _showPINDialog(amount);
  }

  void _showPINDialog(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.hideKeyboard(),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const CustomText(
                      text: "Enter PIN",
                      size: 20,
                      shouldBold: true,
                    ),
                    const SizedBox(height: 20),

                    // Pin Field
                    CodeField(
                      onCompleted: (code) {
                        Navigator.pop(context);
                        context.hideKeyboard();
                        _submitWithdrawal(amount, code);
                      },
                      length: 4,
                      keyboardType: TextInputType.number,
                      onChanged: (code) {
                        // pin = code;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Cancel button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.hideKeyboard();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitWithdrawal(double amount, String pin) async {
    var payload = {
      "name": "$userProfileM.firstname $userProfileM.lastname",
      "bankCode": selectedAccount?.data?.lenco,
      "bankName": selectedAccount?.bankName,
      "bankAccountName": selectedAccount?.accountName,
      "bankAccountNumber": selectedAccount?.accountNumber,
      "amount": amount.toString(),
      "email": userProfileM.email,
      "user_id": userProfileM.userid,
      "pin": pin,
      "id": userProfileM.userid,
      "version": K.VERSION_CODE,
    };

    WalletViewModel walletVM =
        Provider.of<WalletViewModel>(context, listen: false);
    final res = await walletVM.withdraw(payload, userProfileM.token!);

    if (!mounted) return;
    context.toastMsg(res.status!);

    if (res.status == "success") {
      setState(() {
        _amountController.clear();
        selectedAccount = null;
      });

      // Convert WithdrawalDataM to WithdrawRecordM
      final withdrawRecord = WithdrawRecordM.fromWithdrawalData(res.data!);

      // Navigate to receipt screen
      // context.goNextScreenWithData(K.withdrawReceiptScreen, extra: withdrawRecord)
      GoRouter.of(context).pushReplacementNamed(
        K.withdrawReceiptScreen,
        // (route) => false, // Removes all routes until false is returned
        extra: withdrawRecord,
      );
    } else {
      if (kDebugMode) {
        print("General log: withdraw error  - ${res.status}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    WalletViewModel walletVM = Provider.of<WalletViewModel>(context);
    return ModalProgressHUD(
      inAsyncCall: walletVM.isLoading,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: const CustomAppBar(title: "Withdrawal"),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.hideKeyboard(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight -
                    32, // 32 is the padding (16 top + 16 bottom)
              ),
              child: Column(
                children: [
                  // Amount Input
                  _buildAmountInput(walletVM),
                  const SizedBox(height: 16),

                  // Select Bank Account
                  _buildBankSelection(),
                  const SizedBox(height: 24),

                  // Transaction Summary (shown when amount is entered)
                  if (!_isAmountInvalid) ...[
                    _buildTradeSummaryOnInputAmount(amount),
                    const SizedBox(height: 24),
                  ],

                  // Withdraw Button
                  const SizedBox(height: 24),
                  _buildProceedButton(walletVM)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton(WalletViewModel walletVM) {
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    bool canProceed = selectedAccount != null &&
        amount >= minimumWithdrawal &&
        amount <= (walletVM.wallet?.balance ?? 0.0);

    return canProceed
        ? PrimaryButton(
            onPressed: _processToPIN,
            backgroundColor: AppColors.lightPurple,
            text: "Proceed",
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
          )
        : PrimaryButton(
            disabledBackgroundColor: context.backgroundGray,
            text: "Proceed",
            textStyle: const TextStyle(color: Colors.grey, fontSize: 18),
          );
  }

  Widget _buildAmountInput(WalletViewModel walletVM) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.purpleText.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: "Enter Amount",
                shouldBold: true,
                size: 14,
              ),
              CustomText(
                text:
                    "Balance: ₦ ${AdjustUtils.formatWithComma(walletVM.wallet?.balance ?? 0.00)}",
                shouldBold: true,
                size: 14,
                color: context.purpleText,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.blackWhite,
            ),
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(
                color: context.defaultColor,
              ),
              prefixText: "₦ ",
              prefixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.blackWhite,
              ),
              border: InputBorder.none,
              errorText: _isAmountInvalid ? "Invalid amount" : null,
            ),
            onChanged: (value) => _calculateAmountToReceive(value),
          ),
          const SizedBox(height: 8),
          Text(
            "Min: ₦${AdjustUtils.formatWithComma(minimumWithdrawal)}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSelection() {
    return GestureDetector(
      onTap: _showBankAccountSheet,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedAccount != null
                ? context.purpleText.withOpacity(0.3)
                : Colors.grey.shade200.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedAccount != null
                    ? context.purpleText.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance,
                color: selectedAccount != null
                    ? context.purpleText
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: selectedAccount != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: selectedAccount!.bankName,
                          shouldBold: true,
                          size: 14,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: selectedAccount!.accountNumber,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    )
                  : const CustomText(
                      text: "Select withdraw account",
                      color: Colors.grey,
                    ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showBankAccountSheet() {
    context.hideKeyboard();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBankAccountSheet(),
    );
  }

  Widget _buildBankAccountSheet() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.hideKeyboard(),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const CustomText(
              text: "Select Bank Account",
              size: 18,
              shouldBold: true,
            ),
            const SizedBox(height: 20),

            // Bank accounts list
            ...bankAccounts.map((account) => _buildBankAccountItem(account)),

            const SizedBox(height: 16),

            // Add bank account button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ProfileViewModel viewModel =
                    Provider.of<ProfileViewModel>(context, listen: false);
                viewModel.getBanks(shouldLoad: false);

                // Navigate to add bank account screen
                GoRouter.of(context).pushReplacementNamed(
                  K.addBankName,
                  // (route) => false, // Removes all routes until false is returned
                  extra: userProfileM,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.purpleText, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: context.purpleText),
                    const SizedBox(width: 8),
                    CustomText(
                      text: "ADD BANK ACCOUNT",
                      color: context.purpleText,
                      shouldBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountItem(BankAccount account) {
    final isSelected = selectedAccount?.accountNumber == account.accountNumber;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAccount = account;
        });
        Navigator.pop(context);
        context.hideKeyboard();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.purpleText.withOpacity(0.1)
              : context.backgroundColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.purpleText
                : Colors.grey.shade300.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Bank icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.purpleText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance,
                color: context.purpleText,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Bank details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: account.bankName,
                    shouldBold: true,
                    size: 14,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: account.accountNumber,
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.purpleText,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeSummaryOnInputAmount(double amount) {
    final amountToReceive =
        amount > transactionFee ? amount - transactionFee : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBF2882), // light purple
            Color(0xFF5B2C98), // deep indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Amount",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              Text(
                "₦${AdjustUtils.formatWithComma(amount)}",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transaction Fee",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              Text(
                "-₦${AdjustUtils.formatWithComma(transactionFee)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300.withOpacity(0.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: "You will receive:",
                color: Colors.white,
                size: 14,
              ),
              CustomText(
                text: "₦${AdjustUtils.formatWithComma(amountToReceive)}",
                size: 18,
                shouldBold: true,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
