import 'package:flutter/material.dart';
import 'package:legit_cards/data/models/auth_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/auth/auth_view_model.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/code_field_wg.dart';
import '../widgets/custom_text.dart';

class Login2FaScreen extends StatefulWidget {
  final SignModel? user;

  const Login2FaScreen({super.key, required this.user});

  @override
  State<Login2FaScreen> createState() => _Login2FaScreenState();
}

class _Login2FaScreenState extends State<Login2FaScreen> {
  late SignModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    // context.mounted
  }

  Future<void> _resent2FaCode(AuthViewModel authVM) async {
    authVM.loginUser(user, context, goScreen: false);
  }

  Future<void> _loginWith2Fa(AuthViewModel authVM, String code) async {
    try {
      var payload = {
        "email": user.email,
        "password": user.password,
        "devicename": user.devicename,
        "devicetype": user.devicetype,
        "deviceos": user.deviceos,
        "twoFaCode": code
      };

      if (mounted) {
        authVM.loginUser(user, context, use2Fa: true, payload: payload);
      }
    } catch (e) {
      if (mounted) {
        print("General log: login with 2fa failed: $e");
        context.toastMsg("Login failed: $e", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: const CustomAppBar(title: "Verify 2fa"),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: authViewModel.isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const CustomText(
                    text: 'Enter the code sent to your email', size: 18),
                const SizedBox(height: 20),
                CodeField(
                  keyboardType: TextInputType.text,
                  onCompleted: (code) {
                    _loginWith2Fa(authViewModel, code);
                  },
                ),
                const SizedBox(height: 20),
                CustomText(
                  text: "Resend code",
                  underline: true,
                  color: context.purpleText,
                  onTap: () => _resent2FaCode(authViewModel),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
