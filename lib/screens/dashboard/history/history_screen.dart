import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/date_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
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
  // late final Function(int)? onTabChange;

  late TabController _tabController;
  late UserProfileM? user;
  late List<GiftCardTradeM> _cardHistory = [];
  late List<GiftCardTradeM> _coinHistory = [];

  @override
  void initState() {
    super.initState();
    user = widget.userProfileM!;
    _tabController = TabController(length: 3, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions({String from = K.CARD}) async {
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
    final res =
        await viewModel.getCardHistory(payload, user!.token!, from: from);
    if (res.statusCode == "TRADE_FOUND") {
      setState(() {
        if (from == K.CARD) {
          _cardHistory = res.data;
        } else {
          _coinHistory = res.data;
        }
      });
    } else {
      if (mounted) context.toastMsg(res.message);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyViewModel = Provider.of<HistoryViewModel>(context);

    return ModalProgressHUD(
      inAsyncCall: historyViewModel.isLoading,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Expanded(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Tab Bar
              _buildTabBar(),
              const SizedBox(height: 16),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCardsTab(),
                    _buildCoinsTab(),
                    _buildActivitiesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
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
          Tab(text: 'ACTIVITIES'),
        ],
      ),
    );
  }

  Widget _buildCardsTab() {
    final cardTransactions = _cardHistory;

    if (cardTransactions.isEmpty) {
      return _buildEmptyState('No card transactions yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cardTransactions.length,
      itemBuilder: (context, index) {
        final transaction = cardTransactions[index];
        return InkWell(
          onTap: () => _openTradeHistory(transaction),
          child: _buildTransactionCard(transaction),
        );
      },
    );
  }

  Widget _buildCoinsTab() {
    // final fundTransactions = [_cardHistory];
    final coinTransactions = _coinHistory;

    if (coinTransactions.isEmpty) {
      _fetchTransactions(from: K.CRYPTO);
      return _buildEmptyState('No coin— transactions yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: coinTransactions.length,
      itemBuilder: (context, index) {
        final transaction = coinTransactions[index];
        return InkWell(
          onTap: () => _openTradeHistory(transaction, from: K.CRYPTO),
          child: _buildTransactionCard(transaction),
        );
      },
    );
  }

  Widget _buildActivitiesTab() {
    // All activities combined
    if (_coinHistory.isEmpty) {
      _fetchTransactions(from: K.CRYPTO);
    }
    final transactions = [
      ..._cardHistory,
      ..._coinHistory // change to fund later
    ];
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (transactions.isEmpty) {
      return _buildEmptyState('No activities yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return InkWell(
          onTap: () => _openTradeHistory(transaction), // change later
          child: _buildTransactionCard(transaction),
        );
      },
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
        _fetchTransactions(from: from);
      }
    });
  }
}
