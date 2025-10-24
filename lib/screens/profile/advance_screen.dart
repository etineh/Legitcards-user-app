import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/PasswordField.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../services/validation_service.dart';
import '../widgets/action_card.dart';
import '../widgets/app_bar.dart';

class AdvanceScreen extends StatelessWidget {
  final UserProfileM user;

  const AdvanceScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "Advance"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ActionCard(
                text: "Delete Account",
                icon: Icons.delete,
                onTap: () => _showDeleteAccountDialog(context, user),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    UserProfileM user,
  ) async {
    final TextEditingController passwordController = TextEditingController();
    final ValidationService validationService = ValidationService();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const CustomText(
          text: 'Delete Account',
          size: 20,
          shouldBold: true,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              size: 14,
              text:
                  'Are you sure you want to delete your account? By pressing the delete button, you accept that this action cannot be undone and all your data will be permanently deleted.'
                  '\n\nMore importantly; WITHDRAW YOUR FUNDS first! 🙏',
            ),
            const SizedBox(height: 20),
            PasswordField(
              fillColor: context.cardColor,
              controller: passwordController,
              labelText: 'Password',
              textInputAction: TextInputAction.done,
              validator: validationService.validatePassword,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          Consumer<ProfileViewModel>(
            builder: (context, vm, child) {
              return TextButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        if (passwordController.text.isEmpty) {
                          context.toastMsg('Please enter your password',
                              timeInSec: 2);
                          return;
                        }

                        if (passwordController.text.length < 6) {
                          context.toastMsg(
                              'Password must be at least 6 characters',
                              timeInSec: 3);
                          return;
                        }

                        // Call API
                        final payload = {
                          "password": passwordController.text,
                          "userid": user.userid,
                          "id": user.userid,
                        };
                        context.hideKeyboard();
                        await vm.deleteAccount(payload, user.token!, context);

                        // Close dialog after API completes
                        if (context.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }
}
