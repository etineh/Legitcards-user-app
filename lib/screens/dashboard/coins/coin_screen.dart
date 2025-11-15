import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/constants/app_colors.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/models/crypto_trade_m.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/dashboard/coins/crypto_vm.dart';
import 'package:legit_cards/screens/widgets/InputField.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../Utilities/adjust_utils.dart';
import '../../../Utilities/cloudinary_utils.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/PrimaryButton.dart';

class CoinScreen extends StatefulWidget {
  final UserProfileM? userProfileM;
  final Function(int)? onTabChange; // unused yet

  const CoinScreen({
    super.key,
    this.userProfileM,
    this.onTabChange,
  });

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  late UserProfileM userProfileM;
  late final Function(int)? onTabChange;

  String? selectedCoin;
  String? selectedNetwork;
  final _amountController = TextEditingController();
  bool _isAmountInvalid = false;
  List<File> uploadedImages = [];
  List<String> uploadedUrls = [];
  double calculatedRate = 0.0;

  // Sample coin data
  final List<String> coins = [K.BTC, K.USDT, K.ETH];
  final Map<String, List<String>> networks = {
    K.USDT: ['TRON(TRC20)', 'ERC20', 'BEP20'],
    K.BTC: ['Bitcoin Network'],
    K.ETH: ['Ethereum Network'],
  };

  // Sample wallet addresses for different networks
  final Map<String, String> walletAddresses = {
    '${K.USDT}-TRON(TRC20)': K.usdtTrc20,
    '${K.USDT}-ERC20': K.usdtErc20,
    '${K.USDT}-BEP20': K.usdtBep20,
    '${K.BTC}-Bitcoin Network': K.btcBtcNet,
    '${K.ETH}-Ethereum Network': K.ethEthNet,
    // 'ETH-ERC20': 'Ex4K7M9N2P5Q8R1S',
  };

  @override
  void initState() {
    userProfileM = widget.userProfileM!;
    onTabChange = widget.onTabChange;

    setState(() {
      selectedCoin = K.BTC;
    });

    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateRate(CryptoViewModel cryptoVM, String value) {
    double amount = double.tryParse(value) ?? 0;
    if (selectedCoin == null) return;
    CryptoRateM? cryptoRateM = cryptoVM.getRateForAmount(selectedCoin!, amount);
    setState(() {
      _isAmountInvalid = !cryptoRateM!.isInRange(amount);
      if (!_isAmountInvalid) {
        calculatedRate = (cryptoRateM.rate ?? 0) * amount;
        cryptoVM.toNairaRate = "Rate: ₦${cryptoRateM.rate}/＄";
      } else {
        cryptoVM.getRate(selectedCoin!); // full range
      }
    });
  }

  String _getRange(CryptoViewModel cryptoVM) {
    if (selectedCoin == null) return "Enter Amount";
    String from = cryptoVM.getLeastAmount(selectedCoin!.toLowerCase());
    String to = cryptoVM.getHighestAmount(selectedCoin!.toLowerCase());
    return "Range: \$$from - \$$to";
  }

  void showEachRateOnDialogInfo() {
    final cryptoOuterVM = Provider.of<CryptoViewModel>(context, listen: false);
    final rates = cryptoOuterVM.rates[selectedCoin!.toLowerCase()] ?? [];

    String subtitle;

    if (rates.isEmpty) {
      subtitle = "No rates available";
    } else if (rates.length == 1) {
      final rate = rates.first;
      subtitle =
          "Amount: \$${rate.from} - \$${rate.to}\nRate: ₦${rate.rate?.toStringAsFixed(2)}/\$";
    } else {
      // Multiple rates
      subtitle = rates.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final rate = entry.value;
        return "$index. Range \$${rate.from} - \$${rate.to} : ₦${rate.rate?.toStringAsFixed(2)}/\$";
      }).join('\n\n');
    }

