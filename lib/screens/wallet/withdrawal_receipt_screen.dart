import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/date_utils.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';
import '../../data/models/wallet_model.dart';

class WithdrawalReceiptScreen extends StatelessWidget {
  final WithdrawRecordM withdrawalRecord;

  const WithdrawalReceiptScreen({
    super.key,
    required this.withdrawalRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: 'Transaction Receipt'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success Icon and Status
            _buildStatusSection(context),
            const SizedBox(height: 30),

            // Receipt Card
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Amount Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFBF2882), // light purple
                          Color(0xFF5B2C98), // deep indigo
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Amount Withdrawn",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₦ ${AdjustUtils.formatWithComma(withdrawalRecord.amount ?? 0.0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Transaction Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          "Status",
                          withdrawalRecord.statusDisplay,
                          statusColor: AdjustUtils.getStatusColor(
                              withdrawalRecord.statusDisplay),
                          isBold: true,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          "Bank",
                          withdrawalRecord.bankName ?? "N/A",
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          "Account Number",
                          withdrawalRecord.bankAccountNumber ?? "N/A",
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          "Account Name",
                          withdrawalRecord.bankAccountName ?? "N/A",
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          context,
                          "Transaction Reference",
                          withdrawalRecord.reference ?? "N/A",
                          showCopy: true,
                        ),
                        const Divider(height: 24),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          "Date",
                          DateAndTimeUtils.formatToDateAndTime(
                              withdrawalRecord.createdAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton.icon(
            //         onPressed: () => _shareReceipt(context),
            //         icon: const Icon(Icons.share),
            //         label: const Text("Share"),
            //         style: OutlinedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(vertical: 16),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Expanded(
            //       child: ElevatedButton.icon(
            //         onPressed: () => Navigator.pop(context),
            //         icon: const Icon(Icons.check_circle),
            //         label: const Text("Done"),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: context.purpleText,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 16),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    IconData icon;
    Color iconColor;
    String message;

    switch (withdrawalRecord.status) {
      case 'pending':
        icon = Icons.schedule;
        iconColor = Colors.orange;
        message = "Withdrawal is being processed";
        break;
      case 'completed':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        message = "Withdrawal completed!";
        break;
      case 'failed':
        icon = Icons.error;
        iconColor = Colors.red;
        message = "Withdrawal failed";
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
        message = "Withdrawal initiated";
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 60,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: context.blackWhite,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? statusColor,
    bool isBold = false,
    bool showCopy = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: statusColor ?? context.blackWhite,
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (showCopy) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    // Show snackbar
                  },
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _shareReceipt(BuildContext context) {
    final receiptText = '''
Withdrawal Receipt

Amount: ${AdjustUtils.formatWithComma(withdrawalRecord.amount ?? 0.0)}
Status: ${withdrawalRecord.statusDisplay}

Bank: ${withdrawalRecord.bankName ?? 'N/A'}
Account: ${withdrawalRecord.bankAccountNumber ?? 'N/A'}
Name: ${withdrawalRecord.bankAccountName ?? 'N/A'}

Reference: ${withdrawalRecord.reference ?? 'N/A'}

Date: ${DateAndTimeUtils.formatToDateAndTime(withdrawalRecord.createdAt)}

Thank you for using our service!
    ''';

    Clipboard.setData(ClipboardData(text: receiptText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
