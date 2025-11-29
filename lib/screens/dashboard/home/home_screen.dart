import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/dashboard/coins/crypto_vm.dart';
import 'package:legit_cards/screens/notification/notification_view_model.dart';
import 'package:legit_cards/screens/wallet/wallet_view_model.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/k.dart';
import '../../../data/models/gift_card_trades_m.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repository/secure_storage_repo.dart';
import '../../../services/firebase_messaging_service.dart';
import '../../widgets/support_count_wg.dart';
import '../gift_cards/gift_card_vm.dart';

class HomeScreen extends StatefulWidget {
  final UserProfileM? userProfileM;
  final Function(int)? onTabChange;
  final Function(GiftCardAssetM)? onCardSelected;

  const HomeScreen({
    super.key,
    required this.userProfileM,
    this.onTabChange,
    this.onCardSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final UserProfileM? userProfileM;
  late final Function(int)? onTabChange;
  late final Function(GiftCardAssetM)? onCardSelected;
  bool _isBalanceVisible = true;
  bool notificationIsUnread = false;

  @override
  void initState() {
    // TODO: implement initState
    userProfileM = widget.userProfileM;
    onTabChange = widget.onTabChange;
    onCardSelected = widget.onCardSelected;
    _loadBalanceVisibility();
    fetchCryptoRates();
    fetchBalance();
    refreshPushToken();

    super.initState();
  }

  Future<void> _loadBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final isVisible = prefs.getBool('balance_visibility') ?? true;
    if (mounted) {
      setState(() {
        _isBalanceVisible = isVisible;
      });
    }
  }

  Future<void> _saveBalanceVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('balance_visibility', isVisible);
  }

  Future<void> refreshPushToken() async {
    final messagingService = FirebaseMessagingService();
    String? getPushToken = await messagingService.getDeviceToken();
    if (getPushToken != null &&
        mounted &&
        (getPushToken != userProfileM?.pushToken)) {
      final payload = {
        "pushToken": getPushToken,
        "email": userProfileM?.email,
      };
      final notificationVM =
          Provider.of<NotificationViewModel>(context, listen: false);
      notificationVM.saveDeviceToken(payload, userProfileM!.token!);
    }
  }

  void fetchBalance() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final walletVM = Provider.of<WalletViewModel>(context, listen: false);
      if (userProfileM == null) return;
      walletVM.fetchBalance(userProfileM!, context: context);

      // check if there is unread notification
      final isUnread =
          await SecureStorageRepo.notificationIsUnread(userProfileM!);
      setState(() {
        notificationIsUnread = isUnread;
      });

