import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/dashboard/history/history_screen.dart';
import 'package:provider/provider.dart';

import '../../data/models/gift_card_trades_m.dart';
import '../../data/repository/secure_storage_repo.dart';
import '../profile/profile_view_model.dart';
import '../wallet/withdrawal_screen.dart';
import 'coins/coin_screen.dart';
import 'gift_cards/gift_card_screen.dart';
import 'gift_cards/gift_card_vm.dart';
import 'home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfileM? userProfileM;

  const DashboardScreen({super.key, this.userProfileM});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfileM? userProfileM;
  int currentIndex = 0;
  GiftCardAssetM? selectedCard;
  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Add the onTabChange method
  void onTabChange(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void updateSelectedCard(GiftCardAssetM card) {
    setState(() {
      selectedCard = card;
      currentIndex = 1; // navigate to GiftCardScreen
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await SecureStorageRepo.getUserProfile();
    if (!mounted) return;
    setState(() {
      userProfileM = widget.userProfileM ?? profile;
    });
    // print("General log: What is userProfile $userProfileM");

    if (userProfileM == null ||
        userProfileM?.userid == null ||
        userProfileM?.token == null) {
      if (mounted) CacheUtils.logout(context);
    } else {
      ProfileViewModel viewModel =
          Provider.of<ProfileViewModel>(context, listen: false);
      // get bank account details
      viewModel.getMyBankInfo(userProfileM!, context: context);
      // get gift card asset
      final giftCardVM = Provider.of<GiftCardTradeVM>(context, listen: false);
      giftCardVM.fetchCardAssets(userProfileM!.token!, shouldLoad: false);
    }
  }

  /// Handles the back press logic neatly
  void _handleBackPress(bool didPop) {
    if (didPop) return;

    // Navigate back to Home if not on home tab
    if (currentIndex != 0) {
      setState(() => currentIndex = 0);
      return;
    }

    // Handle double-tap to exit
    final now = DateTime.now();
    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      context.toastMsg("Press back again to exit");
    } else {
      SystemNavigator.pop(); // Exit app
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _handleBackPress(didPop);
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: AppColors.lightPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed, // important for text to show
          showUnselectedLabels: true, // <— make sure unselected text shows
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard), label: "Cards"),
            BottomNavigationBarItem(
                icon: Icon(Icons.currency_bitcoin), label: "Coins"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
          ],
        ),
        body: SafeArea(
          child: _getBody(currentIndex, (index) {
            setState(() {
              currentIndex = index;
            });
          }),
        ),
      ),
    );
  }

  Widget _getBody(int index, Function(int) onTabChange) {
    // print("General log: what is index - $index");
    final card = selectedCard; // temporarily store it
    selectedCard = null; // immediately reset so next time it's null

    switch (index) {
      case 0:
        return HomeScreen(
          userProfileM: userProfileM,
          onTabChange: onTabChange,
          onCardSelected: updateSelectedCard,
          // onWithdrawalTap: _handleWithdrawalNavigation, // Pass the handler
        );
      case 1:
        return GiftCardScreen(
          userProfileM: userProfileM,
          onTabChange: onTabChange,
          transferSelectCard: card,
        );
      case 2:
        return CoinScreen(
          userProfileM: userProfileM,
          onTabChange: onTabChange,
        );
      case 3:
        return HistoryScreen(
          userProfileM: userProfileM,
        ); // change later
      default:
        return HomeScreen(
          userProfileM: userProfileM,
          onTabChange: onTabChange,
        );
    }
  }
}
