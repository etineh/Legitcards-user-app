import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legit_cards/Utilities/adjust_utils.dart';
import 'package:legit_cards/Utilities/cache_utils.dart';
import 'package:legit_cards/constants/k.dart';
import 'package:legit_cards/data/models/gift_card_trades_m.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';
import 'package:legit_cards/screens/widgets/PrimaryButton.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:provider/provider.dart';

import '../../../Utilities/cloudinary_utils.dart';
import '../../../constants/app_colors.dart';
import '../../../data/models/history_model.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/gift_card_item.wg.dart';
import '../history/card_details_bottom_sheet.dart';
import 'gift_card_vm.dart';

class GiftCardScreen extends StatefulWidget {
  final UserProfileM? userProfileM;
  // final GiftCardTradeVM? giftCardTradeVM;
  final Function(int)? onTabChange;
  final GiftCardAssetM? transferSelectCard;

  const GiftCardScreen(
      {super.key,
      this.userProfileM,
      this.transferSelectCard,
      this.onTabChange});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  late UserProfileM userProfileM;
  late final Function(int)? onTabChange;
  GiftCardAssetM? transferSelectCard;

  bool isPhysical = true;
  GiftCardAssetM? selectedCardAsset;
  GiftCardRateM? selectedRate;
  String? selectedCountry;
  String? selectedType;
  final _amountController = TextEditingController();
  bool _isAmountInvalid = false;
  // final _commentsController = TextEditingController();
  List<File> uploadedImages = [];
  List<String> uploadedUrls = [];
  double calculatedRate = 0.0;
  int _quantity = 1;

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    userProfileM = widget.userProfileM!;
    onTabChange = widget.onTabChange!;
    setState(() {
      if (widget.transferSelectCard != null) {
        selectedCardAsset = widget.transferSelectCard!;
        transferSelectCard = widget.transferSelectCard!;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    // _commentsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _increment() {
    context.hideKeyboard();
    setState(() {
      _quantity++;
    });
    _calculateRate();
  }

  void _decrement() {
    context.hideKeyboard();
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      _calculateRate();
    }
  }

  void _calculateRate() {
    if (selectedCountry != null) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      // Calculate rate based on your logic
      setState(() {
        calculatedRate = amount * (selectedRate?.rate ?? 0) * _quantity;
      });
    }
  }

  bool isAmong3Uploads() {
    const allowedCards = [
      'Master',
      'vanilla master',
      'Vanilla visa',
      'Visa',
      'Walmart visa',
      'American express',
    ];

    final cardName = selectedCardAsset?.name.trim().toLowerCase();

    // check if the name matches any allowed card (case-insensitive)
    return allowedCards.any((c) => c.toLowerCase() == cardName);
  }

  bool isAmong2Uploads() {
    const allowedCards = [
      'Amazon',
    ];

    final cardName = selectedCardAsset?.name.trim().toLowerCase();

    // check if the name matches any allowed card (case-insensitive)
    return allowedCards.any((c) => c.toLowerCase() == cardName);
  }

  final ImagePicker _picker = ImagePicker();

  // Future<void> _pickImage(ImageSource source) async {
  //   // Request permission based on source
  //   final permission =
  //       source == ImageSource.gallery ? Permission.photos : Permission.camera;
  //
  //   final status = await permission.request();
  //
  //   if (status.isGranted) {
  //     final pickedFile = await _picker.pickImage(source: source);
  //     if (pickedFile != null && mounted) {
  //       File file = await AdjustUtils.optimizeImage(File(pickedFile.path));
  //       // Upload to Cloudinary
  //       // final uploadedUrl = await CloudinaryUtils.uploadImage(file);
  //       setState(() {
  //         uploadedImages.add(file);
  //       });
  //     }
  //   } else if (mounted) {
  //     // Handle denied permission
  //     context.toastMsg(
  //       source == ImageSource.gallery
  //           ? "Gallery permission denied"
  //           : "Camera permission denied",
  //     );
  //   }
  // }

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
    final giftCardVM = Provider.of<GiftCardTradeVM>(context);

