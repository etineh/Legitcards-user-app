import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:legit_cards/screens/widgets/custom_text.dart';

extension ContextExtensions on BuildContext {
  Color get purpleText => Theme.of(this).colorScheme.primary;
  Color get blackWhite => Theme.of(this).colorScheme.onPrimary;
  Color get cardColor => Theme.of(this).colorScheme.surface;
  Color get backgroundColor => Theme.of(this).colorScheme.onSurface;
  Color get defaultColor => Theme.of(this).colorScheme.onSecondary;
  Color get whiteBlack => Theme.of(this).colorScheme.secondary;
  Color get cardCo => Theme.of(this).colorScheme.shadow;
  Color get coverBgIcon => Theme.of(this).colorScheme.scrim;
  Color get greenColor => Theme.of(this).colorScheme.outline;
  Color get backgroundGray => Theme.of(this).colorScheme.tertiary;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void goNextScreen(String path) {
    kIsWeb ? go(path) : push(path);
  }

  void goNextScreenWithData(String path, {Object? extra}) {
    if (kIsWeb) {
      // Web: Use GoRouter with extra
      goNamed(path, extra: extra);
    } else {
      // Mobile: Use push with arguments
      pushNamed(path, extra: extra);
    }
  }

  // Navigate and remove all previous routes
  void goNextScreenAndRemoveUntil(String routeName, {Object? extra}) {
    final router = GoRouter.of(this); // Get the GoRouter instance from context
    if (kIsWeb) {
      // On web, goNamed replaces the current route (effectively clearing history)
      router.goNamed(routeName, extra: extra);
    } else {
      // On mobile, remove all previous routes
      router.pushReplacementNamed(
        "/login",
        // (route) => false, // Removes all routes until false is returned
        extra: extra,
      );
    }
  }

  void goBack() {
    if (kIsWeb) {
      pop();
    } else {
      Navigator.of(this).pop();
    }
  }

  void toastMsg(String message, {Color color = Colors.orange}) {
    ScaffoldMessenger.of(this)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
  }

  void showInfoDialog({String? title, String? subtitle}) {
    showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: CustomText(text: title ?? "", size: 20),
        content: CustomText(text: subtitle ?? "", size: 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus(); // hide keyboard
  }
}

Future<bool> checkNetwork() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}
