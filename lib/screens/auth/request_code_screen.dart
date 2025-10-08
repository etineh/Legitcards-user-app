import 'package:flutter/material.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/InputField.dart';
import 'package:legit_cards/screens/widgets/LogoWidget.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:provider/provider.dart';
import '../../services/validation_service.dart';
import 'auth_view_model.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RequestCodeScreen extends StatefulWidget {
  const RequestCodeScreen({super.key});

  @override
  State<RequestCodeScreen> createState() => _RequestCodeScreenState();
}

class _RequestCodeScreenState extends State<RequestCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final ValidationService _validationService = ValidationService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _signin(AuthViewModel authViewModel) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;

    try {
      String email = _emailController.text.trim();

      final emailMap = {"email": email};

      // print("General log: sign up complete ${response.message}");
      final res = await authViewModel.requestCode(emailMap);
      if (!mounted) return;
      context.toastMsg(res.message);
      if (res.statusCode == "OTP_SENT") {
        // go to reset_password_screen
        context.goNextScreenWithData(K.resetPassword, extra: email);
      }
    } catch (e) {
      if (mounted) {
        context.toastMsg("Signin failed: $e", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: viewModel.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and App Name
                  Center(
                    child: Column(
                      children: [
                        const LogoWidget(size: 100.0),
                        const SizedBox(height: 10),
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: context.blackWhite,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Email Field
                  InputField(
                    fillColor: context.cardColor,
                    controller: _emailController,
                    labelText: 'Email address',
                    hintText: 'your@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validationService.validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  PrimaryButton(
                    text: 'Request code',
                    onPressed: () => _signin(viewModel),
                    isLoading: viewModel.isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// quick widgets methods

Widget signinLink(BuildContext context) {
  return TextButton(
    onPressed: () {
      // Navigate to signin screen
      context.goNextScreenWithData(K.signupPath);
    },
    child: RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        children: [
          const TextSpan(text: 'No account yet? '),
          TextSpan(
            text: 'Register',
            style: TextStyle(
              color: context.purpleText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