    return transferSelectCard == null
        ? _buildCardOption(giftCardVM) // 2 grid layout
        : _sellCardInputs(giftCardVM);
  }

  Widget _buildCardOption(GiftCardTradeVM viewModel) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CustomText(
          text: "Select Gift Card Asset",
          shouldBold: true,
          size: 18,
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: context.blackWhite),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                // 👈 default (unfocused) border
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[500]!),
              ),
              focusedBorder: OutlineInputBorder(
                // 👈 when user taps (focused)
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.purpleText, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: _build2GridCardList(viewModel),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _sellCardInputs(GiftCardTradeVM giftCardVM) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ModalProgressHUD(
        inAsyncCall: giftCardVM.isLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with balance
              const CustomText(text: "Get funded in few minutes! ☺️"),
              const SizedBox(height: 20),

              // Gift Card Category selection
              _buildGiftCardSelector(giftCardVM),
              const SizedBox(height: 12),

              // Sub-category selection
              _buildCountrySelector(giftCardVM),
              const SizedBox(height: 12),

              // Sub-category selection
              _buildAssetTypeSelector(giftCardVM),
              const SizedBox(height: 12),

              // Amount input
              _buildAmountInput(),
              const SizedBox(height: 12),

              // Quantity
              _buildQuantity(),
              const SizedBox(height: 12),

              // Rate display
              _buildRateDisplay(),
              const SizedBox(height: 20),

              // require number of images
              _imageInfo(),
              const SizedBox(height: 15),

              // Upload images section
              _buildImageUploadSection(),
              const SizedBox(height: 30),

              // Proceed button
              _buildProceedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGiftCardSelector(GiftCardTradeVM viewModel) {
    return GestureDetector(
      onTap: () => _showGiftCardBottomSheet(viewModel), // show gift cards
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // subtle shadow color
                  blurRadius: 10, // how soft the shadow is
                  offset: const Offset(0, 3), // horizontal, vertical offset
                ),
              ],
              border: Border.all(color: context.backgroundGray, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCardAsset?.name ?? 'Select Gift Card Asset',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedCardAsset != null
                        ? context.blackWhite
                        : Colors.grey[600],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: context.purpleText),
              ],
            ),
          ),
          selectedCardAsset?.specialInfo == null
              ? const SizedBox.shrink()
              : _buildWarningMessage(selectedCardAsset!.specialInfo!),
        ],
      ),
    );
  }

  Widget _buildWarningMessage(String warning) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                  child: CustomText(
                text: warning,
                size: 12,
                color: Colors.black,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector(GiftCardTradeVM viewModel) {
    return GestureDetector(
      onTap: selectedCardAsset == null
          ? () => _showSelectCategoryFirstDialog() // empty gift_card category
          : () => _showCountryBottomSheet(viewModel), // gift card is selected
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // subtle shadow color
              blurRadius: 10, // how soft the shadow is
              offset: const Offset(0, 3), // horizontal, vertical offset
            ),
          ],
          border: Border.all(color: context.backgroundGray, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCountry ?? 'Select Country',
              style: TextStyle(
                fontSize: 16,
                color: selectedCountry != null
                    ? context.blackWhite
                    : Colors.grey[600],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: context.purpleText),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTypeSelector(GiftCardTradeVM viewModel) {
    return GestureDetector(
      onTap: selectedCardAsset == null || selectedCountry == null
          ? () => _showSelectCategoryFirstDialog() // empty category
          : () => _showTypeBottomSheet(viewModel),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // subtle shadow color
              blurRadius: 10, // how soft the shadow is
              offset: const Offset(0, 3), // horizontal, vertical offset
            ),
          ],
          border: Border.all(color: context.backgroundGray, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedType ?? 'Select Card Type',
              style: TextStyle(
                fontSize: 16,
                color: selectedCountry != null
                    ? context.blackWhite
                    : Colors.grey[600],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: context.purpleText),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // subtle shadow color
            blurRadius: 10, // how soft the shadow is
            offset: const Offset(0, 3), // horizontal, vertical offset
          ),
        ],
        border: Border.all(
            color: _isAmountInvalid ? Colors.red : context.backgroundGray,
            width: 0.5),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        onChanged: (value) => _calculateRate(),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.attach_money, // Dollar icon
            color: context.purpleText, // Optional
            size: 22,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: selectedRate == null
              ? 'Card Amount'
              : "Enter amount: ${selectedRate!.from.toInt()} to ${selectedRate!.to.toInt()}",
          hintStyle: TextStyle(color: context.defaultColor.withOpacity(0.2)),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 16, color: context.blackWhite),
      ),
    );
  }

  Widget _buildQuantity() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomText(text: "Quantity", shouldBold: true),
          const SizedBox(width: 20),
          IconButton(
            onPressed: _decrement,
            icon: const Icon(Icons.remove),
            splashRadius: 10,
            color: context.whiteBlack,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(context.purpleText),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CustomText(text: "$_quantity", shouldBold: true, size: 20),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _increment,
            icon: const Icon(Icons.add),
            splashRadius: 10,
            color: context.whiteBlack,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(context.purpleText),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateDisplay() {
    return Container(
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
        children: [
          selectedRate?.rate == null
              ? const SizedBox.shrink()
              : CustomText(
                  text: "Rate: ₦${selectedRate!.rate}/＄",
                  color: context.defaultColor,
                  size: 14,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //== naira symbol
              Text(
                '₦',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.purpleText,
                ),
              ),
              const SizedBox(width: 4),
              //== amount text
              Text(
                AdjustUtils.formatWithComma(calculatedRate),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.purpleText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageInfo() {
    return InkWell(
      onTap: () => context.showInfoDialog(
          title: 'Image Notice',
          subtitle:
              'Kindly upload receipt after uploading front and back of card (if available).'
              '\n\nClick the upload button again to upload more images'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // change the 3 to dynamic number according to asset
          CustomText(text: "Upload card images", color: context.purpleText),
          const SizedBox(width: 10),
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
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
                    CustomText(
                        text: isAmong3Uploads()
                            ? "Frontside"
                            : isAmong2Uploads()
                                ? "  Card  "
                                : "Upload",
                        color: context.whiteBlack),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (isAmong3Uploads())
              GestureDetector(
                onTap: _showPickerOptions,
                child: Container(
                  // width: 85,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.purpleText,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.purpleText, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload, color: context.whiteBlack, size: 30),
                      CustomText(text: "Backside", color: context.whiteBlack),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 10),
            if (isAmong3Uploads() || isAmong2Uploads())
              GestureDetector(
                onTap: _showPickerOptions,
                child: Container(
                  // width: 85,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.purpleText,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.purpleText, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload, color: context.whiteBlack, size: 30),
                      CustomText(text: "Receipt", color: context.whiteBlack),
                    ],
                  ),
                ),
              ),
          ],
        ),

        //  === display images
        if (uploadedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Center(
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
          ),
        ],
      ],
    );
  }

  Widget _buildProceedButton() {
    final isValid = selectedCardAsset != null &&
        selectedCountry != null &&
        _amountController.text.isNotEmpty &&
        uploadedImages.isNotEmpty;

    return isValid
        ? PrimaryButton(
            onPressed: _showTradeSummary,
            backgroundColor: AppColors.lightPurple,
            text: "Proceed",
            textStyle: const TextStyle(color: Colors.white, fontSize: 18),
          )
        : PrimaryButton(
            disabledBackgroundColor: context.backgroundGray,
            text: "Proceed",
            textStyle: const TextStyle(color: Colors.grey, fontSize: 18),
          );
  }

  void _showGiftCardBottomSheet(GiftCardTradeVM viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        // important for updating inside sheet
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                const CustomText(
                  text: "Select Gift Card Asset",
                  shouldBold: true,
                  size: 20,
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: context.blackWhite),
                    onChanged: (value) {
                      setModalState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        // 👈 default (unfocused) border
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[500]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // 👈 when user taps (focused)
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: context.purpleText, width: 2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _buildGiftCardList(viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the category ItemCard
  Widget _buildGiftCardList(GiftCardTradeVM viewModel) {
    final categories = viewModel.assets;
    if (categories.isEmpty) {
      viewModel.fetchCardAssets(userProfileM.token!, context: context);
    }

    // filter by search query
    final filtered = categories.where((c) {
      return c.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const CustomText(text: "No categories found!"),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            // logo
            leading: Container(
              width: 60,
              // height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: category.images[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.blackWhite,
              ),
            ),
            onTap: () {
              setState(() {
                selectedCardAsset = category;
                selectedCountry = null;
                selectedType = null;
                selectedRate = null;
              });
              Navigator.pop(context);
              // fetch rate
              viewModel.fetchAssetRates(userProfileM, category.id,
                  context: context, shouldLoad: true);
              context.hideKeyboard(); // hide keyboard
            },
          ),
        );
      },
    );
  }

  // gift cardItem 2 grid
  Widget _build2GridCardList(GiftCardTradeVM viewModel) {
    final categories = viewModel.assets;
    if (categories.isEmpty) {
      viewModel.fetchCardAssets(userProfileM.token!, context: context);
    }

    // filter by search query
    final filtered = categories.where((c) {
      return c.name.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const CustomText(text: "No categories found!"),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 25,
        childAspectRatio: 1.5,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final cardAsset = filtered[index];

        return GiftCardItemWG(
          // context: context,
          giftCardAsset: cardAsset,
          onTap: () {
            setState(() {
              selectedCardAsset = cardAsset;
              transferSelectCard = cardAsset;
              selectedCountry = null;
              selectedType = null;
              selectedRate = null;
            });
            // fetch rate
            viewModel.fetchAssetRates(userProfileM, cardAsset.id,
                context: context, shouldLoad: true);
          },
        );
      },
    );
  }

  void _showCountryBottomSheet(GiftCardTradeVM viewModel) {
    if (viewModel.rates[selectedCardAsset!.id] == null) {
      // print("General log: I reach here---111");
      viewModel.fetchAssetRates(userProfileM, selectedCardAsset!.id,
          context: context);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7, // dropdown height
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: "Select Country",
              shouldBold: true,
              size: 20,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: viewModel
                    .getFilterCountry(selectedCardAsset!.id)
                    .map((item) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCountry = item.country;
                        selectedRate = item;
                        selectedType = null;
                      });
                      Navigator.pop(context);
                      _calculateRate();
                      context.hideKeyboard(); // hide keyboard
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.country,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.blackWhite,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeBottomSheet(GiftCardTradeVM viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: "Select Card Type",
              shouldBold: true,
              size: 20,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: viewModel
                    .getFilterType(selectedCardAsset!.id, selectedCountry!)
                    .map((item) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = item.type;
                        selectedRate = item;
                      });
                      Navigator.pop(context);
                      _calculateRate();
                      context.hideKeyboard(); // hide keyboard
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.blackWhite,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // when category is not yet selected, show this for country or type
  void _showSelectCategoryFirstDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_neutral, size: 80, color: context.purpleText),
            const SizedBox(height: 16),
            CustomText(
              text: selectedCardAsset == null
                  ? 'Oooops... Please select Gift Card first!'
                  : 'Select country first',
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTradeSummary() {
    if (mounted) context.hideKeyboard(); // hide keyboard
    if ((isAmong3Uploads() && uploadedImages.length < 2)) {
      context.toastMsg("This card requires at-least 2 images");
      return;
    }
    /*
    if ((isAmong2Uploads() && uploadedImages.length < 2)) {
      context.toastMsg("This card requires 2 images");
      return;
    }
     */

    final transaction = GiftCardTradeM(
      id: '', // not yet created — leave empty or temp
      assetName: selectedCardAsset!.name,
      assetImage: selectedCardAsset!.images,
      assetId: selectedCardAsset!.id,
      images: uploadedUrls, // user will upload later
      status: 'SELLING',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      country: selectedRate!.country,
      type: selectedRate!.type,
      quantity: _quantity, // default — you can change later
      userAmount: double.tryParse(_amountController.text) ?? 0.0,
      actualAmount: double.tryParse(_amountController.text) ?? 0.0, // same here
      cost: calculatedRate,
      rate: selectedRate!.rate.toInt(),
      // rateInfo: selectedRate,
      // countryInfo: selectedRate!.countryInfo,
    );

    CardDetailBottomSheet.show(context, transaction, K.submitNow, () async {
      _proceedTransaction();
    });
  }

  Future<void> _proceedTransaction() async {
    context.hideKeyboard();
    final giftCardVM = Provider.of<GiftCardTradeVM>(context, listen: false);

    setState(() => _isAmountInvalid = false);

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (selectedRate != null &&
        (amount < selectedRate!.from || amount > selectedRate!.to)) {
      setState(() => _isAmountInvalid = true);
      context.toastMsg(
        "Card amount should be between ${selectedRate!.from} to ${selectedRate!.to}",
        color: Colors.red,
      );
      return;
    }

    giftCardVM.setIsLoadToTrue();
    if (mounted) {
      context.toastMsg("Uploading image(s)... [1/2]", color: Colors.green);
    }
    uploadedUrls.clear();
    // load image to cloud
    // uploadedUrls = [
    //   "https://res.cloudinary.com/dhvucxi2s/image/upload/v1759693124/legitcards/vaviup5noeeu0m38bujt.jpg",
    //   "https://res.cloudinary.com/dhvucxi2s/image/upload/v1759693125/legitcards/t1sghlug7yup6at5kjk1.jpg"
    // ];
    try {
      for (final file in uploadedImages) {
        final uploadedUrl = await CloudinaryUtils.uploadImage(file);
        if (uploadedUrl == null) {
          if (mounted) context.toastMsg("Image failed to upload");
          giftCardVM.setIsLoadToFalse();
          return;
        }
        uploadedUrls.add(uploadedUrl);
      }

      // All uploads completed successfully
      _sellCard(giftCardVM);
    } catch (e) {
      giftCardVM.setIsLoadToFalse();
      if (mounted) context.toastMsg("Upload failed: $e", color: Colors.red);
    }
  }

  Future<void> _sellCard(GiftCardTradeVM giftCardVM) async {
    if (mounted) {
      context.toastMsg("Processing card... [2/2]", color: Colors.green);
      context.hideKeyboard(); // hide keyboard
    }
    final payload = {
      "id": userProfileM.userid,
      "data": [
        {
          "rateSpec": selectedRate?.id,
          "images": uploadedUrls,
          "userAmount": double.tryParse(_amountController.text) ?? 0,
          "quantity": _quantity,
        }
      ]
    };

    final giftRes = await giftCardVM.sellGiftCard(payload, userProfileM.token!);
    if (mounted) context.toastMsg(giftRes.message);

    if (giftRes.statusCode == "TRADE_SAVED") {
      if (mounted) context.toastMsg("Trade submitted!", color: Colors.green);
      // go to history
      CacheUtils.reloadCardTab = true;
      onTabChange?.call(3);
    }
    // print("General log: the total link image is - $uploadedUrls");
  }
}

/*
{"statusCode":"INVALID_TRADING_PERIOD","message":"This asset is avaliable for trade from 00:00 to 11:59","status":400,"data":[{"assetName":"cvs pharmacy ","assetType":"physical card ","assetCountry":"USA","assetId":"680367720d818cfab051482a"}]}
 */
