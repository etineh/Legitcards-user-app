import 'package:flutter/material.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/InputField.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../services/validation_service.dart';
import '../widgets/PasswordField.dart';
import '../widgets/app_bar.dart';
import '../widgets/code_field_wg.dart';
import '../widgets/custom_text.dart';

class UpdatePinScreen extends StatefulWidget {
  final UserProfileM? user;

  const UpdatePinScreen({super.key, required this.user});

  @override
  State<UpdatePinScreen> createState() => _UpdatePinScreenState();
}

class _UpdatePinScreenState extends State<UpdatePinScreen> {
  late UserProfileM user;
  final ValidationService _validationService = ValidationService();
  bool _showCodeInput = false;
  late String pin;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
  }

  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  Future<void> _requestCode(ProfileViewModel profileVM) async {
    FocusScope.of(context).unfocus(); // hide keyboard
    if (_passwordController.text.isEmpty) {
      if (mounted) context.toastMsg("Password cannot be empty");
      return;
    }

    var payload = {
      "password": _passwordController.text,
      "id": user.userid,
    };

    var sendRes = await profileVM.sendOtpForPin(payload, user.token!);

    if (!mounted) return;
    context.toastMsg(sendRes.message);

    if (sendRes.statusCode == "PIN_ACTIVATION_CODE_SENT") {
      setState(() {
        _showCodeInput = true;
      });
    }
  }

  Future<void> _updatePin(ProfileViewModel profileVM) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;

    try {
      final payload = {
        "token": _codeController.text.toUpperCase(),
        "id": user.userid,
        "pin": pin,
      };

      final profileR = await profileVM.setPin(payload, user.token!);
      if (!mounted) return;
      context.toastMsg(profileR.message);

      if (profileR.statusCode == "PIN_SET") {
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
      appBar: const CustomAppBar(title: "Update Pin"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const CustomText(text: 'Enter new PIN', size: 18),
                const SizedBox(height: 20),
                CodeField(
                  length: 4,
                  keyboardType: TextInputType.number,
                  onChanged: (code) {
                    pin = code;
                  },
                ),
                const SizedBox(height: 20),
                !_showCodeInput
                    ?
                    // Current Password Field
                    PasswordField(
                        fillColor: context.cardColor,
                        controller: _passwordController,
                        labelText: 'Enter Password',
                        textInputAction: TextInputAction.done,
                        validator: _validationService.validatePassword,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InputField(
                            fillColor: context.cardColor,
                            controller: _codeController,
                            labelText: 'Enter the code sent to your email',
                            textInputAction: TextInputAction.done,
                            validator: _validationService.validatePassword,
                          ),
                          CustomText(
                            size: 12,
                            color: context.purpleText,
                            text: K.optInfo,
                          ),
                        ],
                      ),
                const SizedBox(height: 25),
                _showCodeInput
                    ? CustomText(
                        text: "Resend code",
                        underline: true,
                        color: context.purpleText,
                        onTap: () => _requestCode(profileViewModel),
                      )
                    : const SizedBox.shrink(),
                _showCodeInput
                    ? const SizedBox(height: 30)
                    : const SizedBox.shrink(),
                PrimaryButton(
                  text: _showCodeInput ? 'Proceed' : 'Request code',
                  onPressed: () => _showCodeInput
                      ? _updatePin(profileViewModel)
                      : _requestCode(profileViewModel),
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
