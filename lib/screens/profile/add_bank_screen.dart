import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/profile/profile_view_model.dart';
import 'package:legit_cards/screens/widgets/app_bar.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../widgets/InputField.dart';

class AddBankAccountScreen extends StatefulWidget {
  final UserProfileM? user;

  const AddBankAccountScreen({super.key, required this.user});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _accountNumberController = TextEditingController();
  BankM? _selectedBank;
  bool _showBankList = false;
  bool _isVerified = false;
  String _searchQuery = '';
  String _accountName = '';
  UserProfileM? user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  List<BankM> _getFilteredBanks(List<BankM> banks) {
    if (_searchQuery.isEmpty) {
      return banks;
    }
    return banks
        .where((bank) =>
            bank.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      appBar: CustomAppBar(
        title: 'Add bank Account',
        onBack: () {
          if (_showBankList) {
            setState(() {
              _showBankList = false;
            });
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return _showBankList
              ? _buildBankList(viewModel) // bank list for dropdown
              : _buildAddBankForm(viewModel); // account number field | button
        },
      ),
    );
  }

  // account number | dropdown | Account Name | button
  Widget _buildAddBankForm(ProfileViewModel profileVM) {
    return ModalProgressHUD(
      inAsyncCall: profileVM.isLoading,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Account Number Field
              InputField(
                fillColor: context.cardColor,
                controller: _accountNumberController,
                labelText: 'Enter account number',
                hintText: 'e.g 9076600660',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.account_balance_wallet_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    _isVerified = false;
                  });
                }, // I want the get the value from onChange
                // validator: _validationService.validatePhone,
              ),

              const SizedBox(height: 20),

              // Bank Selection Dropdown
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showBankList = true;
                    _isVerified = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedBank?.name ?? 'Select your bank',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedBank != null
                                ? context.blackWhite
                                : Colors.grey[600],
                          ),
                          overflow:
                              TextOverflow.ellipsis, // adds ... if too long
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: context.purpleText,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              CustomText(text: _accountName, shouldBold: true),

              const Spacer(),

              // Add Bank Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_selectedBank != null &&
                          _accountNumberController.text.isNotEmpty)
                      ? () {
                          _verifyOrAddBankAccount(profileVM);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _isVerified ? 'Add Bank Account' : 'Verify Account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // bank list for dropdown
  Widget _buildBankList(ProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Back button and Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      _showBankList = false;
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search bank',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bank List
          Expanded(
            child: _buildBanksItemCard(viewModel),
          ),
        ],
      ),
    );
  }

  // card for bank list dropdown
  Widget _buildBanksItemCard(ProfileViewModel viewModel) {
    List<BankM> banks = viewModel.banks;

    if (banks.isEmpty) viewModel.getBanks(shouldLoad: true);

    final filteredBanks = _getFilteredBanks(banks);

    if (filteredBanks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No banks available, Reload page!' : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    //  if list is not empty, return this card item
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredBanks.length,
      itemBuilder: (context, index) {
        final bank = filteredBanks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF8E24AA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              bank.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.blackWhite,
              ),
            ),
            onTap: () => _verifyAccountName(bank, viewModel),
          ),
        );
      },
    );
  }

  void _verifyOrAddBankAccount(ProfileViewModel viewModel) {
    // print("General log: bank details is $_selectedBank");
    context.hideKeyboard();
    if (_accountNumberController.text.length != 10) {
      context.toastMsg("Account number must be 10 digits");
      return;
    }
    if (_selectedBank == null) {
      context.toastMsg("Please select a bank name");
      return;
    }

    if (_isVerified) {
      _addBankAccount(viewModel);
    } else {
      _verifyAccountName(_selectedBank, null);
    }
  }

  Future<void> _verifyAccountName(
      BankM? bank, ProfileViewModel? viewModel) async {
    setState(() {
      _selectedBank = bank;
      _showBankList = false;
    });

    if (_accountNumberController.text.length != 10 || bank == null) return;
    viewModel ??= Provider.of<ProfileViewModel>(context, listen: false);
    if (mounted) context.toastMsg("Verifying account number...");

    final payload = {
      "bankCode": bank.code,
      "accountNumber": _accountNumberController.text
    };
    final res = await viewModel.verifyAccount(payload);
    if (res.status == "success") {
      setState(() {
        _accountName = res.bankAccountDetails!.bankAccountName;
        _isVerified = true;
      });
    } else {
      if (mounted) context.toastMsg("Invalid account number");
    }
  }

  void _addBankAccount(ProfileViewModel viewModel) async {
    try {
      final payload = {
        "id": user?.userid,
        "bankName": _selectedBank?.name,
        "accountName": _accountName,
        "accountNumber": _accountNumberController.text,
        "data": {
          "LENCO": _selectedBank?.code,
        },
      };

      final res = await viewModel.addBankAccount(payload, user!.token!);
      if (mounted) context.toastMsg(res.message);

      if (res.statusCode == "SUCCESS") {
        await viewModel.getMyBankInfo(user!);
        if (mounted) context.goBack();
      }
    } catch (e) {
      if (mounted) context.toastMsg("Adding failed: $e");
      // print("General log: adding account $e");
    }
  }
}