    context.showInfoDialog(
      title: 'Rate Information',
      subtitle: subtitle,
    );
  }

  String? get currentWalletAddress {
    if (selectedCoin != null && selectedNetwork != null) {
      return walletAddresses['$selectedCoin-$selectedNetwork'];
    }
    return null;
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        // Camera still needs permission
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            context.toastMsg("Camera permission denied");
          }
          return;
        }
      }

      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        File file = await AdjustUtils.optimizeImage(File(pickedFile.path));
        setState(() {
          uploadedImages.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        context.toastMsg("Error picking image: $e");
      }
    }
  }

  void _showPickerOptions() {
    context.hideKeyboard();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: context.purpleText),
                title: const CustomText(text: "Pick from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: context.purpleText),
                title: const CustomText(text: "Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cryptoVM = Provider.of<CryptoViewModel>(context);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: cryptoVM.isLoading,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.hideKeyboard(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Coin Selector
                _buildCoinSelector(cryptoVM),
                const SizedBox(height: 16),

                // Network Selector
                if (selectedCoin != null) _buildNetworkSelector(cryptoVM),
                if (selectedCoin != null) const SizedBox(height: 20),

                if (selectedNetwork != null) ...[
                  // QR Code and Wallet Address Section
                  _buildQRCodeSection(),
                  const SizedBox(height: 10),
                  _buildWalletAddressSection(),
                  const SizedBox(height: 10),
                  _buildWarningMessage(),
                  const SizedBox(height: 20),

                  // Amount Input
                  _buildAmountInput(cryptoVM),
                  const SizedBox(height: 16),

                  // if (_amountController.text.isNotEmpty &&
                  //     double.tryParse(_amountController.text) != null &&
                  //     double.tryParse(_amountController.text)! > 0) ...[
                  //   // _buildRateDisplay(),
                  //   // const SizedBox(height: 20),
                  // ],

                  // Rate Display
                  _buildRateDisplay(cryptoVM),
                  const SizedBox(height: 20),

                  // steps of images uploads
                  _imageInfo(),
                  const SizedBox(height: 15),

                  // Upload Image Section
                  _buildImageUploadSection(),
                  const SizedBox(height: 30),
                ],

                // Proceed Button
                if (selectedNetwork != null) _buildProceedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinSelector(CryptoViewModel cryptoVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomText(
            text: Platform.isIOS
                ? "Select Coin to exchange"
                : "Select Coin to sell",
            size: 14),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.purpleText),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: coins.map((coin) {
              final isSelected = selectedCoin == coin;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // fetch rate
                    cryptoVM.fetchCryptoRates(userProfileM, coin.toLowerCase(),
                        context: context);
                    setState(() {
                      selectedCoin = coin;
                      selectedNetwork = null;
                      _amountController.clear();
                      calculatedRate = 0.0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightPurple
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: coin == coins.first
                            ? const Radius.circular(12)
                            : Radius.zero,
                        right: coin == coins.last
                            ? const Radius.circular(12)
                            : Radius.zero,
                      ),
                    ),
                    child: Text(
                      coin,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkSelector(CryptoViewModel cryptoVM) {
    final availableNetworks = networks[selectedCoin] ?? [];

    // Auto-select if only one network available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (availableNetworks.length == 1 &&
          selectedNetwork != availableNetworks.first) {
        cryptoVM.getRate(selectedCoin);
        setState(() {
          selectedNetwork = availableNetworks.first;
        });
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedNetwork,
          borderRadius: BorderRadius.circular(12),
          hint: const Text(
            "Choose network",
            style: TextStyle(color: Colors.grey),
          ),
          dropdownColor: context.cardColor,
          items: availableNetworks.map((network) {
            return DropdownMenuItem(
              value: network,
              child: CustomText(
                text: network,
                color: context.blackWhite,
              ),
            );
          }).toList(),
          onChanged: (value) {
            cryptoVM.getRate(selectedCoin);
            setState(() {
              selectedNetwork = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBF2882), // light purple
            Color(0xFF5B2C98), // deep indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomText(
            text: "$selectedCoin - $selectedNetwork",
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: currentWalletAddress ?? '',
              version: QrVersions.auto,
              size: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CustomText(text: "Wallet Address"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomText(text: currentWalletAddress ?? '', size: 14),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    context.copyText(textToCopy: currentWalletAddress!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          // Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
              child: CustomText(
            text:
                "1. Send your $selectedCoin to the wallet address provided here. \n2. After sending, upload your transaction proof and click on proceed to submit your trade. \n3. Sending to wrong address or an address on another network may result in lost coins.",
            size: 12,
            color: Colors.black,
          )),
        ],
      ),
    );
  }

  Widget _buildAmountInput(CryptoViewModel cryptoVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputField(
          onChanged: (value) => _calculateRate(cryptoVM, value),
          fillColor: context.cardColor,
          controller: _amountController,
          labelText: "Enter ${selectedCoin ?? 'USDT'} Amount",
          hintText: _getRange(cryptoVM),
          hintTextColor: context.defaultColor.withOpacity(0.3),
          prefixIcon: Icons.monetization_on_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          focusedBorderColor:
              _isAmountInvalid ? Colors.red : AppColors.lightPurple,
          // validator: _validationService.validateEmail,
        ),
      ],
    );
  }

  Widget _imageInfo() {
    return InkWell(
      onTap: () => context.showInfoDialog(
        title: 'Steps',
        subtitle: "1. Copy the address (the exact network address)"
            "\n2. Go to your exchange and deposit the amount"
            "\n3. Screenshot the payment receipt and upload",
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // change the 3 to dynamic number according to asset
          CustomText(text: "Upload payment proof", color: context.purpleText),
          const SizedBox(width: 10),
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 10),

        //  === display images
        uploadedImages.isNotEmpty
            ? Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: uploadedImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            // === show image here
                            image: DecorationImage(
                              image: FileImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                uploadedImages.remove(image);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
            // upload image
            : GestureDetector(
                onTap: _showPickerOptions,
                child: Container(
                  // width: 95,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.purpleText,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.purpleText, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload, color: context.whiteBlack, size: 30),
                      CustomText(text: "Upload", color: context.whiteBlack),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildRateDisplay(CryptoViewModel cryptoVM) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.cardCo,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // subtle shadow color
            blurRadius: 8, // how soft the shadow is
            offset: const Offset(0, 3), // horizontal, vertical offset
          ),
        ],
        // border: Border.all(color: Colors.grey[500]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: showEachRateOnDialogInfo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: cryptoVM.toNairaRate,
                  color: context.blackWhite,
                  size: 12,
                ),
                const SizedBox(width: 10),
                Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
              ],
            ),
          ),
          // const SizedBox(height: 8),
          Text(
            "₦${AdjustUtils.formatWithComma(calculatedRate)}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.purpleText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    final isValid = selectedCoin != null &&
        selectedNetwork != null &&
        _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.tryParse(_amountController.text)! > 0 &&
        uploadedImages.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _showTradeSummary : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPurple,
          disabledBackgroundColor: context.backgroundGray,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Proceed",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isValid ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    bool isAddress = false,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight
            ? context.purpleText.withOpacity(0.1)
            : context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(color: context.purpleText, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: value,
              size: isHighlight ? 18 : 14,
              shouldBold: isHighlight,
              color: isHighlight ? context.purpleText : context.blackWhite,
              // textAlign: TextAlign.right,
              maxLines: isAddress ? 2 : 1,
              overflow: isAddress ? TextOverflow.ellipsis : TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeSummary() {
    if (_isAmountInvalid) {
      context.toastMsg("Invalid amount range", timeInSec: 2);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const CustomText(
                text: "Trade Summary",
                size: 20,
                shouldBold: true,
              ),
              const SizedBox(height: 20),

              // Summary Items
              _buildSummaryItem(
                "Coin Name:",
                selectedCoin ?? "",
              ),
              const SizedBox(height: 12),

              _buildSummaryItem(
                "Network:",
                selectedNetwork ?? "",
              ),
              const SizedBox(height: 12),

              _buildSummaryItem(
                "Address:",
                currentWalletAddress ?? "",
                isAddress: true,
              ),
              const SizedBox(height: 12),

              _buildSummaryItem(
                "Amount:",
                "\$${_amountController.text}",
              ),
              const SizedBox(height: 12),

              _buildSummaryItem(
                "You will receive:",
                "₦${AdjustUtils.formatWithComma(calculatedRate)}",
                isHighlight: true,
              ),
              const SizedBox(height: 30),

              // Sell Now Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  backgroundColor: AppColors.lightPurple,
                  onPressed: _proceedWithTransaction,
                  text: "Submit Now",
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.hideKeyboard();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
    context.hideKeyboard();
  }

  Future<void> _proceedWithTransaction() async {
    context.hideKeyboard();
    Navigator.pop(context);
    context.hideKeyboard();
    final cryptoVM = Provider.of<CryptoViewModel>(context, listen: false);

    // Validate amount is within range
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final matchingRate = cryptoVM.getRateForAmount(
      selectedCoin!.toLowerCase(),
      amount,
    );

    if (matchingRate == null || !matchingRate.isInRange(amount)) {
      context.toastMsg(
        "Invalid amount. Please check the rate range.",
        color: Colors.red,
      );
      return;
    }

    cryptoVM.setIsLoadToTrue();
    context.hideKeyboard();

    if (mounted) {
      context.toastMsg("Uploading image(s)... [1/2]", color: Colors.green);
    }

    uploadedUrls.clear();

    try {
      // Upload images to Cloudinary
      for (final file in uploadedImages) {
        final uploadedUrl = await CloudinaryUtils.uploadImage(file);
        if (uploadedUrl == null) {
          if (mounted) {
            context.toastMsg("Image failed to upload", color: Colors.red);
          }
          cryptoVM.setIsLoadToFalse();
          return;
        }
        uploadedUrls.add(uploadedUrl);
      }

      // All uploads completed successfully
      await _sellCrypto(cryptoVM, matchingRate);
    } catch (e) {
      cryptoVM.setIsLoadToFalse();
      if (mounted) {
        context.toastMsg("Upload failed: $e", color: Colors.red);
      }
    }
  }

  Future<void> _sellCrypto(
    CryptoViewModel cryptoVM,
    CryptoRateM matchingRate,
  ) async {
    if (mounted) {
      context.toastMsg("Processing transaction... [2/2]", color: Colors.green);
      context.hideKeyboard();
    }

    final payload = {
      "id": userProfileM.userid,
      "data": [
        {
          "rateSpec": matchingRate.id,
          "images": uploadedUrls,
          "userAmount": double.tryParse(_amountController.text) ?? 0,
        }
      ]
    };

    final response = await cryptoVM.sellCrypto(
      payload,
      userProfileM.token!,
    );

    cryptoVM.setIsLoadToFalse();

    if (!mounted) return;

    // Handle different response codes
    switch (response.statusCode) {
      case "TRADE_SAVED":
        context.toastMsg("Trade submitted!", color: Colors.green);
        resetForm();
        // Navigate to history tab
        CacheUtils.historyTab = K.COIN;
        onTabChange?.call(3);
        break;

      case "AUTHENTICATION_FAILED":
        context.toastMsg(response.message, color: Colors.red);
        // Handle logout if needed
        CacheUtils.logout(context);
        break;

      default:
        context.toastMsg(
          response.message,
          color: Colors.red,
        );
        debugPrint("General log: COMPLETE TRADE ERROR: ${response.status} "
            "${response.statusCode} ${response.message}");
        break;
    }
  }

  void resetForm() {
    setState(() {
      selectedCoin = null;
      selectedNetwork = null;
      _amountController.clear();
      uploadedImages.clear();
      uploadedUrls.clear();
      calculatedRate = 0.0;
    });
  }
}
