import 'package:flutter/material.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../services/validation_service.dart';
import '../widgets/InputField.dart';
import '../widgets/action_card.dart';
import '../widgets/app_bar.dart';

class AdvanceScreen extends StatelessWidget {
  final UserProfileM user;

  const AdvanceScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);

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
                onTap: () => context.toastMsg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
