import 'package:flutter/material.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../constants/k.dart';
import '../../data/models/user_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/code_field_wg.dart';
import '../widgets/custom_text.dart';

class Enable2FaScreen extends StatefulWidget {
  final UserProfileM? user;

  const Enable2FaScreen({super.key, required this.user});

  @override
  State<Enable2FaScreen> createState() => _Enable2FaScreenState();
}

class _Enable2FaScreenState extends State<Enable2FaScreen> {
  late UserProfileM user;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    // context.mounted
  }

  Future<void> _requestCode(ProfileViewModel profileVM) async {
    var payload = {"id": user.userid};
    var sendRes = await profileVM.sendCode2Fa(payload, user.token!);
    if (mounted) context.toastMsg(sendRes.message);
  }

  Future<void> _enable2Fa(ProfileViewModel profileVM, String code) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    try {
      var payload = {
        "type": "email",
        "id": user.userid,
        "code": code,
      };

      final profileR = await profileVM.enable2Fa(payload, user.token!);
      if (!mounted) return;
      context.toastMsg(profileR.message);

      if (profileR.statusCode == "2FA_ENABLED") {
        user.is2fa = true;
        SecureStorageRepo.saveUserProfile(user);
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
      appBar: const CustomAppBar(title: "Verify 2fa"),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: profileViewModel.isLoading,
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
                    _enable2Fa(profileViewModel, code);
                  },
                ),
                CustomText(
                  size: 12,
                  color: context.purpleText,
                  text: K.optInfo,
                ),
                const SizedBox(height: 20),
                CustomText(
                  text: "Resend code",
                  underline: true,
                  color: context.purpleText,
                  onTap: () => _requestCode(profileViewModel),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
