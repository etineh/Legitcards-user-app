import 'package:flutter/material.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/models/auth_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/InputField.dart';
import 'package:legit_cards/screens/widgets/LogoWidget.dart';
import 'package:legit_cards/screens/widgets/PasswordField.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import '../../Utilities/cache_utils.dart';
import '../../Utilities/device_utils.dart';
import '../../data/models/user_model.dart';
import '../../data/repository/secure_storage_repo.dart';
import '../../services/validation_service.dart';
import 'auth_view_model.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // bool _termsAccepted = false;
  final ValidationService _validationService = ValidationService();
  UserProfileM? userProfileM; // Add gender state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await SecureStorageRepo.getUserProfile();
      _emailController.text = user?.email ?? "";
      setState(() {
        userProfileM = user;
      });
    });
  }

  Future<void> _signin(AuthViewModel authViewModel) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      final deviceDetails = await DeviceUtils.getDeviceDetails();

      final signModel = SignModel(
        email: email,
        password: password,
        phoneNumber: "+2349077777777",
        devicename: deviceDetails["devicename"]!,
        devicetype: deviceDetails["devicetype"]!,
        deviceos: deviceDetails["deviceos"]!,
      );
      // print("General log: sign up complete ${response.message}");
      if (mounted) authViewModel.loginUser(signModel, context);
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
                          'LegitCards',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: context.blackWhite,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Email Field
                  userProfileM == null
                      ? InputField(
                          fillColor: context.cardColor,
                          controller: _emailController,
                          labelText: 'Email address',
                          hintText: 'your@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validationService.validateEmail,
                        )
                      : Center(
                          child: CustomText(
                            text: "Welcome ${userProfileM?.firstname}!",
                            size: 20,
                          ),
                        ),

                  const SizedBox(height: 20),

                  // Password Field (Now last field)
                  PasswordField(
                    fillColor: context.cardColor,
                    controller: _passwordController,
                    labelText: 'Password',
                    textInputAction: TextInputAction.done,
                    // onFieldSubmitted: (_) => _signup(),
                    validator: _validationService.validatePassword,
                  ),

                  const SizedBox(height: 25),

                  // Sign Up Button
                  PrimaryButton(
                    text: 'Login',
                    onPressed: () => _signin(viewModel),
                    isLoading: viewModel.isLoading,
                  ),

                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        context.goNextScreen(K.requestCode);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: context.purpleText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Signin Link
                  userProfileM == null
                      ? signinLink(context)
                      : Center(
                          child: CustomText(
                            size: 18,
                            text: "Logout",
                            color: Colors.orange,
                            onTap: () {
                              setState(() {
                                userProfileM = null;
                              });
                              CacheUtils.logout(context);
                              _emailController.text = "";
                            },
                          ),
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
