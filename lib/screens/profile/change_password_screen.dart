import 'package:flutter/material.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../services/validation_service.dart';
import '../widgets/PasswordField.dart';
import '../widgets/app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  final UserProfileM? user;

  const ChangePasswordScreen({super.key, required this.user});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late UserProfileM user;
  final ValidationService _validationService = ValidationService();

  @override
  void initState() {
    super.initState();
    user = widget.user!;
  }

  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword(ProfileViewModel profileVM) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      context.toastMsg("Confirm password doesn't match with new password");
      return;
    }
    try {
      // prepare map to send to API
      final passwordMap = {
        "id": user.userid,
        "oldPassword": _currentPasswordController.text,
        "password": _newPasswordController.text,
      };

      final profileR = await profileVM.changePassword(passwordMap, user.token!);
      if (!mounted) return;
      context.toastMsg(profileR.message);

      if (profileR.statusCode == "UPDATED") {
        context.goBack();
      }
    } catch (e) {
      if (mounted) {
        print("General log: Update failed: $e");
        context.toastMsg("Update failed: $e", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "Change Password"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Current Password Field
                PasswordField(
                  fillColor: context.cardColor,
                  controller: _currentPasswordController,
                  labelText: 'Current Password',
                  textInputAction: TextInputAction.done,
                  validator: _validationService.validatePassword,
                ),

                const SizedBox(height: 15),

                // new password Name Field
                PasswordField(
                  fillColor: context.cardColor,
                  controller: _newPasswordController,
                  labelText: 'New Password',
                  textInputAction: TextInputAction.done,
                  validator: _validationService.validatePassword,
                ),

                const SizedBox(height: 15),

                // confirm new password Field
                PasswordField(
                  fillColor: context.cardColor,
                  controller: _confirmPasswordController,
                  labelText: 'Confirm New Password',
                  textInputAction: TextInputAction.done,
                  validator: _validationService.validatePassword,
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'Proceed',
                  onPressed: () => _changePassword(profileViewModel),
                  isLoading: profileViewModel.isLoading,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
