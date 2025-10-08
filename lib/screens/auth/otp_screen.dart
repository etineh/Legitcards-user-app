import 'dart:async';
import 'package:flutter/material.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../../data/models/auth_model.dart';
import '../widgets/code_field_wg.dart';
import 'auth_view_model.dart';

class OtpScreen extends StatefulWidget {
  final UserNavigationData? user;

  const OtpScreen({super.key, this.user});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late Timer _timer;
  int _remainingSeconds = 60; // change to 60
  bool _canResend = false;
  bool _showSupport = false;
  late UserNavigationData user;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = 60; // change to 60
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          _showSupport = true;
          _canResend = true;
        });
        _timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // verify code
  Future<void> _verifyOtp(String code, AuthViewModel authVM) async {
    final request = ActivateAccountRequest(email: user.email, code: code);

    try {
      final response = await authVM.activateAccount(request);
      // print("General log: what is user activate response $response");

      final String? userId = response.data?.isNotEmpty == true
          ? response.data!.first.userid
          : null;

      if (userId == null) {
        if (mounted) context.toastMsg(response.message);
        return;
      }

      authVM.setIsLoadingToTrue();

      user.updateUserM.userid = userId; // add userid to user profile
      await authVM.updateNewUserProfile(user.updateUserM);

      if (mounted) authVM.loginUser(user.signIn, context);
    } catch (e) {
      if (mounted) context.toastMsg("Verify failed: $e", color: Colors.red);
      print("General log: error on login $e");
    }
  }

  // resend otp
  Future<void> _resendOtp(AuthViewModel authViewModel) async {
    if (!_canResend) return;

    try {
      final response = await authViewModel.resendCode(user.email);

      if (!mounted) return;

      if (response.status == 200 && response.statusCode == "OTP_SENT") {
        _startCountdown();
      } else {
        context.toastMsg(response.message);
      }
    } catch (e) {
      print("General log: otp error: $e");
      if (mounted) context.toastMsg("Resend failed: $e", color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.goBack();
            },
          ),
          title: const Text(
            "Verification",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryPurple),
      body: ModalProgressHUD(
        inAsyncCall: authViewModel.isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppColors.lightPurple,
                ),

                const SizedBox(height: 20),
                Text(
                  "Enter the 6-digit code sent to your email ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: context.blackWhite),
                ),

                const SizedBox(height: 20),

                // OTP Input
                CodeField(
                  onCompleted: (code) {
                    _verifyOtp(code, authViewModel);
                  },
                ),
                CustomText(
                  size: 12,
                  color: context.purpleText,
                  text:
                      "Please check your spam folder if not received in your inbox",
                ),

                const SizedBox(height: 30),

                // Countdown + Resend
                _canResend
                    ? TextButton(
                        onPressed: () => _resendOtp(authViewModel),
                        child: const Text("Resend OTP"),
                      )
                    : Text("Resend in $_remainingSeconds s",
                        style: const TextStyle(color: Colors.grey)),

                // Show Support Section
                if (_showSupport) ...[
                  const SizedBox(height: 50),
                  const Divider(color: Colors.grey),
                  const SelectableText(
                    "Any issue? Contact support: \nCall: 0806 051 7997 \nEmail: support@legitcards.com.ng",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
