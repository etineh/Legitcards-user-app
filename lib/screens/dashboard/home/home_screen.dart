import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/wallet/wallet_view_model.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:provider/provider.dart';

import '../../../constants/k.dart';
import '../../../data/models/gift_card_trades_m.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repository/secure_storage_repo.dart';
import '../../wallet/withdrawal_screen.dart';
import '../gift_cards/gift_card_vm.dart';

class HomeScreen extends StatefulWidget {
  final UserProfileM? userProfileM;
  final Function(int)? onTabChange;
  final Function(GiftCardAssetM)? onCardSelected;
  // final VoidCallback? onWithdrawalTap;

  const HomeScreen({
    super.key,
    required this.userProfileM,
    this.onTabChange,
    this.onCardSelected,
    // this.onWithdrawalTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final UserProfileM? userProfileM;
  late final Function(int)? onTabChange;
  late final Function(GiftCardAssetM)? onCardSelected;
  // String walletBalance = "₦ 150,000.00";
  bool _isBalanceVisible = true;

  @override
  void initState() {
    // TODO: implement initState
    userProfileM = widget.userProfileM!;
    onTabChange = widget.onTabChange;
    onCardSelected = widget.onCardSelected;
    fetchBalance();
    super.initState();
  }

  void fetchBalance() {
    WalletViewModel viewModel =
        Provider.of<WalletViewModel>(context, listen: false);
    viewModel.fetchBalance(userProfileM!, context: context);
  }

  @override
  Widget build(BuildContext context) {
    WalletViewModel walletVM = Provider.of<WalletViewModel>(context);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Greeting + avatar
            _header(),
            const SizedBox(height: 20),

            /// Wallet Balance Card
            _wallet(walletVM),
            const SizedBox(height: 20),

            /// Card and Crypto Action Buttons
            _cardAndCryptoButton(),
            const SizedBox(height: 30),

            // hot cards
            _hotCards()
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEFT SIDE: Avatar + Greeting
        Row(
          children: [
            InkWell(
              onTap: () async {
                UserProfileM? userProfile =
                    await SecureStorageRepo.getUserProfile();
                if (mounted) {
                  context.goNextScreenWithData(
                    K.profilePath,
                    extra: userProfile!,
                  );
                }
              },
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: const Icon(Icons.person, color: Colors.purple),
              ),
            ),
            const SizedBox(width: 10),
            CustomText(
              text: "Hi, ${AdjustUtils.shortName(userProfileM!.firstname)}!",
              size: 18,
              shouldBold: true,
            )
          ],
        ),

        // RIGHT SIDE: Notification + Support icons
        Row(
          children: [
            InkWell(
              onTap: () {
                context.toastMsg("Notifications in progress");
              },
              borderRadius: BorderRadius.circular(20),
              child: Icon(Icons.notifications_none, color: context.purpleText),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () {
                context.toastMsg("Support coming soon");
              },
              borderRadius: BorderRadius.circular(20),
              child: Icon(Icons.support_agent, color: context.purpleText),
            ),
            const SizedBox(width: 5),
          ],
        ),
      ],
    );
  }

  Widget _cardAndCryptoButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // gift card
        Expanded(
          child: InkWell(
            onTap: () {
              // Navigate to sell gift-cards
              onTabChange?.call(1);
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(right: 15, left: 15),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(
                //     color: AppColors.primaryPurple, width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "Sell your\nGiftcards",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // crypto card
        Expanded(
          child: InkWell(
            onTap: () {
              // Navigate to trade coins
              onTabChange?.call(2);
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(left: 15, right: 15),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightPurple, width: 1),
              ),
              child: Column(
                children: [
                  const Icon(Icons.currency_bitcoin,
                      color: Colors.orange, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    "Trade your\nCoins",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.purpleText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wallet(WalletViewModel walletVM) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBF2882), // light purple
            Color(0xFF5B2C98), // deep indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: context.backgroundGray, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                  child: Row(
                    children: [
                      const CustomText(
                        text: "Balance",
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 15),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          key: ValueKey(_isBalanceVisible),
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  // if walletVM.isLoading -- rotate loading circle bar on the balance and show bal when false
                  child: walletVM.isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                            strokeWidth: 2.5,
                          ),
                        )
                      : CustomText(
                          key: ValueKey(
                              '${_isBalanceVisible}_${walletVM.wallet?.balance}'),
                          text: _isBalanceVisible
                              ? "₦${AdjustUtils.formatWithComma(walletVM.wallet?.balance ?? 0.00)}"
                              : "₦*******",
                          size: 25,
                          shouldBold: true,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),

          // Right side - Withdraw button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.cardColor,
              // foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => context.goNextScreenWithData(K.withdrawScreen,
                extra: userProfileM),
            child: Text(
              "Withdraw",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: context.blackWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotCards() {
    final giftCardVM = Provider.of<GiftCardTradeVM>(context, listen: false);
    final allCategories = giftCardVM.assets;

    // 1️⃣ Get Apple, Steam, and Razer
    final fixed = allCategories.where((c) {
      final name = c.name.toLowerCase();
      return name.contains("apple") ||
          name.contains("steam") ||
          name.contains("razor");
    }).toList();

// 2️⃣ Filter the four allowed for random pick
    final allowedRandoms = allCategories.where((c) {
      final name = c.name.toLowerCase();
      return name.contains("footlocker") ||
          name.contains("tremendous") ||
          name.contains("sephora") ||
          name.contains("macy");
    }).toList();

// 3️⃣ Shuffle and pick 2 random from those allowed
    allowedRandoms.shuffle();
    final randomTwo = allowedRandoms.take(2).toList();

// 4️⃣ Combine all together
    final categories = [...fixed, ...randomTwo];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomText(
            text: "🔥 Hot Gift Cards",
            color: context.purpleText,
            shouldBold: true,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: category.images[0],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                  ),
                ),
                title: CustomText(text: category.name, shouldBold: true),
                onTap: () {
                  // open the card screen
                  widget.onTabChange?.call(1);
                  // pass the select card to the screen
                  final selected = categories[index];
                  widget.onCardSelected?.call(selected);
                  // fetch card rate
                  giftCardVM.fetchAssetRates(
                    userProfileM!,
                    categories[index].id,
                    context: context,
                    shouldLoad: true,
                  );
                },
              ),
            );
          },
        ),
        CustomText(
          text: "open more...",
          italic: true,
          underline: true,
          onTap: () {
            onTabChange?.call(1);
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
