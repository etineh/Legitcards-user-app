import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/models/auth_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/gender_selector.dart';
import 'package:legit_cards/screens/widgets/InputField.dart';
import 'package:legit_cards/screens/widgets/LogoWidget.dart';
import 'package:legit_cards/screens/widgets/PasswordField.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:legit_cards/screens/widgets/terms_checkbox.dart';
import 'package:provider/provider.dart';
import '../../Utilities/device_utils.dart';
import '../../services/validation_service.dart';
import 'auth_view_model.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _termsAccepted = false;
  final ValidationService _validationService = ValidationService();
  String? _gender; // Add gender state

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup(AuthViewModel authViewModel) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;

    if (_gender == null) {
      context.toastMsg("Please select your gender");
      return;
    }

    if (!_termsAccepted) {
      context.toastMsg("Please accept the terms and conditions");
      return;
    }

    try {
      String fullName = _fullNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String pNumber = AdjustUtils.normalizePhone(_phoneNumberController.text);

      // get the first name and last name from the fullName
      final user = UpdateUserM(
        userid: "",
        firstname: AdjustUtils.getFirstName(fullName),
        lastname: AdjustUtils.getLastName(fullName),
        phoneNumber: pNumber,
        // email: email,
        password: password,
        gender: _gender!,
        username: AdjustUtils.generateUsername(fullName),
      );

      final deviceDetails = await DeviceUtils.getDeviceDetails();

      final signModel = SignModel(
        email: email,
        password: password,
        phoneNumber: pNumber,
        devicename: deviceDetails["devicename"]!,
        devicetype: deviceDetails["devicetype"]!,
        deviceos: deviceDetails["deviceos"]!,
      );

      final response = await authViewModel.signup(signModel); // signup user
      if (mounted) context.toastMsg(response.message, color: Colors.green);

      if (response.status != 201) return;

      // print("General log: sign up complete ${response.message}");
      final userWithEmail = UserNavigationData(
          updateUserM: user, email: email, signIn: signModel);
      if (mounted) {
        context.goNextScreenWithData(K.otpPath, extra: userWithEmail);
      }
    } catch (e) {
      if (mounted) {
        context.toastMsg("Signup failed: $e", color: Colors.red);
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

                  const SizedBox(height: 25),

                  const SizedBox(height: 20),

                  // Full Name Field
                  InputField(
                    fillColor: context.cardColor,
                    controller: _fullNameController,
                    labelText: 'Enter your full name',
                    hintText: 'e.g John Hin',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    validator: _validationService.validateFullName,
                  ),

                  const SizedBox(height: 10),

                  // Phone Number Field
                  InputField(
                    fillColor: context.cardColor,
                    controller: _phoneNumberController,
                    labelText: 'Enter phone number',
                    hintText: 'e.g 09076600660',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: _validationService.validatePhone,
                  ),

                  const SizedBox(height: 10),

                  // Email Field
                  InputField(
                    fillColor: context.cardColor,
                    controller: _emailController,
                    labelText: 'Enter your email address',
                    hintText: 'your@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validationService.validateEmail,
                  ),

                  const SizedBox(height: 10),

                  // Password Field (Now last field)
                  PasswordField(
                    fillColor: context.cardColor,
                    controller: _passwordController,
                    labelText: 'Enter a strong password',
                    textInputAction: TextInputAction.done,
                    // onFieldSubmitted: (_) => _signup(),
                    validator: _validationService.validatePassword,
                  ),

                  const SizedBox(height: 10),

                  // Gender Radio Group
                  Center(
                    child: RadioGroup<String>(
                      initialValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      options: const [
                        RadioOption(value: 'Male', label: 'Male'),
                        RadioOption(value: 'Female', label: 'Female'),
                      ],
                      activeColor: AppColors.lightPurple,
                      textColor: context.blackWhite,
                      spacing: 30.0,
                    ),
                  ),

                  // Terms and Conditions
                  TermsCheckbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value;
                      });
                    },
                    onPrivacyPolicyTap: () => _launchUrl(
                        'https://legitcards.com.ng/privacy-policy.php'),
                    onTermsTap: () =>
                        _launchUrl('https://legitcards.com.ng/terms.php'),
                    prefixText:
                        'By clicking Sign Up, you have read and agreed to our ',
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Button
                  PrimaryButton(
                    text: 'Sign Up',
                    onPressed: () => _signup(viewModel),
                    isLoading: viewModel.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Divider with "or" text
                  dividerWithOr(context),

                  const SizedBox(height: 5),

                  // Login Link
                  loginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        context.toastMsg('Could not open link');
      }
    }
  }
}

// quick widgets methods

Widget dividerWithOr(BuildContext context) {
  return Row(
    children: [
      Expanded(child: Divider(color: Colors.grey[300])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'or',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
      Expanded(child: Divider(color: Colors.grey[300])),
    ],
  );
}

Widget loginLink(BuildContext context) {
  return TextButton(
    onPressed: () {
      // Navigate to login screen
      context.goNextScreen(K.loginPath);
    },
    child: RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        children: const [
          TextSpan(text: 'Already have an account? '),
          TextSpan(
            text: 'Log in',
            style: TextStyle(
              color: AppColors.lightPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
