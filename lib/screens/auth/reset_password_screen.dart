import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/auth/auth_view_model.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:provider/provider.dart';
import '../../services/validation_service.dart';
import '../widgets/InputField.dart';
import '../widgets/PasswordField.dart';
import '../widgets/app_bar.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ValidationService _validationService = ValidationService();
  final _formKey = GlobalKey<FormState>();
  late String email;

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword(AuthViewModel authVN) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      context.toastMsg("Confirm password doesn't match with new password");
      return;
    }
    try {
      // prepare map to send to API
      final passwordMap = {
        "recoverytoken": _codeController.text.toUpperCase(),
        "email": email,
        "password": _newPasswordController.text,
      };

      final resetRes = await authVN.resetPassword(passwordMap);
      if (!mounted) return;
      context.toastMsg(resetRes.message);

      if (resetRes.statusCode == "CODE_VERIFIED") {
        context.goNextScreen(K.loginPath);
      }
    } catch (e) {
      if (mounted) {
        if (kDebugMode) print("General log: reset password failed: $e");
        context.toastMsg("Update failed: $e", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

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

                // Recovery Code Field
                InputField(
                  fillColor: context.cardColor,
                  controller: _codeController,
                  labelText: 'Enter recovery code',
                  prefixIcon: Icons.code,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
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
                  onPressed: () => _changePassword(authViewModel),
                  isLoading: authViewModel.isLoading,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
