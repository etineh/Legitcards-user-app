import 'package:flutter/material.dart';
import 'package:legit_cards/data/models/user_model.dart';
import 'package:legit_cards/extension/inbuilt_ext.dart';

import '../../../data/models/gift_card_trades_m.dart';
import '../../../data/repository/app_repository.dart';
import '../../../data/repository/share_ref_repo.dart';

class GiftCardTradeVM extends ChangeNotifier {
  final AppRepository _repository = AppRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<GiftCardAssetM> _assets = [];
  List<GiftCardAssetM> get assets => _assets;

  Future<void> fetchCardAssets(String token,
      {bool shouldLoad = true, BuildContext? context}) async {
    // Load from local storage first
    final localAssets = await LocalShareRefRepo.getCachedCardAssets();
    if (localAssets != null && localAssets.isNotEmpty) {
      _assets = localAssets;
      notifyListeners(); // show cached data immediately
    }

    // Fetch from API
    final response = await getResponse(
      _repository.fetchCardAsset(token),
      shouldLoad: shouldLoad,
    );

    if (response.statusCode == "ASSET_FETCHED") {
      // Filter only active cards
      final filteredAssets = response.data
          .where((asset) => asset.cardActive == true)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // Update state with fresh active data
      _assets = filteredAssets;
      notifyListeners();

      // Save active cards to local storage
      await LocalShareRefRepo.saveCardAssets(filteredAssets);
    } else if (context?.mounted ?? false) {
      context?.toastMsg(response.message);
    }
  }

  /// Map of assetId → list of rate models
  final Map<String, List<GiftCardRateM>> _rates = {};
  Map<String, List<GiftCardRateM>> get rates => _rates;

  Future<void> fetchAssetRates(UserProfileM user, String assetId,
      {bool shouldLoad = true, BuildContext? context}) async {
    // fetch when first time
    if (_rates[assetId] == null) {
      if (context!.mounted) context.toastMsg("Fetching rate...");
      // fetch from repo - api
      final response = await getResponse(
        _repository.fetchAssetRate(user, assetId),
        shouldLoad: shouldLoad,
      );

      if (response.statusCode == "RATE_FETCHED") {
        _rates[assetId] = response.data;
        notifyListeners();
      } else if (context.mounted) {
        context.toastMsg(response.message);
      }
    }
  }

  Future<GiftCardResponseM> sellGiftCard(
      Map<String, dynamic> payload, String token) async {
    return getResponse(_repository.sellGiftCard(payload, token));
  }

  // reusable function
  Future<T> getResponse<T>(Future<T> repoCall, {bool shouldLoad = true}) async {
    if (shouldLoad) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      return await repoCall;
    } catch (e) {
      rethrow;
    } finally {
      if (shouldLoad) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setIsLoadToTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setIsLoadToFalse() {
    _isLoading = false;
    notifyListeners();
  }

  // ======== logic methods

  // get the country available for each asset
  List<GiftCardRateM> getFilterCountry(String cardAssetId) {
    final allRates = rates[cardAssetId] ?? [];

    // Create a Set to track unique country names
    final Set<String> seenCountries = {};

    // Keep only the first rate per country
    final uniqueRates = allRates.where((rate) {
      if (seenCountries.contains(rate.country)) {
        return false;
      } else {
        seenCountries.add(rate.country);
        return true;
      }
    }).toList();

    // Sort alphabetically (case-insensitive)
    uniqueRates.sort(
        (a, b) => a.country.toLowerCase().compareTo(b.country.toLowerCase()));

    return uniqueRates;
  }

  // get the Types that belongs to each country
  List<GiftCardRateM> getFilterType(String cardAssetId, String country) {
    final allRates = rates[cardAssetId] ?? [];

    // Filter only rates for the selected country
    final countryRates =
        allRates.where((rate) => rate.country == country).toList();

    // Create a Set to track unique type names
    final Set<String> seenTypes = {};

    // Keep only the first rate per type
    final uniqueTypes = countryRates.where((rate) {
      if (seenTypes.contains(rate.type)) {
        return false;
      } else {
        seenTypes.add(rate.type);
        return true;
      }
    }).toList();

    // Sort alphabetically by type
    uniqueTypes
        .sort((a, b) => a.type.toLowerCase().compareTo(b.type.toLowerCase()));

    return uniqueTypes;
  }
}
