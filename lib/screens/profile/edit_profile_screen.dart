import 'package:flutter/material.dart';
import 'package:legit_cards/data/repository/secure_storage_repo.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../services/validation_service.dart';
import '../widgets/InputField.dart';
import '../widgets/app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileM? user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserProfileM user;
  final ValidationService _validationService = ValidationService();

  @override
  void initState() {
    super.initState();
    user = widget.user!;
    _firstNameController.text = user.firstname ?? '';
    _lastNameController.text = user.lastname ?? '';
    _usernameController.text = user.username ?? '';
  }

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _updateProfile(ProfileViewModel profileVM) async {
    FocusScope.of(context).unfocus(); // hide keyboard

    if (!_formKey.currentState!.validate()) return;
    try {
      // prepare map to send to API
      final profileMap = {
        "id": user.userid,
        "firstname": _firstNameController.text.trim(),
        "lastname": _lastNameController.text.trim(),
        "gender": user.gender,
        "username": _usernameController.text.trim(),
      };

      final profileRes = await profileVM.editProfile(profileMap, user.token!);
      if (!mounted) return;
      context.toastMsg(profileRes.message);
      if (profileRes.statusCode == "UPDATED") {
        // save update to local db
        user.username = _usernameController.text.trim();
        user.firstname = _firstNameController.text.trim();
        user.lastname = _lastNameController.text.trim();
        // SecureStorageRepo.saveUserProfile(user);
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
      appBar: const CustomAppBar(title: "Edit Profile"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // First Name Field
                InputField(
                  fillColor: context.cardColor,
                  controller: _firstNameController,
                  labelText: 'First name',
                  hintText: 'e.g, John',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: _validationService.validateFullName,
                ),

                const SizedBox(height: 15),

                // last Name Field
                InputField(
                  fillColor: context.cardColor,
                  controller: _lastNameController,
                  labelText: 'Last name',
                  hintText: 'e.g, Honey',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: _validationService.validateFullName,
                ),

                const SizedBox(height: 15),

                // Username Field
                InputField(
                  fillColor: context.cardColor,
                  controller: _usernameController,
                  labelText: 'Username',
                  hintText: 'e.g, joel',
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.alternate_email,
                  validator: _validationService.validateFullName,
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'Update',
                  onPressed: () => _updateProfile(profileViewModel),
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
