import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/Utilities/date_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/data/models/wallet_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../../constants/k.dart';
import '../../../data/models/history_model.dart';
import '../../../data/models/user_model.dart';
import 'card_details_bottom_sheet.dart';
import 'history_view_model.dart';

class HistoryScreen extends StatefulWidget {
  final UserProfileM? userProfileM;
  // final Function(int)? onTabChange;

  const HistoryScreen({super.key, this.userProfileM});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfileM? user;

  @override
  void initState() {
    super.initState();
    user = widget.userProfileM!;
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCardAndCryptoTransactions();
      _fetchCardAndCryptoTransactions();
      _fetchWithdrawTransactions();
    });
    _navigateToCoinTab();
  }

  void _navigateToCoinTab() {
    if (CacheUtils.historyTab == K.COIN) {
      _tabController.index = 1; // ✅ navigate the tab index
      CacheUtils.historyTab = K.CARD;
    }
  }

  Future<void> _fetchCardAndCryptoTransactions() async {
    // Call your view model to fetch transactions
    final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    final payload = {
      "id": user?.userid,
      "filter": {
        // dropped: false,
        "status": 'ALL',
      },
      "start": 0,
      "sort": 'desc',
    };

    viewModel.fetchCardHistory(payload, user!.token!, context: context);
    if (CacheUtils.historyTab == K.COIN) viewModel.coinHistory.clear();
    viewModel.fetchCoinHistory(payload, user!.token!, context: context);
  }

  void _fetchWithdrawTransactions() {
    final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    viewModel.fetchWithdrawRecords(user!.userid!, context: context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildTabBar(), // This won't rebuild when historyViewModel changes
          const SizedBox(height: 16),
        ],
      ),
      builder: (context, historyViewModel, staticChild) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: ModalProgressHUD(
            inAsyncCall: historyViewModel.isLoading,
            child: Column(
              children: [
                staticChild!, // Reuses the static widgets

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCardsTab(historyViewModel),
                      _buildCoinsTab(historyViewModel),
                      _buildWithdrawTab(historyViewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        // isScrollable: true, // Add this
        tabAlignment: TabAlignment.fill, // Add this for even distribution
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.8),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'CARDS'),
          Tab(text: 'COINS'),
          Tab(text: 'WITHDRAWS'),
        ],
      ),
    );
  }

  Widget _buildCardsTab(HistoryViewModel historyViewModel) {
    if (historyViewModel.cardHistory.isEmpty) {
      return _buildEmptyState('No card transactions yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: historyViewModel.cardHistory.length,
      itemBuilder: (context, index) {
        final transaction = historyViewModel.cardHistory[index];
        return InkWell(
          onTap: () => _openTradeHistory(transaction),
          child: _buildTransactionCard(transaction),
        );
      },
    );
  }

  Widget _buildCoinsTab(HistoryViewModel historyViewModel) {
    if (historyViewModel.coinHistory.isEmpty) {
      return _buildEmptyState('No coin— transactions yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: historyViewModel.coinHistory.length,
      itemBuilder: (context, index) {
        final transaction = historyViewModel.coinHistory[index];
        return InkWell(
          onTap: () => _openTradeHistory(transaction, from: K.COIN),
          child: _buildTransactionCard(transaction),
        );
      },
    );
  }

  Widget _buildWithdrawTab(HistoryViewModel historyViewModel) {
    if (historyViewModel.withdrawRecords.isEmpty) {
      return _buildEmptyState('No card transactions yet');
    }

    // Sort by date (newest first)
    historyViewModel.withdrawRecords
        .sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

    if (historyViewModel.withdrawRecords.isEmpty) {
      return _buildEmptyState('No withdrawal history yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: historyViewModel.withdrawRecords.length,
      itemBuilder: (context, index) {
        final withdraw = historyViewModel.withdrawRecords[index];
        return InkWell(
          onTap: () => context.goNextScreenWithData(K.withdrawReceiptScreen,
              extra: withdraw),
          child: _buildWithdrawCard(withdraw),
        );
      },
    );
  }

  Widget _buildWithdrawCard(WithdrawRecordM withdraw) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.backgroundGray),
      ),
      child: Row(
        children: [
          // Icon - Bank/Withdrawal Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.purpleText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance,
              color: context.purpleText,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),

          // Withdrawal Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: withdraw.bankName ?? 'Bank Withdrawal',
                  shouldBold: true,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: withdraw.bankAccountNumber ?? '',
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text:
                      DateAndTimeUtils.formatToDateAndTime(withdraw.createdAt),
                  size: 12,
                ),
              ],
            ),
          ),

          // Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text:
                    "₦ ${AdjustUtils.formatWithComma(withdraw.amount ?? 0.0)}",
                shouldBold: true,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdjustUtils.getStatusColor(withdraw.status!)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomText(
                  text: withdraw.statusDisplay.toUpperCase(),
                  size: 12,
                  color: AdjustUtils.getStatusColor(withdraw.status!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(GiftCardTradeM transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.backgroundGray),
      ),
      child: Row(
        children: [
          // Icon/Logo
          Container(
            width: 60,
            // height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              // set image
              imageUrl: transaction.assetImage[0],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => transaction.assetName
                          .toLowerCase() ==
                      "btc"
                  ? const Icon(Icons.currency_bitcoin, color: Colors.orange)
                  : const Icon(Icons.settings_ethernet, color: Colors.orange),
            ),
          ),
          const SizedBox(width: 16),
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: transaction.assetName, shouldBold: true),
                const SizedBox(height: 4),
                CustomText(
                    text:
                        DateAndTimeUtils.formatTimestamp(transaction.createdAt),
                    size: 12)
              ],
            ),
          ),
          // Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: '₦${AdjustUtils.formatWithComma(transaction.cost)}',
                shouldBold: true,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdjustUtils.getStatusColor(transaction.status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomText(
                  text: transaction.status.toUpperCase(),
                  size: 12,
                  color: AdjustUtils.getStatusColor(transaction.status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _openTradeHistory(GiftCardTradeM transaction, {String from = K.CARD}) {
    CardDetailBottomSheet.show(context, transaction, "Cancel Transaction",
        () async {
      // call back function
      final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
      final res = await viewModel.cancelTrade(user!, transaction.id, from);

      if (mounted) context.toastMsg(res.message);
      if (res.statusCode == "TRADE_CANCELLED") {
        _fetchCardAndCryptoTransactions();
      }
    });
  }
}