      // Check and show notification reminder if needed
      await _checkAndShowNotificationReminder();
    });
  }

  Future<void> _checkAndShowNotificationReminder() async {
    final messagingService = FirebaseMessagingService();
    final hasPermission = await messagingService.isPermissionGranted();

    // Show reminder if notifications are not enabled
    if (!hasPermission && mounted) {
      // Check if 72 hours have passed since last shown
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt('notification_reminder_last_shown') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastShown = (currentTime - lastShown) / (1000 * 60 * 60);

      // Show only if 72 hours have passed or never shown before
      if (hoursSinceLastShown >= 72 || lastShown == 0) {
        // Add a small delay to ensure home screen is fully loaded
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _showNotificationReminderSheet();
          // Save the current timestamp
          await prefs.setInt('notification_reminder_last_shown', currentTime);
        }
      }
    }
  }

  void _showNotificationReminderSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.backgroundColor,
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.purpleText.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                size: 48,
                color: context.purpleText,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            CustomText(
              text: "Stay Updated!",
              shouldBold: true,
              size: 22,
              color: context.blackWhite,
            ),

            const SizedBox(height: 12),

            // Message
            CustomText(
              text:
                  "Don't miss out on important updates about your gift card transactions, rates, and special offers!",
              size: 14,
              color: context.defaultColor,
              // textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Activate Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final messagingService = FirebaseMessagingService();
                  final granted = await messagingService.requestPermission();

                  if (granted) {
                    if (context.mounted) {
                      context.toastMsg('Notifications enabled successfully!');
                    }
                  } else {
                    if (context.mounted) {
                      context
                          .toastMsg('Please enable notifications in Settings');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Activate Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Later button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.defaultColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshBalance() async {
    final walletVM = Provider.of<WalletViewModel>(context, listen: false);
    if (userProfileM == null) return;
    await walletVM.fetchBalance(userProfileM!, context: context);

    // check if there is unread notification
    final isUnread =
        await SecureStorageRepo.notificationIsUnread(userProfileM!);
    setState(() {
      notificationIsUnread = isUnread;
    });
  }

  void fetchCryptoRates() {
    if (userProfileM == null) return;

    CryptoViewModel cryptoVM =
        Provider.of<CryptoViewModel>(context, listen: false);
    cryptoVM.fetchCryptoRates(userProfileM!, "btc", shouldLoad: false);
  }

  @override
  Widget build(BuildContext context) {
    // WalletViewModel walletVM = Provider.of<WalletViewModel>(context);
    return RefreshIndicator(
      onRefresh: _refreshBalance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Greeting + avatar
              _header(),
              const SizedBox(height: 20),

              /// Wallet Balance Card
              _wallet(),
              const SizedBox(height: 20),

              /// Card and Crypto Action Buttons
              _cardAndCryptoButton(),
              const SizedBox(height: 30),

              // hot cards
              _hotCards()
            ],
          ),
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
                // UserProfileM? userProfile =
                //     await SecureStorageRepo.getUserProfile();
                if (mounted) {
                  context.goNextScreenWithData(
                    K.profilePath,
                    extra: userProfileM!,
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
              text:
                  "Hi, ${AdjustUtils.shortName(userProfileM?.firstname ?? "")}!",
              size: 18,
              shouldBold: true,
            )
          ],
        ),

        // RIGHT SIDE: Notification + Support icons
        Row(
          children: [
            // if (notificationIsUnread) // show the indicator icon
            // Just wrap your icon with this
            Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () {
                    context.goNextScreenWithData(K.notificationScreen,
                        extra: userProfileM);
                    setState(() {
                      notificationIsUnread = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child:
                      Icon(Icons.notifications_none, color: context.purpleText),
                ),
                if (notificationIsUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            // UnreadBadge(
            //   userId: userProfileM!.userid!,
            //   child: IconButton(
            //     icon: Icon(Icons.support_agent, color: context.purpleText),
            //     onPressed: () => context.goNextScreenWithData(
            //         K.supportChatsScreen,
            //         extra: userProfileM),
            //   ),
            // ),
            // InkWell(
            //   onTap: () {
            //     context.toastMsg("Live Support coming soon");
            //   },
            //   borderRadius: BorderRadius.circular(20),
            //   child: Icon(Icons.support_agent, color: context.purpleText),
            // ),
            // const SizedBox(width: 5),
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
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    Platform.isIOS ? "Gift Cards" : "Sell your\nGiftcards",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 5),
                    const CustomText(
                      text: "Rate Calculator",
                      color: Colors.white,
                      size: 13,
                    )
                  ],
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
                  Icon(
                      Platform.isIOS
                          ? Icons.dataset_outlined
                          : Icons.currency_bitcoin,
                      color: AppColors.lightPurple,
                      size: 40),
                  const SizedBox(height: 10),
                  Text(
                    Platform.isIOS ? "Sell\nAirtime" : "Trade your\nCoins",
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

  Widget _wallet() {
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
                    final newValue = !_isBalanceVisible;
                    setState(() {
                      _isBalanceVisible = newValue;
                    });
                    _saveBalanceVisibility(newValue);
                  },
                  child: Row(
                    children: [
                      const CustomText(
                        text: "Balance",
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 15),
                      Icon(
                        _isBalanceVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(_isBalanceVisible),
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<WalletViewModel>(
                  builder: (context, walletVM, child) {
                    return Row(
                      children: [
                        CustomText(
                          text: _isBalanceVisible
                              ? "₦${AdjustUtils.formatWithComma(walletVM.wallet?.balance ?? 0.00)}"
                              : "₦*******",
                          size: 25,
                          shouldBold: true,
                          color: Colors.white,
                        ),
                        if (walletVM.isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                )
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
    return Consumer<GiftCardTradeVM>(
      builder: (context, giftCardVM, child) {
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
              padding: const EdgeInsets.symmetric(horizontal: 6),
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
                    leading: Platform.isAndroid
                        ? Container(
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: category.images[0],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFBF2882), // light purple
                                  Color(0xFF5B2C98), // deep indigo
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AdjustUtils.getCardAbbreviation(category.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    title: CustomText(
                      text: category.name,
                      shouldBold: Platform.isAndroid,
                    ),
                    trailing: Platform.isIOS
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              // open the card screen
                              widget.onTabChange?.call(1);

                              // pass the selected card to the screen
                              widget.onCardSelected?.call(category);

                              // fetch card rate
                              giftCardVM.fetchAssetRates(
                                userProfileM!,
                                category.id,
                                context: context,
                                shouldLoad: true,
                              );
                            },
                            child: const Text("Check Rate"),
                          )
                        : null,
                    onTap: () {
                      // open the card screen
                      widget.onTabChange?.call(1);

                      // pass the selected card to the screen
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
              color: context.purpleText,
              underline: true,
              onTap: () {
                widget.onTabChange?.call(1);
              },
            ),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}
// 68d2ce7b40075d28ac01e297h2d5slvd
