import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:provider/provider.dart';
import '../../Utilities/cache_utils.dart';
import '../widgets/app_bar.dart';
import '../widgets/bank_details_wg.dart';

class AllBankAccountsScreen extends StatelessWidget {
  final UserProfileM? userProfileM;
  const AllBankAccountsScreen({super.key, this.userProfileM});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (BuildContext context, viewModel, Widget? child) {
        return Scaffold(
          appBar: const CustomAppBar(title: "All Bank Accounts"),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.bankAccount.length,
                  itemBuilder: (context, index) {
                    final bank = viewModel.bankAccount[index];
                    return BankDetailsCard(
                      accountName: bank.accountName,
                      accountNumber: bank.accountNumber,
                      bankName: bank.bankName,
                      onDelete: () async {
                        // call delete API
                        final payload = {
                          "id": userProfileM?.userid,
                          "bankAccountId": bank.id,
                        };
                        var res = await viewModel.deleteBankAccount(
                            payload, userProfileM!.token!);
                        if (res.statusCode == "SUCCESS") {
                          CacheUtils.myBankAccount.clear();
                          viewModel.getMyBankInfo(userProfileM!);
                        }
                      },
                      showActions: false, // switch to delete mode
                      isDeleting: viewModel.isLoading,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  // Navigate to add account
                  GoRouter.of(context).pushReplacementNamed(
                    K.addBankName,
                    extra: userProfileM!,
                  );
                },
                splashColor: Colors.purple.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "ADD ACCOUNT >",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.purpleText,
                        fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
