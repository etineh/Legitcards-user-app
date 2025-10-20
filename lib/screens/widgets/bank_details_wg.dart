import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

import '../../Utilities/cache_utils.dart';

class BankDetailsCard extends StatelessWidget {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final VoidCallback? onAddNew;
  final VoidCallback? onViewAll;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isDeleting;

  const BankDetailsCard({
    super.key,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    this.onAddNew,
    this.onViewAll,
    this.onDelete,
    this.showActions = true, // default is Add/ViewAll mode
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: showActions
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.purpleText.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow("Account Name", accountName, context),
                const SizedBox(height: 8),
                _buildRow("Account Number", accountNumber, context),
                const SizedBox(height: 8),
                _buildRow("Bank Name", bankName, context),
                const SizedBox(height: 16),
                if (showActions)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: onViewAll,
                        splashColor: Colors.purple.withOpacity(0.2),
                        child: Text(
                          CacheUtils.myBankAccount.length > 1
                              ? "VIEW ALL"
                              : "VIEW ACCOUNT",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.purpleText,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onAddNew,
                        splashColor: Colors.purple.withOpacity(0.2),
                        child: Text(
                          "ADD NEW",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.purpleText,
                          ),
                        ),
                      ),
                    ],
                  )
                else // delete button case (like All Bank Accounts)
                  Center(
                    child: isDeleting
                        ? const CircularProgressIndicator(
                            color: Colors.red) // ✅ loader
                        : GestureDetector(
                            onTap: onDelete,
                            child: const Text(
                              "DELETE",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: context.blackWhite,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
