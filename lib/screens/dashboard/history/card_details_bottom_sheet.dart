import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/date_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:path/path.dart';
import '../../../constants/k.dart';
import '../../../data/models/history_model.dart';

class CardDetailBottomSheet extends StatelessWidget {
  final GiftCardTradeM transaction;
  final Function? onActionClick;
  final String? actionText;

  const CardDetailBottomSheet({
    super.key,
    required this.transaction,
    this.onActionClick,
    this.actionText,
  });

  static void show(BuildContext context, GiftCardTradeM transaction,
      String actionText, Function? onActionClick) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardDetailBottomSheet(
        transaction: transaction,
        actionText: actionText,
        onActionClick: onActionClick,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Transaction Status and ID
                  _buildStatusSection(context),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 16),

                  // Transaction Details Card
                  _buildDetailsCard(context),
                  const SizedBox(height: 24),

                  // Cancel button (only show for pending transactions)
                  if (AdjustUtils.statusWithCancelOption(transaction))
                    _buildButton(context),

                  const SizedBox(height: 20),
                  if (transaction.status.toLowerCase() == "selling" ||
                      transaction.status.toLowerCase() == "exchanging")
                    CustomText(
                      text: "Cancel",
                      onTap: () {
                        Navigator.pop(context);
                        context.hideKeyboard();
                      },
                      color: context.defaultColor,
                      italic: true,
                      underline: true,
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          actionText == K.submitNow ? 'Trade Summary' : 'Transaction Status',
          style: TextStyle(
            fontSize: 16,
            color: actionText == K.submitNow ? context.purpleText : Colors.grey,
          ),
        ),
        Text(
          transaction.status.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AdjustUtils.getStatusColor(transaction.status),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionId(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomText(text: "Trans ID: ", color: Colors.white70),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  transaction.id.length > 20
                      ? '${transaction.id.substring(0, 20)}...'
                      : transaction.id,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: transaction.id));
                  context.toastMsg("Transaction ID copied!");
                },
                child: const Icon(
                  Icons.copy,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // CustomText(text: transaction.id, color: Colors.white, maxLines: 1),

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: context.backgroundColor,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBF2882), // light purple
            Color(0xFF5B2C98), // deep indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.backgroundGray),
      ),
      child: Column(
        children: [
          // Card Image and Name
          Row(
            children: [
              // Card Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: transaction.assetImage.isNotEmpty
                      ? transaction.assetImage[0]
                      : '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: context.whiteBlack,
                    child: const Icon(Icons.code_sharp, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Card Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: transaction.assetName,
                      shouldBold: true,
                      size: 18,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: '₦${AdjustUtils.formatWithComma(transaction.cost)}',
                      shouldBold: true,
                      size: 20,
                      color: AppColors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Transaction details
          _buildDetailRow('Country', transaction.country),
          _buildDetailRow('Type', transaction.type),
          _buildDetailRow(
            transaction.type == "Crypto" ? 'Coin Amount' : 'Card Amount',
            '\$${transaction.actualAmount}',
          ),
          _buildDetailRow('Quantity', '${transaction.quantity}'),
          if (transaction.status != "PENDING" &&
              transaction.status != "CANCELLED" &&
              transaction.status != "SELLING" &&
              transaction.status != "EXCHANGING")
            _buildDetailRow('Feedback', transaction.feedbacks.join("\n")),

          if (transaction.status != "SELLING" &&
              transaction.status != "EXCHANGING")
            _buildTransactionId(context),

          const SizedBox(height: 12),

          // Timestamp
          CustomText(
            text:
                DateAndTimeUtils.formatToDateAndTimeLong(transaction.createdAt),
            size: 14,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: "$label:", size: 14, color: Colors.white70),
          CustomText(
            text: value,
            shouldBold: true,
            color: label == "Feedback"
                ? AdjustUtils.getStatusColor(transaction.status)
                : AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: actionText == K.submitNow
              ? AppColors.lightPurple
              : context.cardColor,
          // foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () {
          if (actionText == K.submitNow) {
            Navigator.pop(context); // Close dialog
            onActionClick?.call();
            context.hideKeyboard(); // hide keyboard
          } else {
            _showCancelConfirmation(context);
          }
        },
        child: Text(
          actionText!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: actionText == K.submitNow ? Colors.white : Colors.orange,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(
          text: "Cancel Transaction",
          size: 18,
          shouldBold: true,
        ),
        content: const CustomText(
            text:
                "Are you sure you want to cancel this transaction? This action cannot be undone.'"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep it'),
          ),
          TextButton(
            onPressed: () {
              // Implement cancel transaction logic
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              onActionClick?.call(); // Call cancel API
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
