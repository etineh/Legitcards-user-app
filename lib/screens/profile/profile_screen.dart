import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';
import 'package:legit_cards/services/firebase_messaging_service.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../widgets/action_card.dart';
import '../widgets/bank_details_wg.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfileM? user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  late UserProfileM user;
  bool _is2FAEnabled = false;
  bool _notificationsEnabled = false;
  final _messagingService = FirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    setState(() {
      _is2FAEnabled = user.is2fa ?? false;
    });

    // Check current notification permission status
    _checkNotificationPermission();

    if (CacheUtils.myBankAccount.isEmpty) {
      ProfileViewModel viewModel =
          Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.getMyBankInfo(user);
    }
  }

  Future<void> _checkNotificationPermission() async {
    final isGranted = await _messagingService.isPermissionGranted();
    setState(() {
      _notificationsEnabled = isGranted;
    });
  }

  @override
  void didPopNext() {
    // Called when user navigates back to this screen
    SecureStorageRepo.getUserProfile().then((savedUser) {
      if (savedUser != null) {
        setState(() {
          user = savedUser;
        });
      }
    });
    setState(() {
      ProfileViewModel viewModel =
          Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.getMyBankInfo(user);
    });
  }

  // request code for 2fa
  Future<void> _requestCode(ProfileViewModel profileVM) async {
    var payload = {"id": user.userid};
    // print("General log: ${user.userid} and token: ${user.token} ");
    var sendRes = await profileVM.sendCode2Fa(payload, user.token!);

    if (!mounted) return;
    context.toastMsg(sendRes.message);

    if (sendRes.statusCode == "2FA_ACTIVATION_CODE_SENT") {
      _is2FAEnabled = true;
      context.goNextScreenWithData(K.enable2Fa, extra: user);
    }
  }

  Future<void> _disable2Fa(ProfileViewModel profileVM) async {
    var payload = {"id": user.userid};
    var sendRes = await profileVM.disable2Fa(payload, user.token!);

    if (!mounted) return;
    context.toastMsg(sendRes.message);

    if (sendRes.statusCode == "2FA_DISABLED") {
      setState(() {
        _is2FAEnabled = false;
      });
    }
  }

  Future<void> _handleNotificationToggle(bool enabled) async {
    if (enabled) {
      // Request notification permission
      final granted = await _messagingService.requestPermission();

      if (!mounted) return;

      if (granted) {
        setState(() {
          _notificationsEnabled = true;
        });
        context.toastMsg('Notifications enabled successfully');
      } else {
        setState(() {
          _notificationsEnabled = false;
        });
        context.toastMsg(
            'Notification permission denied. Please enable in Settings.');
      }
    } else {
      // User wants to disable - inform them to do it in system settings
      if (!mounted) return;
      context.showInfoDialog(
        title: 'Disable Notifications',
        subtitle:
            'To disable notifications, please go to your device Settings > Legitcards > Notifications and turn them off.',
      );

      // Revert the switch
      setState(() {
        _notificationsEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "My Profile"),
      body: ModalProgressHUD(
        inAsyncCall: profileViewModel.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Card
              _profileCard(),

              const SizedBox(height: 20),

              // Bank Details Section
              _text('Bank Details'),
              const SizedBox(height: 10),
              CacheUtils.myBankAccount.isEmpty
                  ? ActionCard(
                      text: "Add Bank Account",
                      icon: Icons.add,
                      onTap: () {
                        profileViewModel.getBanks(shouldLoad: false);
                        context.goNextScreenWithData(
                          K.addBankName,
                          extra: user,
                        );
                      },
                    )
                  : BankDetailsCard(
                      accountName: CacheUtils.myBankAccount[0].accountName,
                      accountNumber: CacheUtils.myBankAccount[0].accountNumber,
                      bankName: CacheUtils.myBankAccount[0].bankName,
                      onAddNew: () {
                        profileViewModel.getBanks(shouldLoad: false);
                        context.goNextScreenWithData(
                          K.addBankName,
                          extra: user,
                        );
                      },
                      onViewAll: () {
                        // Navigate to view banks screen
                        context.goNextScreenWithData(
                          K.viewBankAccount,
                          extra: user,
                        );
                      },
                    ),

              const SizedBox(height: 20),

              // Security Section
              _text('Security'),
              const SizedBox(height: 10),

              // Update pin
              ActionCard(
                text: "Update PIN",
                onTap: () {
                  context.goNextScreenWithData(K.updatePin, extra: user);
                },
              ),

              const SizedBox(height: 10),

              // Push Notifications Toggle
              _settingsToggle(
                title: 'Push Notifications',
                subtitle: 'Receive updates about your transactions',
                value: _notificationsEnabled,
                onChanged: _handleNotificationToggle,
              ),

              const SizedBox(height: 10),

              // 2FA
              _settingsToggle(
                title: '2FA',
                subtitle: 'Two-factor authentication',
                value: _is2FAEnabled,
                onChanged: (enabled) {
                  if (_is2FAEnabled) {
                    setState(() {
                      _is2FAEnabled = enabled;
                    });
                  }

                  if (enabled) {
                    _requestCode(profileViewModel);
                  } else {
                    _disable2Fa(profileViewModel);
                    profileViewModel.getMyProfile(user);
                  }
                },
              ),

              const SizedBox(height: 10),

              // Change Password
              ActionCard(
                text: "Change Password",
                onTap: () {
                  context.goNextScreenWithData(K.changePassword, extra: user);
                },
              ),

              const SizedBox(height: 24),

              // Support Section
              _text("Support"),
              const SizedBox(height: 10),

              // Tickets
              // ActionCard(
              //   text: "Live Chat",
              //   onTap: () => context.goNextScreenWithData(K.supportChatsScreen,
              //       extra: user),
              // ),
              //
              // const SizedBox(height: 10),

              // Direct Support
              ActionCard(
                text: "Direct Contact",
                onTap: () => context.goNextScreen(K.directSupportScreen),
              ),

              const SizedBox(height: 30),

              // More - to include 'delete account'
              _text("More"),
              const SizedBox(height: 10),

              ActionCard(
                text: "Advance",
                onTap: () =>
                    context.goNextScreenWithData(K.advanceScreen, extra: user),
              ),

              const SizedBox(height: 30),

              // logout button
              PrimaryButton(
                text: 'Logout',
                onPressed: () => CacheUtils.logout(context),
              ),

              const SizedBox(height: 32),

              // Version
              if (Platform.isAndroid)
                Center(
                  child: Text(
                    'Version ${K.VERSION_NAME} (${K.VERSION_CODE})',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  //  ======== quick widget

  Widget _text(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.purpleText,
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  "${user.firstname ?? ""} ${user.lastname ?? ""}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.blackWhite,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  '@${user.username ?? ""}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  user.email ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  user.phoneNumber,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Update Button
          TextButton(
            onPressed: () {
              context.goNextScreenWithData(K.editProfile, extra: user);
            },
            child: Text(
              'UPDATE',
              style: TextStyle(
                color: context.purpleText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsToggle({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.purpleText.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.blackWhite,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.purpleText,
            inactiveThumbColor: Colors.grey,
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.purple; // outline when ON
                }
                return Colors.grey; // outline when OFF
              },
            ),
          ),
        ],
      ),
    );
  }
}
